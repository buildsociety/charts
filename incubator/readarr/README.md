# Readarr Helm Chart

A Helm chart for deploying Readarr - Book Manager and Automation (Ebook/Audiobook) - with optional VPN (Gluetun) integration.

## Features

- 📚 **Readarr** - Smart book and audiobook manager with automated downloading
- 🔒 **Optional VPN Integration** - Route traffic through Gluetun VPN sidecar
- 💾 **Persistent Storage** - Configurable storage for config, downloads, books, and audiobooks
- 🏠 **Homepage Integration** - Ready for homepage dashboard widgets
- 🔐 **Security** - Network policies, proper security contexts, and secret management
- 🎛️ **Flexible Configuration** - Extensive customization options
- 📖 **Multi-Format Support** - EPUB, MOBI, PDF, and audiobook formats
- 🔗 **Calibre Integration** - Seamless integration with Calibre for metadata management

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
helm install readarr your-charts/readarr
```

### Install with VPN (Gluetun)

```bash
# Create values file for VPN configuration
cat <<EOF > readarr-vpn-values.yaml
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
helm install readarr your-charts/readarr -f readarr-vpn-values.yaml
```

### Complete Installation with VPN

```bash
# Create comprehensive values file
cat <<EOF > readarr-complete-values.yaml
readarr:
  persistence:
    config:
      size: 2Gi
    downloads:
      size: 200Gi
    books:
      size: 2Ti
    audiobooks:
      size: 1Ti

gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-vpn-username"
      password: "your-vpn-password"
      serverRegions: "UK London"

readarr:
  ingress:
    enabled: true  # Configure as needed
  homepage:
    enabled: true
    widget:
      key: "your-readarr-api-key"
EOF

# Install complete setup
helm install readarr your-charts/readarr -f readarr-complete-values.yaml
```

## Configuration

### Core Readarr Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `readarr.enabled` | Enable Readarr deployment | `true` |
| `readarr.image.repository` | Readarr image repository | `lscr.io/linuxserver/readarr` |
| `readarr.image.tag` | Readarr image tag | `develop` |
| `readarr.env.PUID` | Process User ID | `1000` |
| `readarr.env.PGID` | Process Group ID | `1000` |
| `readarr.env.TZ` | Timezone | `Europe/London` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `readarr.service.type` | Service type | `ClusterIP` |
| `readarr.service.port` | Service port | `8787` |
| `readarr.service.targetPort` | Target port | `8787` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `readarr.persistence.config.enabled` | Enable config persistence | `true` |
| `readarr.persistence.config.size` | Config volume size | `1Gi` |
| `readarr.persistence.downloads.enabled` | Enable downloads persistence | `true` |
| `readarr.persistence.downloads.size` | Downloads volume size | `50Gi` |
| `readarr.persistence.books.enabled` | Enable books persistence | `true` |
| `readarr.persistence.books.size` | Books volume size | `1Ti` |
| `readarr.persistence.audiobooks.enabled` | Enable audiobooks persistence | `true` |
| `readarr.persistence.audiobooks.size` | Audiobooks volume size | `500Gi` |
| `readarr.persistence.data.enabled` | Enable data persistence | `true` |
| `readarr.persistence.data.size` | Data volume size | `100Gi` |

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
| `readarr.homepage.enabled` | Enable homepage labels | `true` |
| `readarr.homepage.group` | Homepage group | `Media` |
| `readarr.homepage.widget.type` | Widget type | `readarr` |
| `readarr.homepage.widget.key` | API key for widget | `""` |

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
readarr:
  persistence:
    config:
      storageClass: "nfs-client"
      size: 2Gi
    downloads:
      storageClass: "nfs-client"
      size: 200Gi
    books:
      storageClass: "nfs-client"
      size: 5Ti
    audiobooks:
      storageClass: "nfs-client"
      size: 2Ti
```

### Local Storage

```yaml
readarr:
  persistence:
    config:
      storageClass: "local-path"
      size: 1Gi
    books:
      storageClass: "local-path"
      size: 2Ti
    audiobooks:
      storageClass: "local-path"
      size: 1Ti
```

## Ingress Examples

### NGINX Ingress

```yaml
readarr:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    hosts:
      - host: readarr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: readarr-tls
        hosts:
          - readarr.example.com
```

### Traefik Ingress

```yaml
readarr:
  ingress:
    enabled: true
    className: "traefik"
    annotations:
      traefik.ingress.kubernetes.io/router.tls: "true"
    hosts:
      - host: readarr.example.com
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
          port: 8787
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
- Liveness probes (HTTP GET to Readarr web interface)
- Readiness probes (HTTP GET to Readarr web interface)
- Resource limits and requests

## Book Management Setup

### Initial Configuration

After deployment, configure Readarr for book management:

1. **Root Folders**:
   - Go to Settings > Media Management > Root Folders
   - Add book library path: `/books`
   - Add audiobook library path: `/audiobooks` (if enabled)

2. **Quality Profiles**:
   - Configure quality profiles for different book formats
   - Set preferences for EPUB, MOBI, PDF formats
   - Configure audiobook quality settings

3. **Metadata Profiles**:
   - Set up metadata profiles for book information
   - Configure metadata sources and priorities

### Indexers Setup

Configure book indexers for content discovery:

```yaml
# Example indexer configuration
readarr:
  configMap:
    enabled: true
    data:
      indexer-config: |
        # Book indexer settings
        torznab_enabled: true
        newznab_enabled: true
