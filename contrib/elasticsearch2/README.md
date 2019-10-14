# elasticsearch2-helm
A simple Helm chart proof-of-concept for Elasticsearch2.

WARNING: This version of Elasticsearch is extermely out-of-date.

Please consider using a newer version of Elasticsearch along with the official Helm chart, located here: https://github.com/elastic/helm-charts/tree/master/elasticsearch

Previous versions of the Helm chart can also be found here: https://github.com/helm/charts/tree/master/stable/elasticsearch


## Approach
Uses a Kubernetes [headless service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) to discover additional nodes. This service needs some special configuration to tell Kubernetes not to allocate an IP for it and to create and publish endpoints even if things are not in a ready state. This is necessary since ES2 needs to discover during startup, at which point one or more containers may not yet be ready.

Inspired by the approach recommended by the now-defunct [elasticsearch-cloud-kubernetes](https://github.com/fabric8io/elasticsearch-cloud-kubernetes#kubernetes-cloud-plugin-for-elasticsearch) by Fabric8IO.


## Configuration

Below are the supported configuration options that can be overridden or customized in `values.yaml`:

| Key | Description | Default Value |
| --- | --- | --- |
| `replicaCount` | The initial number of elasticsearch containers that will make up the cluster | `1` |
| `storage.accessModes` | The access mode with which to mount elasticsearch data | `[ "ReadWriteOnce" ]` |
| `storage.storageClass` | The storage class to use to provision the elasticsearch data PVC | (empty - use cluster default) |
| `storage.capacity` | The size of the PVC to provision for elasticsearch data | `1Gi` |
| `image.repository` | The Docker image repo/name to run | `elasticsearch` |
| `image.tag` | The Docker image tag to run | `2.4.6` |
| `image.pullPolicy` | The Docker image pullPolicy to use when running | `IfNotPresent` |
| `ingress.enabled` | Whether an ingress rule should be deployed for ElasticHQ | `true` |
| `ingress.host` | The hostname to use for the ingress rule | `kooper.dyn.ncsa.edu` |
| `elasticsearch.config` | Additional configuration to pass into [`elasticsearch.yml`](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/setup-configuration.html#settings) | (config block) |
| `resources` | [Resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) that should be applied to elasticsearch instances | None |
| `nodeSelector` | [Node selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) that should be applied to elasticsearch instances | None |
| `tolerations` | [Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) that should be applied to elasticsearch instances | None |
| `affinity` | [Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) that should be applied to elasticsearch instances | None |


## The Setup

1. Install minikube binary and run `minikube start` (or use your own preferred method of getting a Kubernetes cluster up and running)
2. Install helm client and run `helm init` (this will run Tiller on your minikube cluster)
3. Clone this repository:`git clone https://github.com/bodom0015/elasticsearch2-helm && cd elasticsearch2-helm`
4. Modify parameters as desired: `vi values.yaml`
5. Deploy the Helm chart: `helm upgrade --install es2 .`

By default, 1 replica will be deployed and will become the master:
```bash
$ helm upgrade --install es2 --namespace=elastic .
Release "es2" does not exist. Installing it now.
NAME:   es2
LAST DEPLOYED: Tue Oct  1 22:40:17 2019
NAMESPACE: elastic
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                  READY  STATUS             RESTARTS  AGE
es2-elasticsearch2-0  0/1    ContainerCreating  0         1s

==> v1/ConfigMap
NAME                DATA  AGE
es2-elasticsearch2  1     1s

==> v1/Service
NAME                          TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)   AGE
es2-elasticsearch2-api        ClusterIP  10.105.115.234  <none>       9200/TCP  1s
es2-elasticsearch2-discovery  ClusterIP  None            <none>       9300/TCP  1s

==> v1beta2/StatefulSet
NAME                DESIRED  CURRENT  AGE
es2-elasticsearch2  1        1        1s


$ kubectl logs -f es2-elasticsearch2-0 -n elastic
[2019-10-02 03:40:29,517][INFO ][node                     ] [Joe Fixit] version[2.4.6], pid[1], build[5376dca/2017-07-18T12:17:44Z]
[2019-10-02 03:40:29,521][INFO ][node                     ] [Joe Fixit] initializing ...
[2019-10-02 03:40:35,412][INFO ][plugins                  ] [Joe Fixit] modules [reindex, lang-expression, lang-groovy], plugins [], sites []
[2019-10-02 03:40:36,174][INFO ][env                      ] [Joe Fixit] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/sda1)]], net usable_space [14.1gb], net total_space [16.9gb], spins? [possibly], types [ext4]
[2019-10-02 03:40:36,175][INFO ][env                      ] [Joe Fixit] heap size [1007.3mb], compressed ordinary object pointers [true]
[2019-10-02 03:40:59,813][INFO ][node                     ] [Joe Fixit] initialized
[2019-10-02 03:40:59,813][INFO ][node                     ] [Joe Fixit] starting ...
[2019-10-02 03:41:00,750][INFO ][transport                ] [Joe Fixit] publish_address {172.17.0.5:9300}, bound_addresses {127.0.0.1:9300}, {172.17.0.5:9300}
[2019-10-02 03:41:00,917][INFO ][discovery                ] [Joe Fixit] es2-elasticsearch2/v5OsITW3RFGElU4yVTxSAA
[2019-10-02 03:41:04,443][INFO ][cluster.service          ] [Joe Fixit] new_master {Joe Fixit}{v5OsITW3RFGElU4yVTxSAA}{172.17.0.5}{172.17.0.5:9300}, reason: zen-disco-join(elected_as_master, [0] joins received)
[2019-10-02 03:41:04,545][INFO ][http                     ] [Joe Fixit] publish_address {172.17.0.5:9200}, bound_addresses {127.0.0.1:9200}, {172.17.0.5:9200}
[2019-10-02 03:41:04,546][INFO ][node                     ] [Joe Fixit] started
[2019-10-02 03:41:04,725][INFO ][gateway                  ] [Joe Fixit] recovered [0] indices into cluster_state
```


## The Scale-Up
Scale up to 2 replicas by running the following:
```bash
kubectl scale statefulset es2-elasticsearch2 -n elastic --replicas=2 --current-replicas=1
```

This will create a second replica pod that will automatically join the cluster once it comes online:
```bash
$ kubectl get pods -n elastic
NAME                   READY   STATUS    RESTARTS   AGE
es2-elasticsearch2-0   1/1     Running   0          13m
es2-elasticsearch2-1   1/1     Running   0          12m

$ kubectl logs -f es2-elasticsearch2-1 -n elastic
[2019-10-02 03:41:50,625][INFO ][node                     ] [Right-Winger] version[2.4.6], pid[1], build[5376dca/2017-07-18T12:17:44Z]
[2019-10-02 03:41:50,628][INFO ][node                     ] [Right-Winger] initializing ...
[2019-10-02 03:41:54,408][INFO ][plugins                  ] [Right-Winger] modules [reindex, lang-expression, lang-groovy], plugins [], sites []
[2019-10-02 03:41:54,855][INFO ][env                      ] [Right-Winger] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/sda1)]], net usable_space [14.1gb], net total_space [16.9gb], spins? [possibly], types [ext4]
[2019-10-02 03:41:54,862][INFO ][env                      ] [Right-Winger] heap size [1007.3mb], compressed ordinary object pointers [true]
[2019-10-02 03:42:12,612][INFO ][node                     ] [Right-Winger] initialized
[2019-10-02 03:42:12,612][INFO ][node                     ] [Right-Winger] starting ...
[2019-10-02 03:42:13,218][INFO ][transport                ] [Right-Winger] publish_address {172.17.0.6:9300}, bound_addresses {127.0.0.1:9300}, {172.17.0.6:9300}
[2019-10-02 03:42:13,239][INFO ][discovery                ] [Right-Winger] es2-elasticsearch2/RxiYhWrOTpyUG-M1GWRnkQ
[2019-10-02 03:42:17,019][INFO ][cluster.service          ] [Right-Winger] detected_master {Joe Fixit}{v5OsITW3RFGElU4yVTxSAA}{172.17.0.5}{172.17.0.5:9300}, added {{Joe Fixit}{v5OsITW3RFGElU4yVTxSAA}{172.17.0.5}{172.17.0.5:9300},}, reason: zen-disco-receive(from master [{Joe Fixit}{v5OsITW3RFGElU4yVTxSAA}{172.17.0.5}{172.17.0.5:9300}])
[2019-10-02 03:42:17,349][INFO ][http                     ] [Right-Winger] publish_address {172.17.0.6:9200}, bound_addresses {127.0.0.1:9200}, {172.17.0.6:9200}
[2019-10-02 03:42:17,351][INFO ][node                     ] [Right-Winger] started
```

And we can see in our original (master) logs that the new pod has successfully joined the cluster:
```bash
$ kubectl logs -f es2-elasticsearch2-0
[2019-10-02 03:40:29,517][INFO ][node                     ] [Joe Fixit] version[2.4.6], pid[1], build[5376dca/2017-07-18T12:17:44Z]
[2019-10-02 03:40:29,521][INFO ][node                     ] [Joe Fixit] initializing ...
[2019-10-02 03:40:35,412][INFO ][plugins                  ] [Joe Fixit] modules [reindex, lang-expression, lang-groovy], plugins [], sites []
[2019-10-02 03:40:36,174][INFO ][env                      ] [Joe Fixit] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/sda1)]], net usable_space [14.1gb], net total_space [16.9gb], spins? [possibly], types [ext4]
[2019-10-02 03:40:36,175][INFO ][env                      ] [Joe Fixit] heap size [1007.3mb], compressed ordinary object pointers [true]
[2019-10-02 03:40:59,813][INFO ][node                     ] [Joe Fixit] initialized
[2019-10-02 03:40:59,813][INFO ][node                     ] [Joe Fixit] starting ...
[2019-10-02 03:41:00,750][INFO ][transport                ] [Joe Fixit] publish_address {172.17.0.5:9300}, bound_addresses {127.0.0.1:9300}, {172.17.0.5:9300}
[2019-10-02 03:41:00,917][INFO ][discovery                ] [Joe Fixit] es2-elasticsearch2/v5OsITW3RFGElU4yVTxSAA
[2019-10-02 03:41:04,443][INFO ][cluster.service          ] [Joe Fixit] new_master {Joe Fixit}{v5OsITW3RFGElU4yVTxSAA}{172.17.0.5}{172.17.0.5:9300}, reason: zen-disco-join(elected_as_master, [0] joins received)
[2019-10-02 03:41:04,545][INFO ][http                     ] [Joe Fixit] publish_address {172.17.0.5:9200}, bound_addresses {127.0.0.1:9200}, {172.17.0.5:9200}
[2019-10-02 03:41:04,546][INFO ][node                     ] [Joe Fixit] started
[2019-10-02 03:41:04,725][INFO ][gateway                  ] [Joe Fixit] recovered [0] indices into cluster_state
[2019-10-02 03:42:16,933][INFO ][cluster.service          ] [Joe Fixit] added {{Right-Winger}{RxiYhWrOTpyUG-M1GWRnkQ}{172.17.0.6}{172.17.0.6:9300},}, reason: zen-disco-join(join from node[{Right-Winger}{RxiYhWrOTpyUG-M1GWRnkQ}{172.17.0.6}{172.17.0.6:9300}])
```


### Monitoring
Using this chart, ElasticHQ is also deployed alongside your cluster to monitor and administer it.

The UI can be accessed by navigating your browser to the `/elastic` path of the hostname configured as `ingress.host` in your `values.yaml`. By default, this should be http://kooper.dyn.ncsa.edu/elastic.

You will be prompted by ElasticHQ to "Connect" to a cluster by hostname, which should be automatically populated with:
```
http://es2-elasticsearch2-api:9200
```

Press "Connect" to access the Monitoring interface.

You should see your cluster listed at the top list, along with a red/yellow/green indicator for cluster health. At the top-right, you should see a `Nodes` dropdown containing each of your elasticsearch nodes as well as further links containing verbose details about each node.

NOTE: If you used a different `--name` besides `es2` for your Helm release, that name will need to be substituted in for `es2` in the above formatted string.


