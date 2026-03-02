# bagofwords

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Bag of Words — self-hostable AI data and analytics platform

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

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://groundhog2k.github.io/helm-charts | postgres | 1.6.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for the app pod |
| autoscaling | object | `{"enabled":false,"maxReplicas":5,"minReplicas":1,"targetCPUUtilizationPercentage":70,"targetMemoryUtilizationPercentage":80}` | Horizontal Pod Autoscaler. When enabled, the Deployment omits `replicas`. |
| commonLabels | object | `{}` | Extra labels added to every resource |
| config | object | `{"auth":{"mode":"hybrid"},"baseUrl":"http://localhost:3000","encryptionKey":"${BOW_ENCRYPTION_KEY}","features":{"allowMultipleOrganizations":false,"allowUninvitedSignups":false,"verifyEmails":false},"googleOAuth":{"clientId":"","clientSecret":"","enabled":false},"intercom":{"enabled":false},"licenseKey":"","oidcProviders":[],"smtp":{"enabled":false,"fromEmail":"","fromName":"Bag of Words","host":"","password":"","port":587,"useCredentials":true,"useSsl":false,"useTls":true,"username":"","validateCerts":true},"telemetry":{"enabled":true}}` | Application configuration rendered into bow-config.yaml |
| config.auth | object | `{"mode":"hybrid"}` | Authentication mode: `hybrid` (local + SSO), `local_only`, or `sso_only` |
| config.baseUrl | string | `"http://localhost:3000"` | Public base URL shown in emails and redirect URIs |
| config.encryptionKey | string | `"${BOW_ENCRYPTION_KEY}"` | Fernet encryption key for sensitive DB data. Use `${BOW_ENCRYPTION_KEY}` in production. |
| config.features | object | `{"allowMultipleOrganizations":false,"allowUninvitedSignups":false,"verifyEmails":false}` | Feature flags |
| config.features.allowMultipleOrganizations | bool | `false` | Allow creating multiple organizations |
| config.features.allowUninvitedSignups | bool | `false` | Allow users to sign up without an invitation |
| config.features.verifyEmails | bool | `false` | Require email verification on sign-up |
| config.googleOAuth | object | `{"clientId":"","clientSecret":"","enabled":false}` | Google OAuth2 settings |
| config.googleOAuth.clientSecret | string | `""` | Use `${BOW_GOOGLE_CLIENT_SECRET}` to pull from an env var / Secret |
| config.intercom | object | `{"enabled":false}` | Intercom chat widget |
| config.licenseKey | string | `""` | Enterprise license key. Use `${BOW_LICENSE_KEY}` to pull from env at runtime. |
| config.oidcProviders | list | `[]` — see values.yaml for a Microsoft Entra ID example | OIDC provider list. clientId and clientSecret should use `${ENV_VAR}` placeholders. |
| config.smtp | object | `{"enabled":false,"fromEmail":"","fromName":"Bag of Words","host":"","password":"","port":587,"useCredentials":true,"useSsl":false,"useTls":true,"username":"","validateCerts":true}` | SMTP settings for transactional email |
| config.smtp.enabled | bool | `false` | Set to true to enable the smtp_settings block in bow-config.yaml |
| config.smtp.password | string | `""` | Use `${BOW_SMTP_PASSWORD}` in production |
| config.telemetry | object | `{"enabled":true}` | Telemetry / usage analytics |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":false,"runAsNonRoot":false}` | Security context applied to the main container |
| database | object | `{"auth":{"provider":"password","region":"","sslMode":""},"host":"","name":"","port":5432,"username":""}` | External managed database settings (Aurora / RDS). Used when `externalDatabase.enabled=true`. |
| database.auth | object | `{"provider":"password","region":"","sslMode":""}` | Auth method and cloud settings |
| database.auth.provider | string | `"password"` | `password` for static credentials, `aws_iam` for IAM token auth |
| database.auth.region | string | `""` | AWS region for IAM token generation (AWS only) |
| database.auth.sslMode | string | `""` | SSL mode, e.g. `require` or `verify-full` (required for IAM auth) |
| database.host | string | `""` | Database host / cluster endpoint |
| database.name | string | `""` | Database name |
| database.username | string | `""` | Database user (must have `GRANT rds_iam` for AWS IAM auth) |
| env | list | `[]` | Extra environment variables injected into the container (plain values or valueFrom references) |
| envFromConfigMaps | list | `[]` | Inject all keys from existing ConfigMaps as env vars (envFrom configMapRef) |
| envFromSecrets | list | `[]` | Inject all keys from existing Secrets as env vars (envFrom secretRef) |
| externalDatabase | object | `{"enabled":false}` | Set to true when using an external database instead of the bundled subchart |
| extraVolumeMounts | list | `[]` | Extra volume mounts added to the main container |
| extraVolumes | list | `[]` | Extra volumes added to the Deployment (e.g. for custom TLS certs) |
| fullnameOverride | string | `""` |  |
| host | string | `"app.bagofwords.com"` | Public-facing hostname (used by Ingress / HTTPRoute) |
| httpRoute | object | `{"enabled":false,"hostnames":[],"parentRefs":[]}` | Kubernetes Gateway API HTTPRoute. Set `ingress.enabled=false` when using this. |
| httpRoute.hostnames | list | `[]` | Hostnames for the HTTPRoute |
| httpRoute.parentRefs | list | `[]` | Gateway parentRefs (required when enabled) |
| image | object | `{"pullPolicy":"Always","repository":"bagofwords/bagofwords","tag":"latest"}` | Container image |
| ingress | object | `{"annotations":{},"className":"nginx","enabled":true,"tls":{"clusterIssuer":"prod-cluster-issuer","enabled":true,"secretName":"bowapp-cert"}}` | Standard Kubernetes Ingress. Disable when using `httpRoute` instead. |
| ingress.annotations | object | `{}` | Extra Ingress annotations (e.g. `nginx.ingress.kubernetes.io/proxy-body-size: "50m"`) |
| ingress.className | string | `"nginx"` | IngressClass name (e.g. `nginx`, `traefik`) |
| ingress.tls.clusterIssuer | string | `"prod-cluster-issuer"` | cert-manager ClusterIssuer name. Leave empty to skip the annotation. |
| ingress.tls.enabled | bool | `true` | Enable TLS on the Ingress |
| ingress.tls.secretName | string | `"bowapp-cert"` | TLS Secret name (created by cert-manager or pre-existing) |
| livenessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/health","port":3000},"initialDelaySeconds":15,"periodSeconds":20,"timeoutSeconds":5}` | Liveness probe |
| nameOverride | string | `""` | Override chart name / full name |
| nodeSelector | object | `{}` | Node selector for the app pod. Example: `karpenter.sh/nodepool: general-apps` |
| podAnnotations | object | `{}` | Annotations added to every pod. Example: `reloader.stakater.com/auto: "true"` |
| podDisruptionBudget | object | `{"enabled":false,"minAvailable":1}` | Pod Disruption Budget to limit voluntary disruptions |
| podDisruptionBudget.minAvailable | int | `1` | Minimum number of available pods during disruptions |
| podLabels | object | `{}` | Extra labels added to every pod |
| podSecurityContext | object | `{"fsGroup":1000}` | Security context applied to the pod |
| postgres | object | `{"enabled":true,"nodeSelector":{},"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"250m","memory":"256Mi"}},"settings":{"superuserPassword":{"value":""}},"storage":{"className":"","requestedSize":"20Gi"},"tolerations":[],"userDatabase":{"name":{"value":"bagofwords"},"password":{"value":""},"user":{"value":"bow"}}}` | Bundled PostgreSQL (groundhog2k/postgres). For production use an external DB and set `enabled: false`. |
| postgres.nodeSelector | object | `{}` | Node selector for the PostgreSQL pod |
| postgres.settings | object | `{"superuserPassword":{"value":""}}` | PostgreSQL settings (superuser credentials) |
| postgres.storage | object | `{"className":"","requestedSize":"20Gi"}` | Persistent storage for PostgreSQL data |
| postgres.userDatabase | object | `{"name":{"value":"bagofwords"},"password":{"value":""},"user":{"value":"bow"}}` | Application database and user created on first boot |
| readinessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/health","port":3000},"initialDelaySeconds":5,"periodSeconds":10,"timeoutSeconds":5}` | Readiness probe |
| replicaCount | int | `1` | Replica count (ignored when autoscaling.enabled is true) |
| resources | object | `{"limits":{"cpu":"2","memory":"2Gi"},"requests":{"cpu":"1","memory":"1500Mi"}}` | CPU/memory requests and limits for the main container |
| service | object | `{"annotations":{},"port":3000,"type":"ClusterIP"}` | Kubernetes Service configuration |
| serviceAccount | object | `{"annotations":{},"create":true,"imagePullSecret":"","name":"bowapp"}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount (e.g. IRSA role ARN) |
| serviceAccount.create | bool | `true` | Create the ServiceAccount. Set to false to use an existing one. |
| serviceAccount.imagePullSecret | string | `""` | Name of an existing imagePullSecret to attach to the SA. Leave empty to skip. |
| serviceAccount.name | string | `"bowapp"` | ServiceAccount name. Defaults to the release fullname. |
| startupProbe | object | `{"failureThreshold":30,"httpGet":{"path":"/health","port":3000},"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5}` | Startup probe (allows slow first boot — up to 5 minutes) |
| tolerations | list | `[]` | Tolerations for the app pod |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
