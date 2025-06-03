# Prowlarr

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.21.2](https://img.shields.io/badge/AppVersion-1.21.2-informational?style=flat-square)

A Helm chart for Prowlarr - Indexer manager for *arr applications

**Homepage:** <https://prowlarr.com/>

## Description

Prowlarr is an indexer manager/proxy built on the popular *arr .net/reactjs base stack to integrate with your various PVR apps. Prowlarr supports both Torrent Trackers and Usenet Indexers. It integrates seamlessly with Sonarr, Radarr, Lidarr, and Readarr offering complete management of your indexers with no per app Indexer setup required (we do it all).

This Helm chart deploys Prowlarr on a Kubernetes cluster with optional VPN support through Gluetun sidecar integration.

## Features

- 🔍 **Indexer Management**: Centralized management of indexers for all *arr applications
- 🔒 **Optional VPN Integration**: Route indexer traffic through Gluetun VPN sidecar
- 📊 **Homepage Integration**: Built-in support for Homepage dashboard
- 🔧 **Lightweight Storage**: Only requires configuration and cache storage
- 🚀 **Production Ready**: Health checks, resource management, and security contexts
- 📈 **Monitoring**: Optional Prometheus ServiceMonitor support
- 🌐 **Proxy Server**: Acts as a proxy between your apps and indexers

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `prowlarr`:

```bash
helm install prowlarr ./charts/incubator/prowlarr
```

To install with custom values:

```bash
helm install prowlarr ./charts/incubator/prowlarr -f my-values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `prowlarr` deployment:

```bash
helm delete prowlarr
```

## Configuration

### Basic Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `prowlarr.enabled` | Enable Prowlarr | `true` |
| `prowlarr.image.repository` | Prowlarr image repository | `lscr.io/linuxserver/prowlarr` |
| `prowlarr.image.tag` | Prowlarr image tag | `latest` |
| `prowlarr.service.port` | Service port | `9696` |
| `prowlarr.env.PUID` | Process User ID | `1000` |
| `prowlarr.env.PGID` | Process Group ID | `1000` |
| `prowlarr.env.TZ` | Timezone | `Europe/London` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `prowlarr.persistence.config.enabled` | Enable config persistence | `true` |
| `prowlarr.persistence.config.size` | Config volume size | `2Gi` |
| `prowlarr.persistence.data.enabled` | Enable data persistence | `true` |
| `prowlarr.persistence.data.size` | Data volume size | `5Gi` |

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

This chart supports optional VPN integration using Gluetun as a sidecar container. VPN integration is particularly important for Prowlarr as it directly accesses indexers and trackers.

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
helm install prowlarr ./charts/incubator/prowlarr -f values-vpn-pia.yaml
```

## Examples

### Basic Installation

```yaml
# values-basic.yaml
prowlarr:
  persistence:
    config:
      size: 5Gi
    data:
      size: 10Gi
```

### With Custom Storage Classes

```yaml
# values-storage.yaml
prowlarr:
  persistence:
    config:
      storageClass: "fast-ssd"
      size: 5Gi
    data:
      storageClass: "fast-ssd"
      size: 10Gi
```

### With Homepage Integration

```yaml
# values-homepage.yaml
prowlarr:
  homepage:
    enabled: true
    group: "Media"
    name: "Prowlarr"
    description: "Indexer Manager"
    widget:
      type: "prowlarr"
      url: "http://prowlarr:9696"
      key: "your-api-key-here"
```

### Production Configuration

```yaml
# values-production.yaml
prowlarr:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 200m
      memory: 512Mi

  persistence:
    config:
      storageClass: "fast-ssd"
      size: 10Gi
    data:
      storageClass: "fast-ssd"
      size: 20Gi

  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: basic-auth
    hosts:
      - host: prowlarr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: prowlarr-tls
        hosts:
          - prowlarr.example.com

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

## Integration with *arr Apps

Prowlarr acts as a centralized indexer manager for your *arr applications. Once configured, it can automatically sync indexers to:

- **Sonarr** (TV Shows)
- **Radarr** (Movies)
- **Lidarr** (Music)
- **Readarr** (Books/Audiobooks)

### Configuration Steps

1. Deploy Prowlarr using this chart
2. Access the Prowlarr web interface
3. Add your indexers in Prowlarr
4. Configure applications in Prowlarr (add your *arr apps)
5. Prowlarr will automatically sync indexers to all configured applications

### Network Considerations

If using VPN with Prowlarr, ensure your other *arr applications can reach Prowlarr:

```yaml
# Example network policy to allow *arr apps to reach Prowlarr
networkPolicy:
  enabled: true
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: media
      ports:
        - protocol: TCP
          port: 9696
```

## Troubleshooting

### Common Issues

1. **Indexer connectivity issues**
   - Verify VPN connection if enabled
   - Check Gluetun container logs: `kubectl logs <pod-name> -c gluetun`
   - Test indexer accessibility from within the pod

2. **Application sync failures**
   - Verify API keys are correct in Prowlarr
   - Check network connectivity between Prowlarr and *arr apps
   - Ensure applications are reachable from Prowlarr pod

3. **VPN connection problems**
   - Verify VPN credentials are correct
   - Check if VPN provider servers are accessible
   - Ensure NET_ADMIN capability is available

4. **Performance issues**
   - Increase memory limits for large indexer lists
   - Use faster storage for config and data volumes
   - Monitor resource usage

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=prowlarr

# View pod logs
kubectl logs -l app.kubernetes.io/name=prowlarr -f

# Check VPN logs specifically
kubectl logs <pod-name> -c gluetun

# Test indexer connectivity from pod
kubectl exec -it <pod-name> -c prowlarr -- wget -O - https://example-indexer.com

# Check PVC status
kubectl get pvc | grep prowlarr
```

### Performance Tuning

For environments with many indexers:

- Increase memory limits (`1Gi` or more)
- Use SSD storage for better I/O performance
- Consider increasing CPU limits during indexer refresh operations
- Monitor network bandwidth usage

## Security Considerations

- Store VPN credentials in Kubernetes secrets
- Use network policies to restrict access to indexers
- Enable Pod Security Standards
- Regularly update container images
- Use HTTPS/TLS for indexer communications
- Consider using a dedicated namespace for media applications

## API Access

Prowlarr provides a REST API for integration with other applications. The API key can be found in the Prowlarr web interface under Settings > General.

### Common API Endpoints

- `/api/v1/indexer` - Manage indexers
- `/api/v1/indexerstats` - Indexer statistics
- `/api/v1/application` - Manage connected applications
- `/api/v1/system/status` - System status

## Contributing

Please read our [Contributing Guide](../../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## Maintainers

| Name | Email |
| ---- | ------ |
| Michael Leer | <michael@leer.dev> |

## Source Code

* <https://github.com/Prowlarr/Prowlarr>
* <https://github.com/linuxserver/docker-prowlarr>