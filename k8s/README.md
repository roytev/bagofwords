## Install with Kubernetes
---
You can install Bag of Words on a Kubernetes cluster. The Helm chart can deploy the app with a bundled PostgreSQL instance **or** connect to an external managed database such as AWS Aurora with IAM authentication.

### 1. Add the Helm Repository

```bash
helm repo add bow https://helm.bagofwords.com
helm repo update
```

### 2. Install or Upgrade the Chart

Here are a few examples of how to install or upgrade the Bag of Words Helm chart:

### Deploy with a bundled PostgreSQL instance
```bash
helm upgrade -i --create-namespace \
 -n bowapp bowapp bow/bagofwords \
 --set postgres.userDatabase.user.value=<PG-USER> \
 --set postgres.userDatabase.password.value=<PG-PASS> \
 --set postgres.userDatabase.name=bagofwords \
 --set host=<HOST>
```

### Deploy without TLS and with a custom hostname
```bash
helm upgrade -i --create-namespace \
 -n bowapp bowapp bow/bagofwords \
 --set host=<HOST> \
 --set postgres.userDatabase.user.value=<PG-USER> \
 --set postgres.userDatabase.password.value=<PG-PASS> \
 --set postgres.userDatabase.name=bagofwords \
 --set ingress.tls.enabled=false
```

### Deploy with TLS, cert-manager, and Google OAuth
```bash
helm upgrade -i --create-namespace \
 -n bowapp bowapp bow/bagofwords \
 --set host=<HOST> \
 --set postgres.userDatabase.user.value=<PG-USER> \
 --set postgres.userDatabase.password.value=<PG-PASS> \
 --set postgres.userDatabase.name=bagofwords \
 --set config.googleOAuth.enabled=true \
 --set config.googleOAuth.clientId=<CLIENT_ID> \
 --set config.googleOAuth.clientSecret=<CLIENT_SECRET>
```

### Deploy with AWS Aurora and IAM Authentication

When using a managed database like AWS Aurora PostgreSQL, the chart skips the bundled PostgreSQL subchart and connects directly to your Aurora cluster. Passwords are generated at runtime using IAM — no static credentials are stored.

**Prerequisites:**
- An Aurora PostgreSQL cluster with IAM database authentication enabled
- A database user with `GRANT rds_iam TO <username>`
- An IAM role with `rds-db:connect` permission
- In EKS: an IRSA (IAM Roles for Service Accounts) annotation on the pod's service account

```bash
helm upgrade -i --create-namespace \
 -n bowapp bowapp bow/bagofwords \
 --set host=<HOST> \
 --set postgres.enabled=false \
 --set externalDatabase.enabled=true \
 --set database.auth.provider=aws_iam \
 --set database.auth.region=us-east-1 \
 --set database.auth.sslMode=require \
 --set database.host=<AURORA-CLUSTER-ENDPOINT> \
 --set database.port=5432 \
 --set database.username=<DB-USER> \
 --set database.name=<DB-NAME> \
 --set serviceAccount.annotations.'eks\.amazonaws\.com/role-arn'=arn:aws:iam::<ACCOUNT>:role/<ROLE-NAME>
```

For example, with a real Aurora cluster:
```bash
helm upgrade -i --create-namespace \
 -n bowapp bowapp bow/bagofwords \
 --set host=bow.example.com \
 --set postgres.enabled=false \
 --set externalDatabase.enabled=true \
 --set database.auth.provider=aws_iam \
 --set database.auth.region=us-east-1 \
 --set database.auth.sslMode=require \
 --set database.host=bow-pg1-instance-1.cry2og862pqb.us-east-1.rds.amazonaws.com \
 --set database.port=5432 \
 --set database.username=bow_user \
 --set database.name=postgres \
 --set serviceAccount.annotations.'eks\.amazonaws\.com/role-arn'=arn:aws:iam::123456789012:role/bow-rds-role
```

### Deploy with Aurora using values.yaml

For Aurora deployments, you can also set all values in a file:

```yaml
# aurora-values.yaml
host: bow.example.com

postgres:
  enabled: false

externalDatabase:
  enabled: true

database:
  auth:
    provider: aws_iam
    region: us-east-1
    sslMode: require
  host: bow-pg1-instance-1.cry2og862pqb.us-east-1.rds.amazonaws.com
  port: 5432
  username: bow_user
  name: postgres

serviceAccount:
  name: bowapp
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/bow-rds-role

config:
  encryptionKey: "${BOW_ENCRYPTION_KEY}"
  baseUrl: "https://bow.example.com"
```

```bash
helm upgrade -i --create-namespace \
 -n bowapp bowapp bow/bagofwords \
 -f aurora-values.yaml
```

### Use existing Secret
1. Make sure the namespace exists, if not create it
```bash
   kubectl create namespace <namespace>
```
2. Create the secret with the environment variables you want to inject
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>
  namespace: <namespace>
stringData:
  BOW_DATABASE_URL: "postgresql://<postgres-user>:<postgres-password>@<postgres-host>:5432/<postgres-database>"
  BOW_ENCRYPTION_KEY: "<encryption-key>"
  BOW_SMTP_PASSWORD: "<smtp-password>"
  # Add any other BOW_* env vars you want to override
```

**Note**: The new chart resolves `${ENV_VAR}` placeholders in `bow-config.yaml` at runtime, so any secret value referenced as `${BOW_FOO}` in the config will be read from the matching env var.

3. Deploy BoW Application
```bash
helm upgrade -i --create-namespace \
 -n bowapp bowapp bow/bagofwords \
 --set postgres.enabled=false \
 --set externalDatabase.enabled=true \
 --set envFromSecrets={<secret-name>}
```


### Service Account annotations
For adding a SA annotation pass the following flag during `helm install` command
`--set serviceAccount.annotations.foo=bar`
Otherwise, set annotations directly in values.yaml file by updating
```yaml
serviceAccount:
  ...
  annotations:
    foo: bar
```

For IRSA (EKS IAM Roles for Service Accounts), annotate with the IAM role ARN:
```bash
--set serviceAccount.annotations.'eks\.amazonaws\.com/role-arn'=arn:aws:iam::<ACCOUNT>:role/<ROLE-NAME>
```

### Configure node selector
To schedule the BowApp pod on a specific node pool, set `nodeSelector` on the app:
```bash
--set nodeSelector.'karpenter\.sh/nodepool'=general-apps
```

To also schedule the bundled PostgreSQL pod on a specific node, set `postgres.nodeSelector`:
```bash
--set postgres.nodeSelector.'kubernetes\.io/hostname'=kind-control-plane
```

Or set both directly in values.yaml:
```yaml
nodeSelector:
  karpenter.sh/nodepool: general-apps

postgres:
  nodeSelector:
    kubernetes.io/hostname: kind-control-plane
```
