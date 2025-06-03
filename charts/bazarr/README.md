# Bazarr Helm Chart

A Helm chart for deploying Bazarr - Subtitle manager for Sonarr and Radarr - with optional VPN (Gluetun) integration.

## Features

- 🎬 **Bazarr** - Smart subtitle manager for movies and TV shows
- 🔒 **Optional VPN Integration** - Route traffic through Gluetun VPN sidecar
- 💾 **Persistent Storage** - Configurable storage for config and read-only media access
- 🏠 **Homepage Integration** - Ready for homepage dashboard widgets
- 🔐 **Security** - Network policies, proper security contexts, and secret management
- 🎛️ **Flexible Configuration** - Extensive customization options
- 🔗 **Media Integration** - Seamless integration with Sonarr and Radarr

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)
- Existing Sonarr and/or Radarr deployments (recommended)

## Installation

### Quick Start

```bash
# Add the helm repository (replace with actual repo)
helm repo add your-charts https://your-charts.example.com
helm repo update

# Install with default configuration
helm install bazarr your-charts/bazarr
```

### Install with VPN (Gluetun)

```bash
# Create values file for VPN configuration
cat <<EOF > bazarr-vpn-values.yaml
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
helm install bazarr your-charts/bazarr -f bazarr-vpn-values.yaml
```

### Complete Installation with VPN

```bash
# Create comprehensive values file
cat <<EOF > bazarr-complete-values.yaml
bazarr:
  persistence:
    config:
      size: 2Gi
    tv:
      size: 1Ti
      accessMode: ReadOnlyMany
    movies:
      size: 5Ti
      accessMode: ReadOnlyMany
    anime:
      size: 500Gi
      accessMode: ReadOnlyMany

gluetun:
  enabled: true
  vpn:
    pia:
      enabled: true
      username: "your-vpn-username"
      password: "your-vpn-password"
      serverRegions: "UK London"

bazarr:
  ingress:
    enabled: true  # Configure as needed
  homepage:
    enabled: true
    widget:
      key: "your-bazarr-api-key"
EOF

# Install complete setup
helm install bazarr your-charts/bazarr -f bazarr-complete-values.yaml
```

## Configuration

### Core Bazarr Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `bazarr.enabled` | Enable Bazarr deployment | `true` |
| `bazarr.image.repository` | Bazarr image repository | `lscr.io/linuxserver/bazarr` |
| `bazarr.image.tag` | Bazarr image tag | `latest` |
| `bazarr.env.PUID` | Process User ID | `1000` |
| `bazarr.env.PGID` | Process Group ID | `1000` |
| `bazarr.env.TZ` | Timezone | `Europe/London` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `bazarr.service.type` | Service type | `ClusterIP` |
| `bazarr.service.port` | Service port | `6767` |
| `bazarr.service.targetPort` | Target port | `6767` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `bazarr.persistence.config.enabled` | Enable config persistence | `true` |
| `bazarr.persistence.config.size` | Config volume size | `1Gi` |
| `bazarr.persistence.tv.enabled` | Enable TV persistence | `true` |
| `bazarr.persistence.tv.size` | TV volume size | `500Gi` |
| `bazarr.persistence.tv.accessMode` | TV volume access mode | `ReadOnlyMany` |
| `bazarr.persistence.movies.enabled` | Enable movies persistence | `true` |
| `bazarr.persistence.movies.size` | Movies volume size | `2Ti` |
| `bazarr.persistence.movies.accessMode` | Movies volume access mode | `ReadOnlyMany` |
| `bazarr.persistence.anime.enabled` | Enable anime persistence | `true` |
| `bazarr.persistence.anime.size` | Anime volume size | `200Gi` |
| `bazarr.persistence.anime.accessMode` | Anime volume access mode | `ReadOnlyMany` |

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
| `bazarr.homepage.enabled` | Enable homepage labels | `true` |
| `bazarr.homepage.group` | Homepage group | `Media` |
| `bazarr.homepage.widget.type` | Widget type | `bazarr` |
| `bazarr.homepage.widget.key` | API key for widget | `""` |

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

### Shared Media Storage (Recommended)

```yaml
bazarr:
  persistence:
    config:
      storageClass: "nfs-client"
      size: 2Gi
    tv:
      storageClass: "nfs-client"
      size: 1Ti
      accessMode: ReadOnlyMany
    movies:
      storageClass: "nfs-client"
      size: 5Ti
      accessMode: ReadOnlyMany
    anime:
      storageClass: "nfs-client" 
      size: 500Gi
      accessMode: ReadOnlyMany
```

