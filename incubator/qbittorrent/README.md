# qBittorrent

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.6.4](https://img.shields.io/badge/AppVersion-4.6.4-informational?style=flat-square)

A Helm chart for qBittorrent - BitTorrent client with web UI

**Homepage:** <https://www.qbittorrent.org/>

## Description

qBittorrent is a cross-platform free and open-source BitTorrent client. It provides a native web UI for remote access and integrates seamlessly with *arr applications for automated media downloading. This implementation uses the LinuxServer.io container which provides excellent performance and stability.

This Helm chart deploys qBittorrent on a Kubernetes cluster with **strong emphasis on VPN integration** through Gluetun sidecar for privacy and security.

## Features

- 🔒 **VPN Integration**: Built-in Gluetun VPN sidecar support (highly recommended)
- 📊 **Web Interface**: Clean, responsive web UI for remote management
- 🔧 **Flexible Storage**: Configurable volumes for downloads, incomplete files, and data
- 🚀 **Production Ready**: Health checks, resource management, and security contexts
- 📈 **Monitoring**: Optional Prometheus ServiceMonitor support
- 🌐 ***arr Integration**: Seamless integration with Sonarr, Radarr, Lidarr, etc.
- ⚡ **High Performance**: Optimized for high-throughput downloading
- 🛡️ **Security**: Network policies and VPN-first architecture

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure
- **VPN provider credentials** (highly recommended for torrent traffic)

## Installing the Chart

To install the chart with the release name `qbittorrent`:

```bash
helm install qbittorrent ./charts/incubator/qbittorrent
```

**⚠️ Important:** For production use, VPN is strongly recommended:

```bash
helm install qbittorrent ./charts/incubator/qbittorrent -f values-vpn-pia.yaml
```

To install with custom values:

```bash
helm install qbittorrent ./charts/incubator/qbittorrent -f my-values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `qbittorrent` deployment:

```bash
helm delete qbittorrent
```

## Configuration

### Basic Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `qbittorrent.enabled` | Enable qBittorrent | `true` |
| `qbittorrent.image.repository` | qBittorrent image repository | `ghcr.io/hotio/qbittorrent` |
| `qbittorrent.image.tag` | qBittorrent image tag | `latest` |
| `qbittorrent.service.port` | Web UI service port | `8080` |
| `qbittorrent.env.PUID` | Process User ID | `1000` |
| `qbittorrent.env.PGID` | Process Group ID | `1000` |
| `qbittorrent.env.TZ` | Timezone | `Europe/London` |
| `qbittorrent.env.WEBUI_PORTS` | Web UI ports | `8080` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `qbittorrent.persistence.config.enabled` | Enable config persistence | `true` |
| `qbittorrent.persistence.config.size` | Config volume size | `2Gi` |
| `qbittorrent.persistence.downloads.enabled` | Enable downloads persistence | `true` |
| `qbittorrent.persistence.downloads.size` | Downloads volume size | `500Gi` |
| `qbittorrent.persistence.data.enabled` | Enable data persistence | `true` |
| `qbittorrent.persistence.data.size` | Data volume size | `100Gi` |
| `qbittorrent.persistence.incomplete.enabled` | Enable incomplete downloads volume | `false` |
| `qbittorrent.persistence.incomplete.size` | Incomplete volume size | `100Gi` |

### VPN Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.enabled` | Enable Gluetun VPN sidecar | `true` |
| `gluetun.image.repository` | Gluetun image repository | `ghcr.io/qdm12/gluetun` |
| `gluetun.vpn.pia.enabled` | Enable Private Internet Access | `true` |
| `gluetun.vpn.pia.username` | PIA username (store in secret) | `""` |
| `gluetun.vpn.pia.password` | PIA password (store in secret) | `""` |
| `gluetun.vpn.pia.serverRegions` | PIA server regions | `UK London` |
| `gluetun.env.VPN_PORT_FORWARDING` | Enable VPN port forwarding | `on` |

### Service Ports

| Parameter | Description | Default |
|-----------|-------------|---------|
| `qbittorrent.service.additionalPorts.bittorrent.port` | BitTorrent TCP port | `6881` |
| `qbittorrent.service.additionalPorts.dht.port` | BitTorrent UDP port (DHT) | `6881` |

## VPN Integration

**VPN is strongly recommended for qBittorrent** to protect your privacy and avoid ISP throttling or blocking. This chart includes integrated Gluetun VPN support.

### Supported VPN Providers

- **Private Internet Access (PIA)** - OpenVPN with port forwarding
- **NordVPN** - WireGuard
- **Mullvad** - WireGuard

### Why VPN is Important for Torrents

1. **Privacy Protection**: Hide your IP address from other peers
2. **ISP Bypass**: Avoid throttling and blocking by ISPs
3. **Legal Protection**: Additional layer of anonymity
4. **Port Forwarding**: Better connectivity and download speeds
5. **Geo-blocking**: Access to region-restricted content

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
  env:
    VPN_PORT_FORWARDING: "on"
```

Install with VPN enabled:

```bash
helm install qbittorrent ./charts/incubator/qbittorrent -f values-vpn-pia.yaml
```

## Examples

### Basic Installation (Not Recommended for Production)

```yaml
# values-basic.yaml
qbittorrent:
  persistence:
    downloads:
      size: 1Ti
    data:
      size: 200Gi

# VPN disabled - only for testing
gluetun:
  enabled: false
```

### Production Configuration with VPN

```yaml
# values-production.yaml
qbittorrent:
  resources:
    limits:
      cpu: 4000m
      memory: 4Gi
    requests:
      cpu: 1000m
      memory: 2Gi

  persistence:
    config:
      storageClass: "fast-ssd"
      size: 5Gi
    downloads:
      storageClass: "large-hdd"
      size: 2Ti
    data:
      storageClass: "fast-ssd"
      size: 500Gi
    incomplete:
      enabled: true
      storageClass: "fast-ssd"
      size: 200Gi

  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: basic-auth
    hosts:
      - host: qbittorrent.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: qbittorrent-tls
        hosts:
          - qbittorrent.example.com

gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-username"
      password: "your-password"
      serverRegions: "UK London"
  env:
    VPN_PORT_FORWARDING: "on"
    FIREWALL_OUTBOUND_SUBNETS: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

serviceMonitor:
  enabled: true

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

### High-Performance Configuration

```yaml
# values-high-performance.yaml
qbittorrent:
  resources:
    limits:
      cpu: 8000m
      memory: 8Gi
    requests:
      cpu: 2000m
      memory: 4Gi

  persistence:
    downloads:
      storageClass: "nvme-ssd"
      size: 5Ti
    incomplete:
      enabled: true
      storageClass: "nvme-ssd"
      size: 1Ti

pod:
  nodeSelector:
    node-type: "high-performance"
  tolerations:
    - key: "high-performance"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

gluetun:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
```

## Integration with *arr Applications

qBittorrent integrates seamlessly with the *arr suite for automated media downloading:

### Configuration Steps

1. **Deploy qBittorrent** with VPN enabled
2. **Configure Download Clients** in your *arr applications:
   - **Host**: `qbittorrent` (service name)
   - **Port**: `8080`
   - **Username**: `admin` (default)
   - **Password**: Check qBittorrent logs for generated password
3. **Set up Categories** in qBittorrent for different media types
4. **Configure Paths** to match your volume mounts

### Network Considerations

When using VPN, ensure your *arr applications can reach qBittorrent:

```yaml
# Example network policy
networkPolicy:
  enabled: true
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: sonarr
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: radarr
      ports:
        - protocol: TCP
          port: 8080
```

## Troubleshooting

### Common Issues

1. **VPN connection failures**
   - Verify VPN credentials are correct
   - Check Gluetun container logs: `kubectl logs <pod-name> -c gluetun`
   - Ensure NET_ADMIN capability is available
   - Test different VPN server regions

2. **Download speed issues**
   - Enable VPN port forwarding
   - Check if ISP is throttling non-VPN traffic
   - Verify sufficient CPU and memory resources
   - Consider using faster storage for incomplete downloads

3. **Connection to trackers failing**
   - Verify VPN is working correctly
   - Check if VPN provider allows P2P traffic
   - Test different VPN servers
   - Verify firewall settings

4. ***arr applications can't reach qBittorrent**
   - Check network policies
   - Verify service names and ports
   - Ensure both applications are in same namespace or have proper cross-namespace access

5. **Permission issues with downloads**
   - Verify PUID/PGID settings match your storage
   - Check volume mount permissions
   - Ensure fsGroup is set correctly

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=qbittorrent

# View qBittorrent logs
kubectl logs -l app.kubernetes.io/name=qbittorrent -c qbittorrent -f

# Check VPN status
kubectl logs <pod-name> -c gluetun

# Test VPN connection from inside pod
kubectl exec -it <pod-name> -c qbittorrent -- curl ifconfig.me

# Check qBittorrent web UI accessibility
kubectl port-forward svc/qbittorrent 8080:8080

# Monitor download performance
kubectl top pods -l app.kubernetes.io/name=qbittorrent
```

### Performance Tuning

For high-throughput downloading:

1. **Resource Allocation**:
   - CPU: 2-8 cores depending on concurrent downloads
   - Memory: 2-8GB for large torrent files
   - Network: Ensure sufficient bandwidth

2. **Storage Optimization**:
   - Use NVMe SSDs for incomplete downloads
   - Separate volumes for complete vs incomplete downloads
   - Consider RAID configurations for redundancy

3. **Network Configuration**:
   - Enable VPN port forwarding
   - Use VPN servers with P2P optimization
   - Configure appropriate connection limits

## Security Considerations

### Essential Security Measures

1. **Always Use VPN**: Never run qBittorrent without VPN protection
2. **Network Policies**: Restrict access to only necessary services
3. **Authentication**: Change default passwords immediately
4. **Resource Limits**: Prevent resource exhaustion attacks
5. **Storage Security**: Use encrypted storage for sensitive content

### Security Checklist

- [ ] VPN enabled and working
- [ ] Default passwords changed
- [ ] Network policies configured
- [ ] Resource limits set
- [ ] Monitoring enabled
- [ ] Backup strategy in place
- [ ] Legal compliance verified

## Default Credentials

- **Username**: `admin`
- **Password**: Check container logs for generated password

To find the generated password:
```bash
kubectl logs <pod-name> -c qbittorrent | grep "password"
```

## API Access

qBittorrent provides a Web API for automation and integration:

- **API Documentation**: Available at `/api/v2/` endpoint
- **Authentication**: Uses same credentials as web UI
- **Common Endpoints**:
  - `/api/v2/torrents/info` - List torrents
  - `/api/v2/torrents/add` - Add new torrent
  - `/api/v2/app/preferences` - Get/set preferences

## Performance Metrics

Monitor these key metrics for optimal performance:

- Download/upload speeds
- Active torrent count
- Disk I/O usage
- Memory consumption
- Network throughput
- VPN connection stability

## Contributing

Please read our [Contributing Guide](../../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## Maintainers

| Name | Email |
| ---- | ------ |
| Michael Leer | <michael@leer.dev> |

## Source Code

* <https://github.com/qbittorrent/qBittorrent>
* <https://github.com/linuxserver/docker-qbittorrent>