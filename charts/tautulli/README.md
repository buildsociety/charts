# Tautulli Helm Chart

A Helm chart for deploying Tautulli - A Python based monitoring and tracking tool for Plex Media Server.

## Features

- 📊 **Tautulli** - Comprehensive Plex Media Server monitoring and analytics
- 💾 **Persistent Storage** - Configurable storage for config and optional log retention
- 🏠 **Homepage Integration** - Ready for homepage dashboard widgets
- 🔐 **Security** - Network policies, proper security contexts, and secret management
- 🎛️ **Flexible Configuration** - Extensive customization options
- 📱 **Notifications** - Support for various notification services
- 📈 **Analytics** - Detailed statistics and custom graphs

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)
- **Plex Media Server** - Running and accessible (can be in-cluster or external)

## Installation

### Quick Start

```bash
# Add the helm repository (replace with actual repo)
helm repo add your-charts https://your-charts.example.com
helm repo update

# Install with default configuration
helm install tautulli your-charts/tautulli
```

### Install with Plex Configuration

```bash
# Create values file with Plex server details
cat <<EOF > tautulli-values.yaml
tautulli:
  plex:
    url: "http://plex:32400"
    token: "your-plex-token"
  homepage:
    enabled: true
    widget:
      key: "your-tautulli-api-key"
EOF

# Install with Plex configuration
helm install tautulli your-charts/tautulli -f tautulli-values.yaml
```

### Complete Installation with Ingress

```bash
# Create comprehensive values file
cat <<EOF > tautulli-complete-values.yaml
tautulli:
  persistence:
    config:
      size: 5Gi
    logs:
      enabled: true
      size: 10Gi
  
  plex:
    url: "http://plex.media.svc.cluster.local:32400"
    token: "your-plex-token"
  
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: tautulli.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: tautulli-tls
        hosts:
          - tautulli.example.com
  
  homepage:
    enabled: true
    widget:
      key: "your-tautulli-api-key"
EOF

# Install complete setup
helm install tautulli your-charts/tautulli -f tautulli-complete-values.yaml
```

## Configuration

### Core Tautulli Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `tautulli.enabled` | Enable Tautulli deployment | `true` |
| `tautulli.image.repository` | Tautulli image repository | `lscr.io/linuxserver/tautulli` |
| `tautulli.image.tag` | Tautulli image tag | `latest` |
| `tautulli.env.PUID` | Process User ID | `1000` |
| `tautulli.env.PGID` | Process Group ID | `1000` |
| `tautulli.env.TZ` | Timezone | `Europe/London` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `tautulli.service.type` | Service type | `ClusterIP` |
| `tautulli.service.port` | Service port | `8181` |
| `tautulli.service.targetPort` | Target port | `8181` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `tautulli.persistence.config.enabled` | Enable config persistence | `true` |
| `tautulli.persistence.config.size` | Config volume size | `2Gi` |
| `tautulli.persistence.logs.enabled` | Enable logs persistence | `false` |
| `tautulli.persistence.logs.size` | Logs volume size | `5Gi` |

### Plex Integration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `tautulli.plex.url` | Plex server URL | `http://plex:32400` |
| `tautulli.plex.token` | Plex server token | `""` |
| `tautulli.plex.ssl_verify` | Verify SSL certificates | `true` |

### Homepage Integration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `tautulli.homepage.enabled` | Enable homepage labels | `true` |
| `tautulli.homepage.group` | Homepage group | `Media` |
| `tautulli.homepage.widget.type` | Widget type | `tautulli` |
| `tautulli.homepage.widget.key` | API key for widget | `""` |

## Plex Server Setup

### Finding Your Plex Token

1. **Web Interface Method**:
   ```bash
   # Open browser developer tools on your Plex web interface
   # Look for X-Plex-Token in network requests
   ```

2. **Settings Method**:
   - Go to Plex Web App
   - Settings > General > Network
   - Show Advanced
   - Find "Plex Media Server" token

3. **API Method**:
   ```bash
   curl -u "username:password" 'https://plex.tv/users/sign_in.xml' -X POST
   # Extract token from response
   ```

### Plex Server URLs

For **in-cluster Plex**:
```yaml
tautulli:
  plex:
    url: "http://plex:32400"  # If Plex service is named "plex"
    # or
    url: "http://plex.media.svc.cluster.local:32400"
```

For **external Plex**:
```yaml
tautulli:
  plex:
    url: "http://192.168.1.100:32400"  # Direct IP
    # or
    url: "https://my-plex-server.example.com:32400"  # Domain name
```

## Storage Examples

### Basic Storage

```yaml
tautulli:
  persistence:
    config:
      storageClass: "standard"
      size: 2Gi
    logs:
      enabled: false
```

### Extended Storage with Logs

```yaml
tautulli:
  persistence:
    config:
      storageClass: "fast-ssd"
      size: 5Gi
    logs:
      enabled: true
      storageClass: "standard"
      size: 20Gi
```

### NFS Storage

```yaml
tautulli:
  persistence:
    config:
      storageClass: "nfs-client"
      size: 3Gi
    logs:
      enabled: true
      storageClass: "nfs-client"
      size: 15Gi
```

## Ingress Examples

### NGINX Ingress

```yaml
tautulli:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: tautulli-auth
    hosts:
      - host: tautulli.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: tautulli-tls
        hosts:
          - tautulli.example.com
```

### Traefik Ingress

