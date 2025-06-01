# Karma Helm Chart

This Helm chart deploys Karma to Kubernetes.

## Installation

```bash
helm install karma ./karma
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `nginx` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag | `""` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `false` |
| `resources` | Resource limits and requests | `{}` |
| `autoscaling.enabled` | Enable autoscaling | `false` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity | `{}` |

## Values

Configure the chart by creating a `values.yaml` file:

```yaml
replicaCount: 2

image:
  repository: your-karma-image
  tag: "latest"

service:
  type: LoadBalancer
  port: 8080

ingress:
  enabled: true
  hosts:
    - host: karma.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Uninstallation

```bash
helm uninstall karma
```