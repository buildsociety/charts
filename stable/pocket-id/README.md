# PocketID Helm Chart (Stable)

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 20.07.2](https://img.shields.io/badge/AppVersion-20.07.2-informational?style=flat-square)

## Description

A Helm chart for PocketID - A simple, secure, and self-hostable authentication provider

> **Note**: This is the stable version of the PocketID chart. For the latest features and updates, consider using the incubator version at `incubator/pocket-id`.

## Features

🔐 **Simple Authentication** - Easy-to-use authentication provider for your applications  
🏠 **Self-Hostable** - Complete control over your authentication infrastructure  
🔒 **Secure by Design** - Built with security best practices in mind  
🚀 **Lightweight** - Minimal resource footprint for efficient operation  
🎯 **Kubernetes Native** - Designed for cloud-native deployments  

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for data persistence)

## Installation

### Add the Helm repository

```bash
helm repo add trozz https://trozz.github.io/charts
helm repo update
```

### Install the chart

```bash
helm install pocket-id trozz/pocket-id --namespace pocket-id --create-namespace
```

### Install with custom values

```bash
helm install pocket-id trozz/pocket-id -f values.yaml --namespace pocket-id --create-namespace
```

## Configuration

The following table lists the configurable parameters of the PocketID chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of PocketID replicas | `1` |
| `image.repository` | PocketID image repository | `stonith404/pocket-id` |
| `image.tag` | PocketID image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full chart name | `""` |
| `podSecurityContext.fsGroup` | Pod security context fsGroup | `2000` |
| `securityContext` | Container security context | See values.yaml |
| `service.type` | Service type | `ClusterIP` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.ingressClassName` | Ingress class name | `nginx` |
| `ingress.annotations` | Ingress annotations | `{"cert-manager.io/cluster-issuer": "letsencrypt"}` |
| `ingress.host` | Ingress hostname | `pocketauth.almultitonedevelopment.com` |
| `ingress.paths` | Ingress paths | `[{path: "/", pathType: "ImplementationSpecific"}]` |
| `ingress.tls.enabled` | Enable TLS | `true` |
| `ingress.tls.secretName` | TLS secret name | `pocket-id-tls` |
| `storage.storageClassName` | Storage class name | `gp2` |
| `storage.size` | Storage size | `2Gi` |
| `resources` | Resource limits and requests | `{}` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity | `{}` |

## Examples

### Basic Installation

```yaml
# values-basic.yaml
replicaCount: 1

image:
  repository: stonith404/pocket-id
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP

ingress:
  enabled: false

storage:
  size: 1Gi
```

### Production Setup

```yaml
# values-production.yaml
replicaCount: 2

image:
  repository: stonith404/pocket-id
  tag: v1.0.0  # Use specific version in production
  pullPolicy: IfNotPresent

ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  host: auth.yourdomain.com
  tls:
    enabled: true
    secretName: pocket-id-tls

storage:
  storageClassName: fast-ssd
  size: 10Gi

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### External Database Configuration

```yaml
# values-external-db.yaml
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: pocket-id-db-secret
        key: connection-string
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: pocket-id-secrets
        key: jwt-secret

storage:
  # Can be reduced when using external database
  size: 500Mi
```

## Persistence

PocketID stores its data in a persistent volume. By default, a PersistentVolumeClaim is created and mounted for data storage.

### Storage Configuration

```yaml
storage:
  storageClassName: your-storage-class
  size: 5Gi
```

## Security Considerations

1. **Secrets Management**: Always use Kubernetes secrets for sensitive configuration
2. **Network Policies**: Consider implementing network policies to restrict traffic
3. **TLS**: Always use TLS in production environments
4. **Security Context**: The default security context runs as non-root user with read-only root filesystem

### Creating Secrets

```bash
# Create database secret
kubectl create secret generic pocket-id-db-secret \
  --from-literal=connection-string='postgresql://user:pass@host:5432/db' \
  -n pocket-id

# Create JWT secret
kubectl create secret generic pocket-id-secrets \
  --from-literal=jwt-secret='your-secure-jwt-secret' \
  -n pocket-id
```

## Monitoring

### Health Checks

Configure liveness and readiness probes in your deployment:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Troubleshooting

### Common Issues

1. **Pod fails to start**
   - Check logs: `kubectl logs -l app.kubernetes.io/name=pocket-id -n pocket-id`
   - Verify storage is provisioned: `kubectl get pvc -n pocket-id`
   - Check secrets are created: `kubectl get secrets -n pocket-id`

2. **Cannot access the application**
   - Verify ingress configuration: `kubectl describe ingress -n pocket-id`
   - Check service endpoints: `kubectl get endpoints -n pocket-id`
   - Test service connectivity: `kubectl port-forward svc/pocket-id 8080:80 -n pocket-id`

3. **Storage issues**
   - Verify StorageClass exists: `kubectl get storageclass`
   - Check PVC status: `kubectl describe pvc -n pocket-id`

## Backup and Recovery

### Backup PocketID Data

```bash
# Create a backup pod
kubectl run pocket-id-backup --image=busybox --restart=Never --rm -it -- \
  tar czf /backup/pocket-id-backup-$(date +%Y%m%d).tar.gz /data

# Copy backup locally
kubectl cp pocket-id-backup:/backup/pocket-id-backup-*.tar.gz ./backups/
```

## Migration from Incubator

If you're migrating from the incubator version:

1. Backup your data
2. Note any custom configurations
3. Uninstall the incubator version
4. Install the stable version with your custom values
5. Restore data if needed

## Upgrading

### To upgrade the chart:

```bash
helm upgrade pocket-id trozz/pocket-id -n pocket-id
```

### To upgrade with new values:

```bash
helm upgrade pocket-id trozz/pocket-id -f values.yaml -n pocket-id
```

## Uninstallation

To uninstall/delete the deployment:

```bash
helm uninstall pocket-id -n pocket-id
```

To delete all resources including PVCs:

```bash
helm uninstall pocket-id -n pocket-id
kubectl delete pvc -l app.kubernetes.io/name=pocket-id -n pocket-id
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This Helm chart is distributed under the MIT License.

## Links

- [PocketID GitHub Repository](https://github.com/stonith404/pocket-id/)
- [Chart Repository](https://github.com/trozz/charts)
- [Helm Documentation](https://helm.sh/docs/)