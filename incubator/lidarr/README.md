# Lidarr

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.4.3](https://img.shields.io/badge/AppVersion-2.4.3-informational?style=flat-square)

A Helm chart for Lidarr - Smart PVR for music collection automation

**Homepage:** <https://lidarr.audio/>

## Description

Lidarr is a music collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new albums from your favorite artists and will grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in your library when a better quality format becomes available.

This Helm chart deploys Lidarr on a Kubernetes cluster with optional VPN support through Gluetun sidecar integration.

## Features

- 🎵 **Smart Music Management**: Automatically download and organize your music collection
- 🔒 **Optional VPN Integration**: Route traffic through Gluetun VPN sidecar
- 📊 **Homepage Integration**: Built-in support for Homepage dashboard
- 🔧 **Flexible Storage**: Configurable persistent volumes for different content types
- 🚀 **Production Ready**: Health checks, resource management, and security contexts
- 📈 **Monitoring**: Optional Prometheus ServiceMonitor support

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `lidarr`:

```bash
helm install lidarr ./charts/incubator/lidarr
```

To install with custom values:

```bash
helm install lidarr ./charts/incubator/lidarr -f my-values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `lidarr` deployment:

```bash
helm delete lidarr
```

## Configuration

### Basic Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `lidarr.enabled` | Enable Lidarr | `true` |
| `lidarr.image.repository` | Lidarr image repository | `linuxserver/lidarr` |
| `lidarr.image.tag` | Lidarr image tag | `latest` |
| `lidarr.service.port` | Service port | `8686` |
| `lidarr.env.PUID` | Process User ID | `1000` |
| `lidarr.env.PGID` | Process Group ID | `1000` |
| `lidarr.env.TZ` | Timezone | `Europe/London` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `lidarr.persistence.config.enabled` | Enable config persistence | `true` |
| `lidarr.persistence.config.size` | Config volume size | `1Gi` |
| `lidarr.persistence.downloads.enabled` | Enable downloads persistence | `true` |
| `lidarr.persistence.downloads.size` | Downloads volume size | `50Gi` |
| `lidarr.persistence.music.enabled` | Enable music persistence | `true` |
| `lidarr.persistence.music.size` | Music volume size | `1000Gi` |
| `lidarr.persistence.data.enabled` | Enable data persistence | `true` |
| `lidarr.persistence.data.size` | Data volume size | `100Gi` |

### VPN Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.enabled` | Enable Gluetun VPN sidecar | `false` |
| `gluetun.image.repository` | Gluetun image repository | `ghcr.io/qdm12/gluetun` |
| `gluetun.vpn.pia.enabled` | Enable Private Internet Access | `true` |
| `gluetun.vpn.pia.username` | PIA username (store in secret) | `""` |
| `gluetun.vpn.pia.password` | PIA password (store in secret) | `""` |
| `gluetun.vpn.pia.serverRegions` | PIA server regions | `UK London` |

## VPN Integration

This chart supports optional VPN integration using Gluetun as a sidecar container. When enabled, all Lidarr traffic will be routed through the VPN.

### Supported VPN Providers

- **Private Internet Access (PIA)** - OpenVPN
- **NordVPN** - WireGuard
- **Mullvad** - WireGuard

### Enabling VPN

Create a values file with your VPN credentials:

```yaml
# values-vpn-pia.yaml
gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-pia-username"
      password: "your-pia-password"
      serverRegions: "UK London"
```

Install with VPN enabled:

```bash
helm install lidarr ./charts/incubator/lidarr -f values-vpn-pia.yaml
```

## Examples

### Basic Installation

```yaml
# values-basic.yaml
lidarr:
  persistence:
    music:
      size: 2Ti
    downloads:
      size: 100Gi
```

### With Custom Storage Classes

```yaml
# values-storage.yaml
lidarr:
  persistence:
    config:
      storageClass: "fast-ssd"
      size: 5Gi
    music:
      storageClass: "large-hdd"
      size: 5Ti
    downloads:
      storageClass: "fast-ssd"
      size: 200Gi
```

### With Homepage Integration

```yaml
# values-homepage.yaml
lidarr:
  homepage:
    enabled: true
    group: "Media"
    name: "Lidarr"
    description: "Music Manager"
    widget:
      type: "lidarr"
      url: "http://lidarr:8686"
      key: "your-api-key-here"
```

### Production Configuration

```yaml
# values-production.yaml
lidarr:
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 512Mi

  persistence:
    config:
      storageClass: "fast-ssd"
      size: 5Gi
    music:
      storageClass: "large-hdd" 
      size: 10Ti
    downloads:
      storageClass: "fast-ssd"
      size: 500Gi

  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: basic-auth
    hosts:
      - host: lidarr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: lidarr-tls
        hosts:
          - lidarr.example.com

gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-username"
      password: "your-password"
      serverRegions: "UK London"

serviceMonitor:
  enabled: true

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

## Troubleshooting

### Common Issues

1. **Pod stuck in pending state**
   - Check if PersistentVolumeClaims are bound
   - Verify storage class exists and has available capacity

2. **VPN connection issues**
   - Verify VPN credentials are correct
   - Check Gluetun container logs: `kubectl logs <pod-name> -c gluetun`
   - Ensure NET_ADMIN capability is available in your cluster

3. **Permission issues**
   - Verify PUID/PGID settings match your storage permissions
   - Check if security context is properly configured

4. **Network connectivity**
   - If using VPN, verify the VPN connection is established
   - Check if indexers are accessible through the VPN

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=lidarr

# View pod logs
kubectl logs -l app.kubernetes.io/name=lidarr -f

# Check VPN logs specifically
kubectl logs <pod-name> -c gluetun

# Describe pod for events
kubectl describe pod <pod-name>

# Check PVC status
kubectl get pvc | grep lidarr
```

### Performance Tuning

For large music libraries, consider:

- Increasing memory limits
- Using faster storage classes for the database
- Enabling resource requests to guarantee CPU/memory
- Using node affinity to place pods on high-performance nodes

## Security Considerations

### Security Context

The chart implements secure defaults:
- Runs as non-root user (UID 1000)
- Proper filesystem permissions (fsGroup: 1000)
- No privilege escalation
- Capabilities properly managed (NET_ADMIN only for VPN sidecar)

### Resource Management

Default resource limits and requests are configured:
```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 256Mi
```

Adjust these based on your music library size and indexing needs.

### Best Practices

- Store VPN credentials in Kubernetes secrets
- Use network policies to restrict traffic
- Enable Pod Security Standards
- Regularly update container images
- Use read-only root filesystem where possible
- Enable ServiceMonitor for monitoring
- Configure PodDisruptionBudget for high availability

## Contributing

Please read our [Contributing Guide](../../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## Maintainers

| Name | Email |
| ---- | ------ |
| Michael Leer | <michael@leer.dev> |

## Source Code

* <https://github.com/Lidarr/Lidarr>
* <https://github.com/linuxserver/docker-lidarr>