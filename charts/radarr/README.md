# Radarr Helm Chart

A Helm chart for deploying Radarr - A fork of Sonarr to work with movies à la Couchpotato - with optional VPN (Gluetun) and Cloudflare tunnel integration.

## Features

- 🎬 **Radarr** - Smart PVR for movies with automated downloading
- 🔒 **Optional VPN Integration** - Route traffic through Gluetun VPN sidecar
- 💾 **Persistent Storage** - Configurable storage for config, downloads, and movies
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
helm install radarr your-charts/radarr
```

### Install with VPN (Gluetun)

```bash
# Create values file for VPN configuration
cat <<EOF > radarr-vpn-values.yaml
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
helm install radarr your-charts/radarr -f radarr-vpn-values.yaml
```

### Complete Installation with VPN

```bash
# Create comprehensive values file
cat <<EOF > radarr-complete-values.yaml
radarr:
  persistence:
    config:
      size: 2Gi
    downloads:
      size: 200Gi
    movies:
      size: 5Ti

gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-vpn-username"
      password: "your-vpn-password"
      serverRegions: "UK London"

radarr:
  ingress:
    enabled: true  # Configure as needed
  homepage:
    enabled: true
    widget:
      key: "your-radarr-api-key"
EOF

# Install complete setup
helm install radarr your-charts/radarr -f radarr-complete-values.yaml
```

## Configuration

### Core Radarr Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `radarr.enabled` | Enable Radarr deployment | `true` |
| `radarr.image.repository` | Radarr image repository | `linuxserver/radarr` |
| `radarr.image.tag` | Radarr image tag | `latest` |
| `radarr.env.PUID` | Process User ID | `1000` |
| `radarr.env.PGID` | Process Group ID | `1000` |
| `radarr.env.TZ` | Timezone | `Europe/London` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `radarr.service.type` | Service type | `ClusterIP` |
| `radarr.service.port` | Service port | `7878` |
| `radarr.service.targetPort` | Target port | `7878` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `radarr.persistence.config.enabled` | Enable config persistence | `true` |
| `radarr.persistence.config.size` | Config volume size | `1Gi` |
| `radarr.persistence.downloads.enabled` | Enable downloads persistence | `true` |
| `radarr.persistence.downloads.size` | Downloads volume size | `50Gi` |
| `radarr.persistence.movies.enabled` | Enable movies persistence | `true` |
| `radarr.persistence.movies.size` | Movies volume size | `2Ti` |
| `radarr.persistence.data.enabled` | Enable data persistence | `true` |
| `radarr.persistence.data.size` | Data volume size | `100Gi` |

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
| `radarr.homepage.enabled` | Enable homepage labels | `true` |
| `radarr.homepage.group` | Homepage group | `Media` |
| `radarr.homepage.widget.type` | Widget type | `radarr` |
| `radarr.homepage.widget.key` | API key for widget | `""` |

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
radarr:
  persistence:
    config:
      storageClass: "nfs-client"
      size: 2Gi
    downloads:
      storageClass: "nfs-client"
      size: 200Gi
    movies:
      storageClass: "nfs-client"
      size: 10Ti
```

### Local Storage

```yaml
radarr:
  persistence:
    config:
      storageClass: "local-path"
      size: 1Gi
    movies:
      storageClass: "local-path"
      size: 5Ti
```

## Ingress Examples

### NGINX Ingress

```yaml
radarr:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    hosts:
      - host: radarr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: radarr-tls
        hosts:
          - radarr.example.com
```

### Traefik Ingress

```yaml
radarr:
  ingress:
    enabled: true
    className: "traefik"
    annotations:
      traefik.ingress.kubernetes.io/router.tls: "true"
    hosts:
      - host: radarr.example.com
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
          port: 7878
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
- Liveness probes (HTTP GET to Radarr web interface)
- Readiness probes (HTTP GET to Radarr web interface)
- Resource limits and requests

## Upgrading

### Upgrade Chart Version

```bash
helm repo update
helm upgrade radarr your-charts/radarr
```

### Upgrade with New Values

```bash
helm upgrade radarr your-charts/radarr -f new-values.yaml
```

### Backup Before Upgrade

```bash
# Backup config
kubectl cp default/radarr-pod:/config ./radarr-config-backup

# Upgrade
helm upgrade radarr your-charts/radarr
```

## NFS Setup Guide

### 1. Prepare NFS Exports

On your NAS/NFS server, create and configure exports:

```bash
# Example NFS exports (/etc/exports)
/volume1/media/movies    192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
/volume1/downloads       192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
```

### 2. Set Proper Permissions

Ensure the NFS exports have correct ownership:

```bash
# On NFS server
chown -R 1000:1000 /volume1/media/movies
chown -R 1000:1000 /volume1/downloads
chmod -R 755 /volume1/media/movies
chmod -R 755 /volume1/downloads
```

### 3. Configure Kubernetes Nodes

Install NFS client on all Kubernetes nodes:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install nfs-common

# CentOS/RHEL
sudo yum install nfs-utils
```

### 4. Test NFS Connectivity

```bash
# Test mount from Kubernetes node
sudo mount -t nfs4 192.168.1.100:/volume1/media/movies /mnt/test
ls -la /mnt/test
sudo umount /mnt/test
```

## Troubleshooting

### NFS Issues

**NFS mount fails**:
- Verify NFS exports are properly configured
- Check firewall rules on NFS server
- Ensure nfs-common is installed on all nodes
- Test manual mount from nodes

**Permission denied errors**:
- Check file/directory ownership on NFS server
- Verify no_root_squash is set in exports
- Ensure PUID/PGID match NFS export permissions

**Performance issues**:
- Tune NFS mount options (rsize/wsize)
- Use NFSv4.1 for better performance
- Consider network bandwidth limitations

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=radarr
kubectl describe pod <pod-name>
```

### View Logs

```bash
# Radarr logs
kubectl logs <pod-name> -c radarr

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

### Access Radarr Shell

```bash
kubectl exec -it <pod-name> -c radarr -- /bin/bash
```

### Common Issues

1. **VPN Not Connecting**: Check credentials in secrets
2. **Storage Issues**: Verify PVC creation and storage class
3. **Permission Issues**: Check PUID/PGID settings
4. **Network Issues**: Verify network policies if enabled

## Integration with Download Clients

Radarr works best when integrated with download clients like qBittorrent, SABnzbd, or NZBGet. When using VPN:

```yaml
# Example configuration for shared data volume
radarr:
  persistence:
    data:
      enabled: true
      size: 500Gi
      # This should match your download client's data volume
```

## Quality Profiles and Indexers

After deployment, configure:
1. **Quality Profiles** - Define preferred video quality
2. **Indexers** - Connect to torrent/usenet indexers
3. **Download Clients** - Configure qBittorrent, SABnzbd, etc.
4. **Root Folders** - Set up movie library locations

## Uninstalling

```bash
# Uninstall the release
helm uninstall radarr

# Clean up PVCs (if needed)
kubectl delete pvc -l app.kubernetes.io/name=radarr
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

- [Radarr Documentation](https://wiki.servarr.com/radarr)
- [Gluetun Documentation](https://github.com/qdm12/gluetun)
- [Kubernetes Documentation](https://kubernetes.io/docs/)