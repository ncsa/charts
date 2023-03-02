# MLFlow Helm Chart
This chart deploys a complete MLFlow instance along with a postgres database
and minio object store. It can optionally use OAuth2-Proxy to secure access to
the tracking server for both web browsers and the MLFlow API.

The deployed service will proxy artifact server requests to the object store
back end so you don't need to distribute AWS_ACCESS_KEYs to users.

## Notes on Authentication
This chart has been tested out using a [Keycloak](https://www.keycloak.org) as
the backend identity and access management service. It turns out that teaching 
OAuth2-proxy to accept JWTs from many common providers is problematic. We 
settled on Keycloak as the best way to offer the features we want.

It is possible to use Keycloak with a 
[Device Flow](https://www.rfc-editor.org/rfc/rfc8628) to make it eash to get a 
valid token from the command line. We developed a 
[tool](https://pypi.org/project/mlflow-token/) to support this. It assumes that
the MLflow instance in the user's `MLFLOW_TRACKING_URI` points to a deployment
made with this chart. It uses an oauth2 endpoint to find the URL of the
Keycloak realm and starts a device flow against that realm.

### OAuth2-Proxy Secret
In order for the device flow to work, the OAuth client must be public and not
require a secret. If you have a deployment that depends on a OAuth secret then
you can create a kubernetes secret in the namespace. This secret must have the
following two properties:
- cookie_secret 
- client_secret

These values will be read and passed on to the OAuth2-Proxy as environment
variables.


## Configurable Values
Here are some of the useful settings in `values.yaml` - there are many other
settings which are typical of most helm charts.

| Value                       | Description                                                                        | Default Value |
|-----------------------------|------------------------------------------------------------------------------------|---------------|
| MLFlow.artifacts.bucketName | The bucket where the artifacts will be stored                                      |               |
| services.postgres.enabled   | Deploy a postgres subchart with this chart?                                        | true          |
| services.minio.enabled      | Deploy a minio subchart with this chart?                                           | true          |
| oauth2Proxy.enabled         | Protect the tracking server with an OAuth2 Proxy?                                  | true          |
| oauth2Proxy.secret          | Kubernetes secret holding values to configure the proxy                            |               |
| oauth2Proxy.clientID        | Client ID string for the value in your OAuth2 client.                              |               |
| oauth2Proxy.provider        | A valid  setting for OAuth2-Proxy                                                  | keycloak-oidc |
| oauth2Proxy.emailDomains    | List of domain names for users that will be automatically accepted                 | *             |
| oauth2Proxy.allowedGroups   | YAML List of groups that will be accepted (best to set oidc_groups_claim with this |               |

