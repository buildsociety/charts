# Overseerr

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.33.2](https://img.shields.io/badge/AppVersion-1.33.2-informational?style=flat-square)

A Helm chart for Overseerr - Request management and media discovery tool for Plex

**Homepage:** <https://overseerr.dev/>

## Description

Overseerr is a free and open source software application for managing requests for your media library. It integrates with your existing services, such as Sonarr, Radarr, and Plex (and many more!). Overseerr helps you find media you want to watch and provides a simple interface to request content.

This Helm chart deploys Overseerr on a Kubernetes cluster as a standalone web application that doesn't require VPN integration since it's primarily a user-facing interface for managing media requests.

## Features

- 🎬 **Media Discovery**: Browse and discover movies and TV shows from TMDb
- 📋 **Request Management**: Simple interface for users to request content
- 👥 **User Management**: Multi-user support with role-based permissions
- 🔔 **Notifications**: Discord, Slack, email, and webhook notifications
- 📊 **Dashboard**: Overview of requests, users, and media statistics
- 🎭 **Plex Integration**: Deep integration with Plex Media Server
- ⚡ ***arr Integration**: Seamless integration with Sonarr, Radarr, and other *arr applications
- 🌐 **Web Interface**: Clean, responsive web UI optimized for all devices
- 🚀 **Production Ready**: Health checks, resource management, and security contexts
- 📈 **Monitoring**: Optional Prometheus ServiceMonitor support

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure
- Plex Media Server (for full functionality)
- Sonarr and/or Radarr (for automated downloads)

## Installing the Chart

To install the chart with the release name `overseerr`:

```bash
helm install overseerr ./charts/incubator/overseerr
```

To install with custom values:

```bash
helm install overseerr ./charts/incubator/overseerr -f my-values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `overseerr` deployment:

```bash
helm delete overseerr
```

## Configuration

### Basic Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `overseerr.enabled` | Enable Overseerr | `true` |
| `overseerr.image.repository` | Overseerr image repository | `sctx/overseerr` |
| `overseerr.image.tag` | Overseerr image tag | `latest` |
| `overseerr.service.port` | Service port | `5055` |
| `overseerr.env.PUID` | Process User ID | `1000` |
| `overseerr.env.PGID` | Process Group ID | `1000` |
| `overseerr.env.TZ` | Timezone | `Europe/London` |
| `overseerr.env.LOG_LEVEL` | Log level | `info` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `overseerr.persistence.config.enabled` | Enable config persistence | `true` |
| `overseerr.persistence.config.size` | Config volume size | `2Gi` |
| `overseerr.persistence.logs.enabled` | Enable logs persistence | `false` |
| `overseerr.persistence.logs.size` | Logs volume size | `1Gi` |

### Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `overseerr.settings.baseUrl` | Base URL for reverse proxy | `""` |
| `overseerr.settings.trustProxy` | Trust proxy headers | `false` |
| `overseerr.settings.apiRateLimit` | Enable API rate limiting | `true` |
| `overseerr.settings.apiRateLimitMax` | Max API requests per window | `100` |
| `overseerr.settings.apiRateLimitWindow` | Rate limit window (minutes) | `15` |

## Examples

### Basic Installation

```yaml
# values-basic.yaml
overseerr:
  persistence:
    config:
      size: 5Gi
```

### With Custom Storage Classes

```yaml
# values-storage.yaml
overseerr:
  persistence:
    config:
      storageClass: "fast-ssd"
      size: 5Gi
    logs:
      enabled: true
      storageClass: "standard"
      size: 2Gi
```

### With Ingress Configuration

```yaml
# values-ingress.yaml
overseerr:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
    hosts:
      - host: overseerr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: overseerr-tls
        hosts:
          - overseerr.example.com
```

### Production Configuration

```yaml
# values-production.yaml
overseerr:
  resources:
    limits:
      cpu: 2000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

  persistence:
    config:
      storageClass: "fast-ssd"
      size: 10Gi
    logs:
      enabled: true
      storageClass: "standard"
      size: 5Gi

  settings:
    baseUrl: "/overseerr"
    trustProxy: true
    apiRateLimit: true
    apiRateLimitMax: 200
    apiRateLimitWindow: 10

  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: overseerr-basic-auth
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/rate-limit: "100"
      nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    hosts:
      - host: overseerr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: overseerr-tls
        hosts:
          - overseerr.example.com

  homepage:
    enabled: true
    group: "Media"
    name: "Overseerr"
    description: "Request Manager"
    widget:
      type: "overseerr"
      url: "https://overseerr.example.com"
      key: "your-api-key"

serviceMonitor:
  enabled: true

podDisruptionBudget:
  enabled: true
  minAvailable: 1

hpa:
  enabled: true
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 80
```

## Integration with Media Stack

Overseerr acts as the user-facing frontend for your media automation stack:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Users    │    │  Overseerr  │    │    Plex     │
│             │───▶│  (Requests) │◄──▶│   Server    │
└─────────────┘    └──────┬──────┘    └─────────────┘
                          │
                ┌─────────┼─────────┐
                │         │         │
        ┌───────▼───┐ ┌───▼───┐ ┌───▼─────┐
        │  Sonarr   │ │Radarr │ │ Lidarr  │
        │   (TV)    │ │(Movies)│ │(Music)  │
        └───────────┘ └───────┘ └─────────┘
```

### Configuration Steps

1. **Deploy Overseerr** using this chart
2. **Access the web interface** and complete the setup wizard
3. **Configure Plex connection** in Overseerr settings
4. **Add *arr services** (Sonarr, Radarr, etc.) to Overseerr
5. **Set up notifications** (Discord, Slack, email, etc.)
6. **Configure user permissions** and quotas
7. **Create request workflows** for different content types

### Integration Examples

#### Plex Integration

```yaml
# Configure Plex server in Overseerr settings
plex:
  hostname: "plex.example.com"
  port: 32400
  useSsl: true
  libraries:
    - name: "Movies"
      type: "movie"
    - name: "TV Shows"
      type: "tv"
```

#### Sonarr Integration

```yaml
# Configure Sonarr in Overseerr
sonarr:
  hostname: "sonarr.media.svc.cluster.local"
  port: 8989
  useSsl: false
  apiKey: "your-sonarr-api-key"
  rootFolder: "/tv"
  qualityProfile: "HD-1080p"
```

#### Radarr Integration

```yaml
# Configure Radarr in Overseerr
radarr:
  hostname: "radarr.media.svc.cluster.local"
  port: 7878
  useSsl: false
  apiKey: "your-radarr-api-key"
  rootFolder: "/movies"
  qualityProfile: "HD-1080p"
```

## User Management

### User Roles

Overseerr supports multiple user roles:

- **Admin**: Full access to all features and settings
- **User**: Can make requests and view their own requests
- **Local User**: Manually created users (not from Plex)

### Permission System

Configure user permissions for:
- Request limits (movies/TV shows per period)
- Auto-approval thresholds
- Request categories access
- 4K content access
- Advanced request options

### Quota Management

Set up user quotas to manage resource usage:
- Daily/weekly/monthly request limits
- Different limits for different user roles
- Override limits for specific users

## Notifications

### Supported Notification Types

- **Discord**: Rich embeds with movie/show information
- **Slack**: Channel notifications with details
- **Email**: SMTP-based email notifications
- **Telegram**: Bot-based notifications
- **Pushbullet**: Mobile push notifications
- **Webhooks**: Custom HTTP webhooks for integration

### Notification Events

Configure notifications for:
- New requests submitted
- Requests approved/declined
- Media available in Plex
- Issues reported
- User registrations

## API Usage

Overseerr provides a comprehensive REST API:

### Authentication

```bash
# Get API key from Overseerr settings
export OVERSEERR_API_KEY="your-api-key"
export OVERSEERR_URL="https://overseerr.example.com"
```

### Common Endpoints

```bash
# Get server status
curl -H "X-Api-Key: $OVERSEERR_API_KEY" "$OVERSEERR_URL/api/v1/status"

# Get all requests
curl -H "X-Api-Key: $OVERSEERR_API_KEY" "$OVERSEERR_URL/api/v1/request"

# Search for media
curl -H "X-Api-Key: $OVERSEERR_API_KEY" "$OVERSEERR_URL/api/v1/search?query=avengers"

# Get user information
curl -H "X-Api-Key: $OVERSEERR_API_KEY" "$OVERSEERR_URL/api/v1/user"

# Submit a movie request
curl -X POST \
  -H "X-Api-Key: $OVERSEERR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"mediaType":"movie","mediaId":299536}' \
  "$OVERSEERR_URL/api/v1/request"
```

### Webhook Integration

Configure webhooks for external integrations:

```json
{
  "event": "request.created",
  "subject": "New Movie Request",
  "message": "{{user_displayname}} has requested {{media_title}}",
  "media": {
    "tmdbId": 299536,
    "mediaType": "movie",
    "status": "pending"
  }
}
```

## Troubleshooting

### Common Issues

1. **Cannot connect to Plex**
   - Verify Plex server URL and credentials
   - Check network connectivity between pods
   - Ensure Plex allows connections from Overseerr IP
   - Verify Plex token is valid

2. ***arr services not responding**
   - Check service names and ports in Kubernetes
   - Verify API keys are correct
   - Test connectivity: `kubectl exec -it <pod> -- curl http://sonarr:8989`
   - Check network policies

3. **Users cannot access Overseerr**
   - Verify ingress configuration
   - Check DNS resolution
   - Test service connectivity
   - Review authentication settings

4. **Requests not being processed**
   - Check *arr service configurations
   - Verify quality profiles exist
   - Check root folder permissions
   - Review integration logs

5. **Performance issues**
   - Increase memory limits
   - Check database performance
   - Monitor network latency to external services
   - Review log levels

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=overseerr

# View logs
kubectl logs -l app.kubernetes.io/name=overseerr -f

# Check service connectivity
kubectl get svc -l app.kubernetes.io/name=overseerr

# Test Overseerr API
kubectl exec -it <pod-name> -- curl localhost:5055/api/v1/status

# Check configuration
kubectl exec -it <pod-name> -- cat /app/config/settings.json

# Port forward for local testing
kubectl port-forward svc/overseerr 5055:5055
```

### Configuration Issues

Check Overseerr configuration files:

```bash
# View current settings
kubectl exec -it <pod-name> -- ls -la /app/config/

# Check settings file
kubectl exec -it <pod-name> -- cat /app/config/settings.json

# View logs directory
kubectl exec -it <pod-name> -- ls -la /app/config/logs/
```

## Security Considerations

### Essential Security Measures

1. **Authentication**: Configure proper user authentication
2. **Network Policies**: Restrict access to Overseerr and backend services
3. **TLS/SSL**: Use HTTPS for all external access
4. **API Security**: Protect API keys and rotate regularly
5. **Resource Limits**: Prevent resource exhaustion attacks
6. **Regular Updates**: Keep Overseerr updated for security patches

### Security Checklist

- [ ] HTTPS/TLS enabled for external access
- [ ] Strong passwords for admin accounts
- [ ] API keys secured and rotated
- [ ] Network policies configured
- [ ] Resource limits set
- [ ] Regular security updates
- [ ] Backup strategy in place
- [ ] User permission auditing

### Network Security

```yaml
# Example network policy
networkPolicy:
  enabled: true
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: "ingress-nginx"
      ports:
        - protocol: TCP
          port: 5055
  egress:
    # Allow connection to Plex
    - to:
        - namespaceSelector:
            matchLabels:
              name: "media"
      ports:
        - protocol: TCP
          port: 32400
    # Allow connection to *arr services
    - to:
        - namespaceSelector:
            matchLabels:
              name: "media"
      ports:
        - protocol: TCP
          port: 8989  # Sonarr
        - protocol: TCP
          port: 7878  # Radarr
```

## Performance Tuning

### Resource Optimization

For high-user environments:

```yaml
resources:
  limits:
    cpu: 4000m
    memory: 2Gi
  requests:
    cpu: 1000m
    memory: 1Gi
```

### Database Optimization

- Use fast storage for config volume
- Regular database maintenance
- Monitor query performance
- Consider external database for high-scale deployments

### Scaling Considerations

```yaml
hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

## Backup and Recovery

### Configuration Backup

```bash
# Backup Overseerr configuration
kubectl create job backup-overseerr --image=busybox -- tar czf /backup/overseerr-$(date +%Y%m%d).tar.gz /app/config

# Copy backup locally
kubectl cp <pod-name>:/backup/overseerr-$(date +%Y%m%d).tar.gz ./overseerr-backup.tar.gz
```

### Database Backup

Overseerr uses SQLite by default:

```bash
# Backup SQLite database
kubectl exec -it <pod-name> -- sqlite3 /app/config/db/db.sqlite3 ".backup /app/config/backup.db"
```

### Recovery Process

1. Restore configuration files
2. Restart Overseerr pod
3. Verify connections to Plex and *arr services
4. Test user authentication
5. Validate notification settings

## Monitoring and Alerting

### Health Checks

Overseerr provides health endpoints:

- `/api/v1/status` - Application status
- `/api/v1/status/appdata` - Application data status

### Metrics Collection

```yaml
serviceMonitor:
  enabled: true
  interval: "30s"
  path: "/api/v1/status"
```

### Common Alerts

- Application unavailable
- High response times
- Failed external service connections
- High error rates
- Disk space issues

## Migration and Upgrades

### Version Upgrades

1. Backup current configuration
2. Update chart version
3. Review changelog for breaking changes
4. Test in staging environment
5. Perform rolling update
6. Verify functionality

### Data Migration

When migrating from existing installations:

1. Export current configuration
2. Transfer SQLite database
3. Update service URLs if changed
4. Re-verify integrations
5. Test user authentication

## Contributing

Please read our [Contributing Guide](../../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## Maintainers

| Name | Email |
| ---- | ------ |
| Michael Leer | <michael@leer.dev> |

## Source Code

* <https://github.com/sctx/overseerr>
* <https://github.com/linuxserver/docker-overseerr>