### Local Storage

```yaml
bazarr:
  persistence:
    config:
      storageClass: "local-path"
      size: 1Gi
    tv:
      storageClass: "local-path"
      size: 1Ti
      accessMode: ReadWriteOnce
    movies:
      storageClass: "local-path"
      size: 5Ti
      accessMode: ReadWriteOnce
```

## Ingress Examples

### NGINX Ingress

```yaml
bazarr:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    hosts:
      - host: bazarr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: bazarr-tls
        hosts:
          - bazarr.example.com
```

### Traefik Ingress

```yaml
bazarr:
  ingress:
    enabled: true
    className: "traefik"
    annotations:
      traefik.ingress.kubernetes.io/router.tls: "true"
    hosts:
      - host: bazarr.example.com
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
          port: 6767
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
- Media volumes mounted read-only for security
- Gluetun gets NET_ADMIN capability for VPN

## Monitoring and Health Checks

The chart includes:
- Liveness probes (HTTP GET to Bazarr web interface)
- Readiness probes (HTTP GET to Bazarr web interface)
- Resource limits and requests

## Integration with Sonarr/Radarr

Bazarr works as a companion to Sonarr and Radarr. After deployment:

1. **Configure Sonarr Connection**:
   - Go to Settings > General > Host Management
   - Add Sonarr server details
   - Set API key and test connection

2. **Configure Radarr Connection**:
   - Go to Settings > General > Host Management  
   - Add Radarr server details
   - Set API key and test connection

3. **Setup Subtitle Providers**:
   - Go to Settings > Providers
   - Add subtitle providers (OpenSubtitles, etc.)
   - Configure provider credentials

4. **Configure Languages**:
   - Go to Settings > Languages
   - Add desired subtitle languages
   - Set language priorities

### Shared Storage Configuration

For optimal integration, ensure Bazarr has read access to the same media paths used by Sonarr and Radarr:

```yaml
# Example shared storage configuration
bazarr:
  persistence:
    tv:
      enabled: true
      # Should point to same storage as Sonarr TV path
      existingClaim: "sonarr-tv-pvc"
      accessMode: ReadOnlyMany
    movies:
      enabled: true
      # Should point to same storage as Radarr movies path
      existingClaim: "radarr-movies-pvc"
      accessMode: ReadOnlyMany
```

## Upgrading

### Upgrade Chart Version

```bash
helm repo update
helm upgrade bazarr your-charts/bazarr
```

### Upgrade with New Values

```bash
helm upgrade bazarr your-charts/bazarr -f new-values.yaml
```

### Backup Before Upgrade

```bash
# Backup config
kubectl cp default/bazarr-pod:/config ./bazarr-config-backup

# Upgrade
helm upgrade bazarr your-charts/bazarr
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=bazarr
kubectl describe pod <pod-name>
```

### View Logs

```bash
# Bazarr logs
kubectl logs <pod-name> -c bazarr

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

### Access Bazarr Shell

```bash
kubectl exec -it <pod-name> -c bazarr -- /bin/bash
```

### Common Issues

1. **VPN Not Connecting**: Check credentials in secrets
2. **Storage Issues**: Verify PVC creation and storage class
3. **Permission Issues**: Check PUID/PGID settings and read permissions
4. **Network Issues**: Verify network policies if enabled
5. **Sonarr/Radarr Connection Failed**: Check API keys and network connectivity
6. **Subtitles Not Downloading**: Verify provider credentials and language settings

### Media Access Issues

If Bazarr cannot access media files:

```bash
# Check volume mounts
kubectl describe pod <pod-name>

# Check file permissions
kubectl exec -it <pod-name> -c bazarr -- ls -la /tv /movies /anime

# Verify read access
kubectl exec -it <pod-name> -c bazarr -- find /tv -name "*.mkv" | head -5
```

## Performance Optimization

For large media libraries:

```yaml
bazarr:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 200m
      memory: 512Mi
  
  # Enable caching for better performance
  env:
    # Additional environment variables for performance
    BAZARR_CACHE_SIZE: "1000"
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall bazarr

# Clean up PVCs (if needed)
kubectl delete pvc -l app.kubernetes.io/name=bazarr
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

- [Bazarr Documentation](https://wiki.bazarr.media/)
- [Gluetun Documentation](https://github.com/qdm12/gluetun)
- [Sonarr Integration Guide](https://wiki.bazarr.media/Tutorials/Setup-Guide/)
- [Radarr Integration Guide](https://wiki.bazarr.media/Tutorials/Setup-Guide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)