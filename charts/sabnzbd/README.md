# SABnzbd

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.1.0](https://img.shields.io/badge/AppVersion-4.1.0-informational?style=flat-square)

A Helm chart for SABnzbd - The automated Usenet download tool

**Homepage:** <https://sabnzbd.org/>

## Description

SABnzbd is an Open Source Binary Newsreader written in Python. It's simple to use, and works practically everywhere. SABnzbd makes Usenet as simple and streamlined as possible by automating everything it can. All you have to do is add a .nzb file. SABnzbd takes over from there, where it will be automatically downloaded, verified, repaired, extracted and filed away with zero human interaction.

This Helm chart deploys SABnzbd on a Kubernetes cluster with optional VPN support through Gluetun sidecar integration.

## Features

- 📥 **Automated Downloads**: Full binary newsreader with automation
- 🔒 **Optional VPN Integration**: Route traffic through Gluetun VPN sidecar
- 📊 **Metrics & Monitoring**: Optional Exportarr sidecar for Prometheus metrics
- 🔧 **Flexible Storage**: Configurable volumes for different content types
- 🚀 **Production Ready**: Health checks, resource management, and security contexts
- 📈 **Monitoring**: Optional Prometheus ServiceMonitor support
- 🌐 ***arr Integration**: Seamless integration with media automation stack

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `sabnzbd`:

```bash
helm repo add truecharts https://charts.truecharts.org/
helm repo update
helm install sabnzbd truecharts/sabnzbd
```

## Uninstalling the Chart

To uninstall/delete the `sabnzbd` deployment:

```bash
helm delete sabnzbd
```

### Install with Monitoring (Exportarr)

```bash
# Install with Prometheus metrics enabled
helm install sabnzbd truecharts/sabnzbd \
  --set exportarr.enabled=true \
  --set exportarr.apiKeySecret.create=true \
  --set exportarr.apiKeySecret.value=your-sabnzbd-api-key \
  --set exportarr.serviceMonitor.enabled=true
```

## Monitoring with Exportarr

This chart includes optional Exportarr integration for comprehensive Prometheus metrics collection.

### Features

- **📊 Download Statistics**: Queue length, download speed, completion rates
- **💾 Storage Metrics**: Disk space usage, download volume statistics
- **🔍 System Health**: Application status, API connectivity, error tracking
- **📈 Historical Data**: Trends and performance analysis over time
- **🚨 Queue Monitoring**: Stuck downloads, failed items, processing status

### Basic Configuration

```yaml
exportarr:
  enabled: true
  
  # API key configuration (use external secret in production)
  apiKeySecret:
    create: true
    value: "your-sabnzbd-api-key"
  
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
    name: "sabnzbd-exportarr"
    key: "api-key"
  
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
kubectl create secret generic sabnzbd-exportarr \
  --from-literal=api-key=your-actual-sabnzbd-api-key

# Then reference it in values
helm install sabnzbd truecharts/sabnzbd \
  --set exportarr.enabled=true \
  --set exportarr.apiKeySecret.name=sabnzbd-exportarr
```

### Available Metrics

Key metrics exposed by the Exportarr exporter:

- `exportarr_up` - Exporter health status
- `sabnzbd_speed_bytes` - Current download speed in bytes/sec
- `sabnzbd_size_left_bytes` - Remaining download size in bytes
- `sabnzbd_queue_total` - Total items in download queue
- `sabnzbd_diskspace_bytes` - Available disk space
- `sabnzbd_version` - SABnzbd version information
- `sabnzbd_status` - Application status

### Grafana Dashboard

Import the official Exportarr dashboard for visualization:
- **Dashboard ID**: 15174
- **URL**: https://grafana.com/grafana/dashboards/15174

## Configuration

The following table lists the configurable parameters of the SABnzbd chart and their default values.

### SABnzbd Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sabnzbd.enabled` | Enable SABnzbd | `true` |
| `sabnzbd.image.repository` | SABnzbd image repository | `linuxserver/sabnzbd` |
| `sabnzbd.image.tag` | SABnzbd image tag | `latest` |
| `sabnzbd.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `sabnzbd.env.PUID` | Process User ID | `1000` |
| `sabnzbd.env.PGID` | Process Group ID | `1000` |
| `sabnzbd.env.TZ` | Timezone | `Europe/London` |
| `sabnzbd.env.HOST` | Host binding | `0.0.0.0` |
| `sabnzbd.env.PORT` | Web interface port | `8080` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sabnzbd.service.type` | Service type | `ClusterIP` |
| `sabnzbd.service.port` | Service port | `8080` |
| `sabnzbd.service.targetPort` | Target port | `8080` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sabnzbd.persistence.config.enabled` | Enable config persistence | `true` |
| `sabnzbd.persistence.config.size` | Config volume size | `2Gi` |
| `sabnzbd.persistence.downloads.enabled` | Enable downloads persistence | `true` |
| `sabnzbd.persistence.downloads.size` | Downloads volume size | `500Gi` |
| `sabnzbd.persistence.incomplete.enabled` | Enable incomplete persistence | `true` |
| `sabnzbd.persistence.incomplete.size` | Incomplete volume size | `100Gi` |
| `sabnzbd.persistence.tv.enabled` | Enable TV persistence | `true` |
| `sabnzbd.persistence.tv.size` | TV volume size | `500Gi` |
| `sabnzbd.persistence.anime.enabled` | Enable anime persistence | `true` |
| `sabnzbd.persistence.anime.size` | Anime volume size | `200Gi` |
| `sabnzbd.persistence.data.enabled` | Enable data persistence | `true` |
| `sabnzbd.persistence.data.size` | Data volume size | `100Gi` |

### VPN Configuration (Gluetun)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.enabled` | Enable Gluetun VPN sidecar | `false` |
| `gluetun.image.repository` | Gluetun image repository | `ghcr.io/qdm12/gluetun` |
| `gluetun.image.tag` | Gluetun image tag | `latest` |
| `gluetun.vpn.pia.enabled` | Enable Private Internet Access | `false` |
| `gluetun.vpn.nordvpn.enabled` | Enable NordVPN | `false` |
| `gluetun.vpn.mullvad.enabled` | Enable Mullvad | `false` |

### Resources Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sabnzbd.resources.limits.cpu` | CPU limit | `2000m` |
| `sabnzbd.resources.limits.memory` | Memory limit | `2Gi` |
| `sabnzbd.resources.requests.cpu` | CPU request | `200m` |
| `sabnzbd.resources.requests.memory` | Memory request | `512Mi` |

## Storage

SABnzbd requires several storage volumes for optimal operation:

### Required Volumes

- **Config** (`/config`): Application configuration and database
- **Downloads** (`/downloads`): Completed downloads
- **Incomplete** (`/incomplete-downloads`): Active downloads

### Optional Volumes

- **TV** (`/tv`): TV show storage for *arr integration
- **Anime** (`/anime`): Anime storage for *arr integration  
- **Data** (`/data`): Shared data with download clients

## VPN Integration

SABnzbd supports optional VPN integration through Gluetun sidecar container. While not strictly required for Usenet (connections are already encrypted), VPN can provide additional privacy.

### Supported VPN Providers

- Private Internet Access (PIA)
- NordVPN (WireGuard)
- Mullvad (WireGuard)

### VPN Configuration Example

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

## Examples

### Basic Installation

```yaml
sabnzbd:
  persistence:
    config:
      size: 5Gi
    downloads:
      size: 1Ti
```

### With VPN Integration

```yaml
sabnzbd:
  env:
    TZ: "America/New_York"

gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "vpn-username"
      password: "vpn-password"
      serverRegions: "US East"
```

### Production Setup

```yaml
sabnzbd:
  resources:
    limits:
      cpu: 4000m
      memory: 4Gi
    requests:
      cpu: 500m
      memory: 1Gi
  
  persistence:
    config:
      storageClass: "fast-ssd"
      size: 10Gi
    downloads:
      storageClass: "bulk-storage"
      size: 2Ti
    incomplete:
      storageClass: "fast-ssd"
      size: 500Gi

serviceMonitor:
  enabled: true
```

## Integration with *arr Applications

SABnzbd integrates seamlessly with the *arr media automation stack:

1. **Sonarr** - TV show automation
2. **Radarr** - Movie automation  
3. **Lidarr** - Music automation
4. **Readarr** - Book automation

Configure each *arr application to use SABnzbd as the download client with the internal service URL: `http://sabnzbd:8080`

## Health Checks

The chart includes health checks for SABnzbd:

- **Liveness Probe**: Ensures SABnzbd is running
- **Readiness Probe**: Ensures SABnzbd is ready to accept requests

## Security

- Runs as non-root user (UID/GID 1000)
- Security contexts applied
- Optional network policies for *arr integration
- VPN credentials stored in Kubernetes secrets

## Monitoring

Optional Prometheus ServiceMonitor for metrics collection:

```yaml
serviceMonitor:
  enabled: true
  interval: "30s"
  path: "/api/v1/stats"
```

## Troubleshooting

### Common Issues

1. **Permission Issues**: Ensure PUID/PGID match your storage permissions
2. **VPN Connection**: Check Gluetun logs for VPN connectivity issues
3. **Storage**: Verify PVC creation and mounting

### Useful Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=sabnzbd

# View logs
kubectl logs -l app.kubernetes.io/name=sabnzbd -c sabnzbd

# Check VPN logs (if enabled)
kubectl logs -l app.kubernetes.io/name=sabnzbd -c gluetun

# Port forward for testing
kubectl port-forward svc/sabnzbd 8080:8080
```

## Values Files

The chart includes example values files:

- `examples/values-basic.yaml` - Basic configuration
- `examples/values-vpn.yaml` - With VPN integration
- `examples/values-production.yaml` - Production setup

## Contributing

Please see the main repository for contribution guidelines.

## License

This chart is licensed under the Apache 2.0 License.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Michael Leer | <michael@leer.dev> |  |

## Sources

- <https://sabnzbd.org/>
- <https://github.com/sabnzbd/sabnzbd>
- <https://github.com/linuxserver/docker-sabnzbd>
- <https://github.com/qdm12/gluetun>