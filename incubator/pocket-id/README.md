# PocketID

A Helm chart for [PocketID](https://github.com/pocket-id/pocket-id) - A simple, secure, and self-hostable auth provider.

## Introduction

PocketID is a lightweight, self-hosted authentication provider that supports OAuth2/OIDC protocols. This chart deploys PocketID on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for data persistence)

## Installing the Chart

To install the chart with the release name `pocket-id`:

```bash
helm install pocket-id ./pocket-id
```

## Configuration

The following table lists the configurable parameters of the PocketID chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/pocket-id/pocket-id` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |
| `podSecurityContext.fsGroup` | Pod security context fsGroup | `2000` |
| `securityContext.runAsNonRoot` | Run container as non-root | `true` |
| `securityContext.runAsUser` | User ID to run container | `1000` |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `securityContext.capabilities.drop` | Linux capabilities to drop | `["ALL"]` |
| `securityContext.readOnlyRootFilesystem` | Read-only root filesystem | `false` |
| `securityContext.seccompProfile.type` | Seccomp profile type | `RuntimeDefault` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `1411` |
| `env` | Environment variables | `[]` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.ingressClassName` | Ingress class name | `nginx` |
| `ingress.annotations` | Ingress annotations | `{"cert-manager.io/cluster-issuer": "letsencrypt"}` |
| `ingress.host` | Ingress hostname | `pocketauth.almultitonedevelopment.com` |
| `ingress.paths` | Ingress paths | `[{path: "/", pathType: "ImplementationSpecific"}]` |
| `ingress.tls.enabled` | Enable TLS | `true` |
| `ingress.tls.secretName` | TLS secret name | `pocket-id-tls` |
| `storage.storageClassName` | Storage class name | `gp2` |
| `storage.size` | Storage size | `2Gi` |
| `resources.limits.cpu` | CPU limit | `200m` |
| `resources.limits.memory` | Memory limit | `256Mi` |
| `resources.requests.cpu` | CPU request | `50m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity | `{}` |
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `podDisruptionBudget.maxUnavailable` | Max unavailable pods | `1` |
| `healthCheck.livenessProbe.enabled` | Enable liveness probe | `true` |
| `healthCheck.livenessProbe.path` | Liveness probe path | `/healthz` |
| `healthCheck.livenessProbe.initialDelaySeconds` | Liveness probe initial delay | `10` |
| `healthCheck.livenessProbe.periodSeconds` | Liveness probe period | `90` |
| `healthCheck.readinessProbe.enabled` | Enable readiness probe | `true` |
| `healthCheck.readinessProbe.path` | Readiness probe path | `/healthz` |
| `healthCheck.readinessProbe.initialDelaySeconds` | Readiness probe initial delay | `10` |
| `healthCheck.readinessProbe.periodSeconds` | Readiness probe period | `30` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |
| `networkPolicy.ingressControllerNamespace` | Ingress controller namespace | `ingress-nginx` |

### Common Environment Variables

PocketID supports several environment variables for configuration:

| Variable | Description | Example |
|----------|-------------|---------|
| `PUBLIC_APP_URL` | Public URL of PocketID instance | `https://auth.example.com` |
| `TRUST_PROXY` | Trust proxy headers | `true` |
| `DATABASE_URL` | Database connection URL | `sqlite:///app/data/pocket-id.db` |
| `JWT_SECRET` | Secret for JWT tokens | `your-secret-key` |
| `ADMIN_USERNAME` | Initial admin username | `admin` |
| `ADMIN_PASSWORD` | Initial admin password | `secure-password` |

Example configuration with environment variables:

```yaml
env:
  - name: ADMIN_USERNAME
    value: "admin"
  - name: ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: pocket-id-secrets
        key: admin-password
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: pocket-id-secrets
        key: jwt-secret
```

## Security

This chart implements several security best practices:

### Security Context

The chart runs containers with a non-root user (UID 1000) and implements the following security measures:
- No privilege escalation allowed
- All Linux capabilities dropped
- Seccomp profile set to RuntimeDefault
- File system group set to 2000

### Resource Limits

Default resource limits and requests are configured to ensure stable operation:
- CPU: 200m limit / 50m request
- Memory: 256Mi limit / 128Mi request

These can be adjusted based on your workload requirements.

### Network Policies

Network policies can be enabled to restrict traffic:

```yaml
networkPolicy:
  enabled: true
  ingressControllerNamespace: ingress-nginx
```

## Persistence

PocketID stores its data in a SQLite database. This chart creates a PersistentVolumeClaim to ensure data persistence across pod restarts.

## Upgrading

To upgrade the chart:

```bash
helm upgrade pocket-id ./pocket-id
```

## Uninstalling

To uninstall/delete the deployment:

```bash
helm uninstall pocket-id
```

This command removes all the Kubernetes components associated with the chart but keeps the PersistentVolumeClaim to prevent data loss. To fully remove all data:

```bash
kubectl delete pvc pocket-id-data
```

## Support

For issues related to:
- Chart: Open an issue in this repository
- PocketID: Visit [PocketID GitHub](https://github.com/pocket-id/pocket-id)