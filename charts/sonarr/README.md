# Sonarr Helm Chart

A Helm chart for deploying Sonarr - Smart PVR for newsgroup and bittorrent users - with optional VPN (Gluetun) and Cloudflare tunnel integration.

## Features

- 🎬 **Sonarr** - Smart PVR for TV shows and anime
- 🔒 **Optional VPN Integration** - Route traffic through Gluetun VPN sidecar
- 📊 **Metrics & Monitoring** - Optional Exportarr sidecar for Prometheus metrics
- 💾 **Persistent Storage** - Configurable storage for config, downloads, and media
- 🏠 **Homepage Integration** - Ready for homepage dashboard widgets
- 🔐 **Security** - Network policies, proper security contexts, and secret management
- 🎛️ **Flexible Configuration** - Extensive customization options

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)

## Installation

### Quick Start

```bash
# Add the helm repository (replace with actual repo)
helm repo add your-charts https://your-charts.example.com
helm repo update

# Install with default configuration
helm install sonarr your-charts/sonarr
```

### Install with VPN (Gluetun)

```bash
# Create values file for VPN configuration
cat <<EOF > sonarr-vpn-values.yaml
gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-vpn-username"
      password: "your-vpn-password"
      serverRegions: "UK London"
EOF

# Install with VPN
helm install sonarr your-charts/sonarr -f sonarr-vpn-values.yaml
```

### Install with Monitoring (Exportarr)

```bash
# Install with Prometheus metrics enabled
helm install sonarr your-charts/sonarr \
  --set exportarr.enabled=true \
  --set exportarr.apiKeySecret.create=true \
  --set exportarr.apiKeySecret.value=your-sonarr-api-key \
  --set exportarr.serviceMonitor.enabled=true
```

## Monitoring with Exportarr

This chart includes optional Exportarr integration for comprehensive Prometheus metrics collection.

### Features

- **📊 Download Statistics**: Queue length, download speed, completion rates
- **📚 Library Metrics**: Total series, monitored series, missing episodes
- **🔍 Quality Profiles**: Cutoff unmet, quality statistics
- **🚨 System Health**: Application status, disk space, API connectivity
- **📈 Historical Data**: Trends and performance analysis over time

### Basic Configuration

```yaml
exportarr:
  enabled: true
  
  # API key configuration (use external secret in production)
  apiKeySecret:
    create: true
    value: "your-sonarr-api-key"
  
  # Prometheus integration
  serviceMonitor:
    enabled: true
    labels:
      release: prometheus  # Match your Prometheus operator labels
```

### Production Configuration

```yaml
exportarr:
  enabled: true
  
  # Use external secret (recommended)
  apiKeySecret:
    name: "sonarr-exportarr"
    key: "api-key"
    
  # Enhanced metrics
  env:
    ENABLE_ADDITIONAL_METRICS: "true"
    ENABLE_UNKNOWN_QUEUE_ITEMS: "true"
  
  # Prometheus integration
  serviceMonitor:
    enabled: true
    interval: "4m"
    scrapeTimeout: "90s"
    labels:
      app.kubernetes.io/component: monitoring
      release: prometheus
```

### Creating External API Key Secret

```bash
# Create secret externally (recommended for production)
kubectl create secret generic sonarr-exportarr \
  --from-literal=api-key=your-actual-sonarr-api-key

# Then reference it in values
helm install sonarr your-charts/sonarr \
  --set exportarr.enabled=true \
  --set exportarr.apiKeySecret.name=sonarr-exportarr
```

### Available Metrics

Key metrics exposed by the Exportarr exporter:

- `exportarr_up` - Exporter health status
- `sonarr_series_total` - Total number of series
- `sonarr_series_monitored` - Number of monitored series
- `sonarr_episodes_missing` - Missing episodes count
- `sonarr_queue_total` - Total items in download queue
- `sonarr_queue_downloading` - Currently downloading items
- `sonarr_system_status` - Application health status

### Grafana Dashboard

Import the official Exportarr dashboard for visualization:
- **Dashboard ID**: 15174
- **URL**: https://grafana.com/grafana/dashboards/15174

```

### Complete Installation with VPN

```bash
# Create comprehensive values file
cat <<EOF > sonarr-complete-values.yaml
sonarr:
  persistence:
    config:
      size: 2Gi
    downloads:
      size: 100Gi
    tv:
      size: 1Ti
    anime:
      size: 500Gi

gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-vpn-username"
      password: "your-vpn-password"
      serverRegions: "UK London"

sonarr:
  ingress:
    enabled: true  # Configure as needed
  homepage:
    enabled: true
    widget:
      key: "your-sonarr-api-key"
EOF

# Install complete setup
helm install sonarr your-charts/sonarr -f sonarr-complete-values.yaml
```

## Configuration

### Core Sonarr Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sonarr.enabled` | Enable Sonarr deployment | `true` |
| `sonarr.image.repository` | Sonarr image repository | `linuxserver/sonarr` |
| `sonarr.image.tag` | Sonarr image tag | `latest` |
| `sonarr.env.PUID` | Process User ID | `1000` |
| `sonarr.env.PGID` | Process Group ID | `1000` |
| `sonarr.env.TZ` | Timezone | `Europe/London` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sonarr.service.type` | Service type | `ClusterIP` |
| `sonarr.service.port` | Service port | `8989` |
| `sonarr.service.targetPort` | Target port | `8989` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sonarr.persistence.config.enabled` | Enable config persistence | `true` |
| `sonarr.persistence.config.size` | Config volume size | `1Gi` |
| `sonarr.persistence.downloads.enabled` | Enable downloads persistence | `true` |
| `sonarr.persistence.downloads.size` | Downloads volume size | `50Gi` |
| `sonarr.persistence.tv.enabled` | Enable TV persistence | `true` |
| `sonarr.persistence.tv.size` | TV volume size | `500Gi` |
| `sonarr.persistence.anime.enabled` | Enable anime persistence | `true` |
| `sonarr.persistence.anime.size` | Anime volume size | `200Gi` |