```yaml
tautulli:
  ingress:
    enabled: true
    className: "traefik"
    annotations:
      traefik.ingress.kubernetes.io/router.tls: "true"
      traefik.ingress.kubernetes.io/router.middlewares: "auth-basic@kubernetescrd"
    hosts:
      - host: tautulli.example.com
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
          port: 8181
    - from:
        - namespaceSelector:
            matchLabels:
              name: monitoring
      ports:
        - protocol: TCP
          port: 8181
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: media  # Allow access to Plex
      ports:
        - protocol: TCP
          port: 32400
    - to: []
      ports:
        - protocol: TCP
          port: 443  # HTTPS for notifications
        - protocol: TCP
          port: 80   # HTTP for notifications
```

### Authentication

Enable authentication in Tautulli settings:
```yaml
tautulli:
  configMap:
    enabled: true
    data:
      security.conf: |
        # Enable HTTP authentication
        http_username = admin
        http_password = secure_password
```

### Security Contexts

The chart automatically configures security contexts:
- Runs as non-root user (UID 1000)
- Proper filesystem permissions
- Read-only root filesystem (where possible)

## Monitoring and Health Checks

The chart includes:
- Liveness probes (HTTP GET to Tautulli web interface)
- Readiness probes (HTTP GET to Tautulli web interface)
- Resource limits and requests

### Prometheus Integration

```yaml
serviceMonitor:
  enabled: true
  labels:
    app: prometheus
  interval: "30s"
  path: "/api/v2?apikey=YOUR_API_KEY&cmd=get_server_info"
```

## Notifications Setup

After deployment, configure notifications:

### Discord Notifications
1. Go to Settings > Notification Agents
2. Add Discord agent
3. Configure webhook URL and message templates

### Email Notifications
```yaml
tautulli:
  configMap:
    enabled: true
    data:
      notification-email.conf: |
        smtp_server = smtp.gmail.com
        smtp_port = 587
        smtp_user = your-email@gmail.com
        smtp_password = your-app-password
```

### Slack Integration
1. Create Slack app and webhook
2. Add Slack notification agent in Tautulli
3. Configure channels and message formats

## API Usage

### Get Activity
```bash
curl "http://tautulli:8181/api/v2?apikey=YOUR_API_KEY&cmd=get_activity"
```

### Get History
```bash
curl "http://tautulli:8181/api/v2?apikey=YOUR_API_KEY&cmd=get_history&length=10"
```

### Server Statistics
```bash
curl "http://tautulli:8181/api/v2?apikey=YOUR_API_KEY&cmd=get_server_info"
```

## Upgrading

### Upgrade Chart Version

```bash
helm repo update
helm upgrade tautulli your-charts/tautulli
```

### Upgrade with New Values

```bash
helm upgrade tautulli your-charts/tautulli -f new-values.yaml
```

### Backup Before Upgrade

```bash
# Backup config and database
kubectl cp default/tautulli-pod:/config ./tautulli-config-backup

# Upgrade
helm upgrade tautulli your-charts/tautulli
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=tautulli
kubectl describe pod <pod-name>
```

### View Logs

```bash
# Tautulli logs
kubectl logs <pod-name> -c tautulli

# Follow logs
kubectl logs <pod-name> -c tautulli -f
```

### Access Tautulli Shell

```bash
kubectl exec -it <pod-name> -c tautulli -- /bin/bash
```

### Common Issues

1. **Plex Connection Failed**:
   - Verify Plex server URL and token
   - Check network connectivity between Tautulli and Plex
   - Ensure Plex allows connections from Tautulli's IP

2. **Database Issues**:
   - Check disk space in config volume
   - Verify file permissions (UID/GID 1000)
   - Check for database corruption in logs

3. **Performance Issues**:
   - Increase resource limits
   - Enable log persistence for debugging
   - Check Plex server performance

4. **Notification Issues**:
   - Verify notification agent configuration
   - Check external service connectivity
   - Test notification templates

### Database Maintenance

```bash
# Access database
kubectl exec -it <pod-name> -c tautulli -- sqlite3 /config/tautulli.db

# Vacuum database
kubectl exec -it <pod-name> -c tautulli -- sqlite3 /config/tautulli.db "VACUUM;"

# Check database integrity
kubectl exec -it <pod-name> -c tautulli -- sqlite3 /config/tautulli.db "PRAGMA integrity_check;"
```

## Performance Optimization

For large Plex libraries:

```yaml
tautulli:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 200m
      memory: 512Mi
  
  persistence:
    config:
      size: 10Gi  # Larger database storage
    logs:
      enabled: true
      size: 50Gi  # Extended log retention
```

## Integration Examples

### Grafana Dashboard

Create custom Grafana dashboards using Tautulli API:
- Current activity graphs
- Historical usage trends
- User statistics
- Library growth charts

### Home Assistant

Integrate with Home Assistant for:
- Presence detection based on Plex usage
- Automated notifications
- Smart home triggers

### Custom Scripts

```bash
# Example: Get current streams
#!/bin/bash
TAUTULLI_URL="http://tautulli:8181"
API_KEY="your-api-key"

curl -s "${TAUTULLI_URL}/api/v2?apikey=${API_KEY}&cmd=get_activity" | jq '.response.data.stream_count'
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall tautulli

# Clean up PVCs (if needed)
kubectl delete pvc -l app.kubernetes.io/name=tautulli
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

- [Tautulli Documentation](https://github.com/Tautulli/Tautulli/wiki)
- [Tautulli API Documentation](https://github.com/Tautulli/Tautulli/wiki/Tautulli-API-Reference)
- [Plex Media Server](https://www.plex.tv/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)