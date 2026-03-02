# Bag of Words Helm Chart

This Helm chart deploys **Bag of Words** on Kubernetes with a bundled PostgreSQL instance (groundhog2k/postgres) or an external managed database (e.g. AWS Aurora with IAM authentication).

See [k8s/README.md](../README.md) for full installation examples including Aurora IAM auth, existing secrets, OIDC, and node scheduling.

## Quick Start

```bash
helm repo add bow https://helm.bagofwords.com
helm repo update

# Deploy with bundled PostgreSQL
helm upgrade -i --create-namespace \
  -n bowapp bowapp bow/bagofwords \
  --set postgres.userDatabase.user.value=<DB-USER> \
  --set postgres.userDatabase.password.value=<DB-PASS> \
  --set postgres.userDatabase.name.value=bagofwords \
  --set host=<HOST>

# Deploy with AWS Aurora + IAM auth
helm upgrade -i --create-namespace \
  -n bowapp bowapp bow/bagofwords \
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