```

### Download Client Integration

Readarr works with various download clients:

1. **qBittorrent**:
   - Configure in Settings > Download Clients
   - Set up book-specific categories
   - Configure post-processing scripts

2. **SABnzbd**:
   - Add SABnzbd configuration
   - Set up book categories
   - Configure completion handling

3. **NZBGet**:
   - Configure NZBGet connection
   - Set up post-processing
   - Configure download categories

### Calibre Integration

For enhanced metadata and library management:

```yaml
readarr:
  configMap:
    enabled: true
    data:
      calibre-config: |
        # Calibre integration settings
        calibre_host: "http://calibre:8080"
        calibre_port: 8080
        calibre_username: ""
        calibre_password: ""
```

### Import Lists

Set up import lists for automated book discovery:

1. **Goodreads Integration**:
   - Configure Goodreads import lists
   - Set up author monitoring
   - Configure reading lists import

2. **Calibre Import**:
   - Import existing Calibre libraries
   - Sync metadata and covers
   - Configure automated updates

## Format Support

Readarr supports various book formats:

### Ebook Formats
- **EPUB** - Standard ebook format
- **MOBI** - Amazon Kindle format
- **PDF** - Portable Document Format
- **AZW/AZW3** - Amazon formats

### Audiobook Formats
- **MP3** - Standard audio format
- **M4A/M4B** - Apple audiobook format
- **FLAC** - High-quality audio format
- **OGG** - Open-source audio format

## Upgrading

### Upgrade Chart Version

```bash
helm repo update
helm upgrade readarr your-charts/readarr
```

### Upgrade with New Values

```bash
helm upgrade readarr your-charts/readarr -f new-values.yaml
```

### Backup Before Upgrade

```bash
# Backup config
kubectl cp default/readarr-pod:/config ./readarr-config-backup

# Upgrade
helm upgrade readarr your-charts/readarr
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=readarr
kubectl describe pod <pod-name>
```

### View Logs

```bash
# Readarr logs
kubectl logs <pod-name> -c readarr

# Gluetun logs (if enabled)
kubectl logs <pod-name> -c gluetun
```

### Test VPN Connection

```bash
# Port forward to gluetun control interface
kubectl port-forward <pod-name> 8000:8000

# Check VPN status
curl http://localhost:8000/v1/openvpn/status
```

### Access Readarr Shell

```bash
kubectl exec -it <pod-name> -c readarr -- /bin/bash
```

### Common Issues

1. **VPN Not Connecting**: Check credentials in secrets
2. **Storage Issues**: Verify PVC creation and storage class
3. **Permission Issues**: Check PUID/PGID settings
4. **Network Issues**: Verify network policies if enabled
5. **Book Import Issues**: Check file permissions and formats
6. **Metadata Issues**: Verify indexer connections and API keys

### Book Library Issues

If Readarr cannot access book files:

```bash
# Check volume mounts
kubectl describe pod <pod-name>

# Check file permissions
kubectl exec -it <pod-name> -c readarr -- ls -la /books /audiobooks

# Verify book formats
kubectl exec -it <pod-name> -c readarr -- find /books -name "*.epub" | head -5
```

## Performance Optimization

For large book libraries:

```yaml
readarr:
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
    requests:
      cpu: 200m
      memory: 512Mi
  
  # Enable additional storage for large libraries
  persistence:
    books:
      size: 10Ti
    audiobooks:
      size: 5Ti
```

## Integration with Media Stack

Readarr works well with other media automation tools:

1. **Calibre** - Library management and format conversion
2. **Calibre-Web** - Web interface for book reading
3. **Audiobookshelf** - Audiobook server and player
4. **Kavita** - Manga and comic book server
5. **LazyLibrarian** - Alternative book manager

### Example Media Stack

```yaml
# Example integration with other services
readarr:
  persistence:
    books:
      # Share with Calibre-Web
      existingClaim: "books-pvc"
    audiobooks:
      # Share with Audiobookshelf  
      existingClaim: "audiobooks-pvc"
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall readarr

# Clean up PVCs (if needed)
kubectl delete pvc -l app.kubernetes.io/name=readarr
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

- [Readarr Documentation](https://wiki.servarr.com/readarr)
- [Gluetun Documentation](https://github.com/qdm12/gluetun)
- [Calibre Integration](https://calibre-ebook.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)