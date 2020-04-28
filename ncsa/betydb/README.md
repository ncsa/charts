## Upgrading BETY

If the password is generated you will need to save this secret before you upgrade. You can do this using the following commands. **If you do not do this, you will not be able to retrieve the previous secrets**.

```
BETY_PASSWORD=$(kubectl get secrets betydb -o json | jq -r '.data.betyPassword' | base64 -d)
BETY_SECRETKEY=$(kubectl get secrets betydb -o json | jq -r '.data.secretKey' | base64 -d)
POSTGRESQL_PASSWORD=$(kubectl get secrets betydb-postgresql -o json | jq -r '.data."postgresql-password"' | base64 -d)
```

now you can upgrade and use the secrets retrieved.

```
helm upgrade betydb ncsa/betydb \
    --set betyPassword="${BETY_PASSWORD}" \
    --set secretKey="${BETY_SECRETKEY}" \
    --set postgresql.postgresqlPassword="${POSTGRESQL_PASSWORD}"
```