### VPN Configuration (Gluetun)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.enabled` | Enable Gluetun VPN sidecar | `false` |
| `gluetun.image.repository` | Gluetun image | `ghcr.io/qdm12/gluetun` |
| `gluetun.env.VPN_PORT_FORWARDING` | Enable port forwarding | `on` |
| `gluetun.vpn.pia.enabled` | Enable PIA VPN | `true` |
| `gluetun.vpn.pia.username` | PIA username | `""` |
| `gluetun.vpn.pia.password` | PIA password | `""` |
| `gluetun.vpn.pia.serverRegions` | PIA server regions | `UK London` |



### Homepage Integration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sonarr.homepage.enabled` | Enable homepage labels | `true` |
| `sonarr.homepage.group` | Homepage group | `Media` |
| `sonarr.homepage.widget.type` | Widget type | `sonarr` |
| `sonarr.homepage.widget.key` | API key for widget | `""` |

## VPN Providers

### Private Internet Access (PIA)

```yaml
gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-username"
      password: "your-password"
      serverRegions: "UK London"
```

### NordVPN

```yaml
gluetun:
  enabled: true
  vpn:
    nordvpn:
      enabled: true
      privateKey: "your-wireguard-private-key"
```

### Mullvad

```yaml
gluetun:
  enabled: true
  vpn:
    mullvad:
      enabled: true
      privateKey: "your-wireguard-private-key"
      addresses: "10.66.212.252/32"
      serverCities: "London"
```

## Storage Examples

### NFS Storage

```yaml
sonarr:
  persistence:
    config:
      storageClass: "nfs-client"
      size: 2Gi
    downloads:
      storageClass: "nfs-client"
      size: 100Gi
    tv:
      storageClass: "nfs-client"
      size: 2Ti
```

### Local Storage

```yaml
sonarr:
  persistence:
    config:
      storageClass: "local-path"
      size: 1Gi
    tv:
      storageClass: "local-path"
      size: 1Ti
```

## Ingress Examples

### NGINX Ingress

```yaml
sonarr:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    hosts:
      - host: sonarr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: sonarr-tls
        hosts:
          - sonarr.example.com
```

### Traefik Ingress

```yaml
sonarr:
  ingress:
    enabled: true
    className: "traefik"
    annotations:
      traefik.ingress.kubernetes.io/router.tls: "true"
    hosts:
      - host: sonarr.example.com
        paths:
          - path: /
            pathType: Prefix
```

## Security

### Network Policies

```yaml
networkPolicy:
  enabled: true
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: homepage
      ports:
        - protocol: TCP
          port: 8989
  egress:
    - to: []
      ports:
        - protocol: TCP
          port: 443
```

### Security Contexts

The chart automatically configures security contexts:
- Runs as non-root user (UID 1000)
- Proper filesystem permissions
- Gluetun gets NET_ADMIN capability for VPN

## Monitoring and Health Checks

The chart includes:
- Liveness probes (HTTP GET to Sonarr web interface)
- Readiness probes (HTTP GET to Sonarr web interface)
- Resource limits and requests

## Upgrading

### Upgrade Chart Version

```bash
helm repo update
helm upgrade sonarr your-charts/sonarr
```

### Upgrade with New Values

```bash
helm upgrade sonarr your-charts/sonarr -f new-values.yaml
```

### Backup Before Upgrade

```bash
# Backup config
kubectl cp default/sonarr-pod:/config ./sonarr-config-backup

# Upgrade
helm upgrade sonarr your-charts/sonarr
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=sonarr
kubectl describe pod <pod-name>
```

### View Logs

```bash
# Sonarr logs
kubectl logs <pod-name> -c sonarr

# Gluetun logs (if enabled)
kubectl logs <pod-name> -c gluetun

# Cloudflared logs (if enabled)
kubectl logs <pod-name> -c cloudflared
```

### Test VPN Connection

```bash
# Port forward to gluetun control interface
kubectl port-forward <pod-name> 8000:8000

# Check VPN status
curl http://localhost:8000/v1/openvpn/status
```

### Access Sonarr Shell

```bash
kubectl exec -it <pod-name> -c sonarr -- /bin/bash
```

### Common Issues

1. **VPN Not Connecting**: Check credentials in secrets
2. **Storage Issues**: Verify PVC creation and storage class
3. **Permission Issues**: Check PUID/PGID settings
4. **Network Issues**: Verify network policies if enabled

## Uninstalling

```bash
# Uninstall the release
helm uninstall sonarr

# Clean up PVCs (if needed)
kubectl delete pvc -l app.kubernetes.io/name=sonarr
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint` and `helm template`
5. Submit a pull request

## License

This chart is licensed under the Apache License 2.0.

## Links

- [Sonarr Documentation](https://wiki.servarr.com/sonarr)
- [Gluetun Documentation](https://github.com/qdm12/gluetun)
- [Kubernetes Documentation](https://kubernetes.io/docs/)