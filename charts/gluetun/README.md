# Gluetun

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v3.37.0](https://img.shields.io/badge/AppVersion-v3.37.0-informational?style=flat-square)

A Helm chart for Gluetun - Lightweight VPN client with HTTP proxy, SOCKS5 proxy, and Shadowsocks

**Homepage:** <https://github.com/qdm12/gluetun>

## Description

Gluetun is a lightweight VPN client with multiple proxy services built-in. Unlike traditional VPN clients, Gluetun is designed to run as a standalone service that provides secure tunneling for multiple applications through various proxy protocols.

This Helm chart deploys Gluetun as a **standalone VPN gateway service** on Kubernetes, exposing proxy services both internally to the cluster and optionally externally. Perfect for providing shared VPN access to multiple applications or creating a secure proxy gateway.

## Features

- 🔒 **Multi-Provider VPN Support**: Works with 60+ VPN providers (NordVPN, Mullvad, PIA, ExpressVPN, Surfshark, etc.)
- 🌐 **Multiple Proxy Protocols**: HTTP proxy, SOCKS5 proxy, and Shadowsocks
- 🔧 **Dual Service Exposure**: Internal cluster access and optional external exposure
- 📊 **Control API**: RESTful API for monitoring and configuration
- 🚀 **Production Ready**: Health checks, resource management, and security contexts
- 📈 **Monitoring**: Optional Prometheus ServiceMonitor support
- 🛡️ **Security**: Network policies and firewall rules
- ⚡ **High Performance**: Lightweight and optimized for containerized environments
- 🔄 **Auto-Healing**: Automatic reconnection and server switching
- 🌍 **Port Forwarding**: Support for VPN port forwarding when available

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure
- **VPN provider credentials** (required)
- NET_ADMIN capability support in cluster

## Installing the Chart

To install the chart with the release name `gluetun`:

```bash
helm install gluetun ./charts/incubator/gluetun
```

**Important:** You must configure VPN credentials before deployment:

```bash
helm install gluetun ./charts/incubator/gluetun -f values-pia.yaml
```

To install with custom values:

```bash
helm install gluetun ./charts/incubator/gluetun -f my-values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `gluetun` deployment:

```bash
helm delete gluetun
```

## Configuration

### Basic Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.enabled` | Enable Gluetun | `true` |
| `gluetun.image.repository` | Gluetun image repository | `ghcr.io/qdm12/gluetun` |
| `gluetun.image.tag` | Gluetun image tag | `latest` |
| `gluetun.env.TZ` | Timezone | `Europe/London` |
| `gluetun.env.LOG_LEVEL` | Log level | `info` |

### Service Configuration

#### Internal Service (Cluster Access)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.service.internal.enabled` | Enable internal service | `true` |
| `gluetun.service.internal.type` | Service type for cluster access | `ClusterIP` |
| `gluetun.service.internal.ports.httpProxy.port` | HTTP proxy port | `8888` |
| `gluetun.service.internal.ports.shadowsocksTcp.port` | Shadowsocks TCP port | `8388` |
| `gluetun.service.internal.ports.shadowsocksUdp.port` | Shadowsocks UDP port | `8388` |
| `gluetun.service.internal.ports.socks5.port` | SOCKS5 proxy port | `1080` |
| `gluetun.service.internal.ports.control.port` | Control API port | `8000` |

#### External Service (External Access)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.service.external.enabled` | Enable external service | `false` |
| `gluetun.service.external.type` | Service type for external access | `NodePort` |
| `gluetun.service.external.ports.httpProxy.nodePort` | HTTP proxy NodePort | `30888` |
| `gluetun.service.external.ports.shadowsocksTcp.nodePort` | Shadowsocks TCP NodePort | `30388` |
| `gluetun.service.external.ports.shadowsocksUdp.nodePort` | Shadowsocks UDP NodePort | `30389` |
| `gluetun.service.external.ports.socks5.nodePort` | SOCKS5 NodePort | `31080` |
| `gluetun.service.external.ports.control.nodePort` | Control API NodePort | `30800` |

### VPN Provider Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.vpn.pia.enabled` | Enable Private Internet Access | `true` |
| `gluetun.vpn.pia.username` | PIA username | `""` |
| `gluetun.vpn.pia.password` | PIA password | `""` |
| `gluetun.vpn.pia.serverRegions` | PIA server regions | `UK London` |
| `gluetun.vpn.nordvpn.enabled` | Enable NordVPN | `false` |
| `gluetun.vpn.mullvad.enabled` | Enable Mullvad | `false` |

## Service Ports

Gluetun exposes multiple proxy services:

### Internal Cluster Access

- **HTTP Proxy**: `gluetun:8888` - Standard HTTP proxy for web traffic
- **SOCKS5 Proxy**: `gluetun:1080` - SOCKS5 proxy for any TCP/UDP traffic
- **Shadowsocks**: `gluetun:8388` (TCP/UDP) - Encrypted proxy protocol
- **Control API**: `gluetun:8000` - RESTful API for monitoring and control

### External Access (Optional)

When external service is enabled with NodePort:
- **HTTP Proxy**: `<node-ip>:30888`
- **SOCKS5 Proxy**: `<node-ip>:31080`
- **Shadowsocks**: `<node-ip>:30388` (TCP/UDP)
- **Control API**: `<node-ip>:30800`

## VPN Providers

Gluetun supports 60+ VPN providers. Configure one provider at a time:

### Supported Providers

- **Private Internet Access (PIA)** - OpenVPN with port forwarding
- **NordVPN** - WireGuard and OpenVPN
- **Mullvad** - WireGuard
- **ExpressVPN** - OpenVPN
- **Surfshark** - OpenVPN
- **Custom** - Bring your own OpenVPN config

### Provider Configuration Examples

#### Private Internet Access (PIA)

```yaml
gluetun:
  vpn:
    pia:
      enabled: true
      username: "your-pia-username"
      password: "your-pia-password"
      serverRegions: "UK London"
```

#### NordVPN

```yaml
gluetun:
  vpn:
    nordvpn:
      enabled: true
      privateKey: "your-wireguard-private-key"
      serverCountries: "United Kingdom"
```

#### Mullvad

```yaml
gluetun:
  vpn:
    mullvad:
      enabled: true
      privateKey: "your-wireguard-private-key"
      addresses: "10.64.0.1/32"
      serverCities: "London"
```

## Examples

### Basic Internal-Only Deployment

```yaml
# values-internal.yaml
gluetun:
  vpn:
    pia:
      enabled: true
      username: "your-username"
      password: "your-password"
      serverRegions: "US East"

  service:
    internal:
      enabled: true
    external:
      enabled: false
```

### External Access with NodePort

```yaml
# values-external.yaml
gluetun:
  vpn:
    pia:
      enabled: true
      username: "your-username" 
      password: "your-password"
      serverRegions: "UK London"

  service:
    internal:
      enabled: true
    external:
      enabled: true
      type: NodePort
      ports:
        httpProxy:
          nodePort: 30888
        socks5:
          nodePort: 31080
        shadowsocksTcp:
          nodePort: 30388
        control:
          nodePort: 30800
```

### Production Configuration with LoadBalancer

```yaml
# values-production.yaml
gluetun:
  vpn:
    pia:
      enabled: true
      username: "your-username"
      password: "your-password"
      serverRegions: "UK London"

  service:
    internal:
      enabled: true
    external:
      enabled: true
      type: LoadBalancer
      loadBalancerSourceRanges:
        - "10.0.0.0/8"
        - "172.16.0.0/12"
        - "192.168.0.0/16"

  resources:
    limits:
      cpu: 2000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

  persistence:
    enabled: true
    storageClass: "fast-ssd"
    size: 2Gi

  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: gluetun.example.com
        paths:
          - path: /
            pathType: Prefix

networkPolicy:
  enabled: true

serviceMonitor:
  enabled: true
```

### High-Performance Configuration

```yaml
# values-high-performance.yaml
gluetun:
  vpn:
    mullvad:
      enabled: true
      privateKey: "your-wireguard-private-key"
      addresses: "10.64.0.1/32"
      serverCities: "London,Manchester"

  resources:
    limits:
      cpu: 4000m
      memory: 2Gi
    requests:
      cpu: 1000m
      memory: 1Gi

  env:
    LOG_LEVEL: "debug"
    VPN_PORT_FORWARDING: "on"
    UPDATER_PERIOD: "12h"

pod:
  nodeSelector:
    node-type: "high-performance"
  tolerations:
    - key: "vpn-workload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
```

## Using Gluetun Services

### HTTP Proxy

Configure applications to use HTTP proxy:

```bash
# Environment variables
export http_proxy=http://gluetun:8888
export https_proxy=http://gluetun:8888

# Curl example
curl -x gluetun:8888 https://httpbin.org/ip
```

### SOCKS5 Proxy

Configure applications to use SOCKS5 proxy:

```bash
# Curl example
curl --socks5 gluetun:1080 https://httpbin.org/ip

# SSH tunnel example
ssh -D 1080 -N user@gluetun
```

### Shadowsocks

Configure Shadowsocks clients:

```yaml
# Shadowsocks config
server: gluetun
server_port: 8388
method: chacha20-ietf-poly1305
password: gluetun
```

## Integration with Applications

### Kubernetes Applications

Configure other applications to use Gluetun as proxy:

```yaml
# Example: Application using Gluetun HTTP proxy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
        - name: my-app
          image: my-app:latest
          env:
            - name: HTTP_PROXY
              value: "http://gluetun:8888"
            - name: HTTPS_PROXY
              value: "http://gluetun:8888"
            - name: NO_PROXY
              value: "localhost,127.0.0.1,10.96.0.0/12"
```

### Docker Compose Integration

```yaml
# docker-compose.yml
version: "3.8"
services:
  my-app:
    image: my-app:latest
    environment:
      - HTTP_PROXY=http://gluetun:8888
      - HTTPS_PROXY=http://gluetun:8888
    depends_on:
      - gluetun
    external_links:
      - gluetun:gluetun
```

## Control API

Gluetun provides a comprehensive REST API for monitoring and control:

### Common Endpoints

- `GET /v1/openvpn/status` - VPN connection status
- `GET /v1/publicip/ip` - Current public IP address
- `GET /v1/openvpn/portforwarded` - Port forwarding status
- `GET /v1/dns/status` - DNS configuration status
- `PUT /v1/openvpn/stop` - Stop VPN connection
- `PUT /v1/openvpn/start` - Start VPN connection

### API Usage Examples

```bash
# Check VPN status
curl gluetun:8000/v1/openvpn/status

# Get current public IP
curl gluetun:8000/v1/publicip/ip

# Check port forwarding
curl gluetun:8000/v1/openvpn/portforwarded

# Restart VPN connection
curl -X PUT gluetun:8000/v1/openvpn/stop
curl -X PUT gluetun:8000/v1/openvpn/start
```

## Troubleshooting

### Common Issues

1. **VPN connection fails**
   - Verify VPN credentials are correct
   - Check logs: `kubectl logs <pod-name>`
   - Test different server regions/cities
   - Ensure NET_ADMIN capability is available

2. **Proxy services not accessible**
   - Verify service is running: `kubectl get svc`
   - Check port-forward: `kubectl port-forward svc/gluetun 8888:8888`
   - Test connectivity: `curl -x localhost:8888 https://httpbin.org/ip`

3. **Performance issues**
   - Increase resource limits
   - Try different VPN servers
   - Check network policies
   - Monitor CPU/memory usage

4. **DNS resolution problems**
   - Check DNS status: `curl gluetun:8000/v1/dns/status`
   - Verify firewall rules
   - Test with different DNS servers

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=gluetun

# View logs
kubectl logs -l app.kubernetes.io/name=gluetun -f

# Check services
kubectl get svc -l app.kubernetes.io/name=gluetun

# Test proxy connectivity
kubectl exec -it <pod-name> -- wget -qO- --proxy=on --proxy-host=localhost --proxy-port=8888 https://httpbin.org/ip

# Check VPN status via API
kubectl exec -it <pod-name> -- wget -qO- localhost:8000/v1/openvpn/status

# Port forward for local testing
kubectl port-forward svc/gluetun 8888:8888 8000:8000 1080:1080
```

### Performance Monitoring

Monitor these key metrics:

- VPN connection stability
- Proxy response times  
- Network throughput
- CPU and memory usage
- Connection count

```bash
# Monitor real-time metrics
kubectl top pods -l app.kubernetes.io/name=gluetun

# Check service endpoints
kubectl get endpoints gluetun

# Test proxy performance
curl -w "@curl-format.txt" -x gluetun:8888 https://httpbin.org/ip
```

## Security Considerations

### Essential Security Measures

1. **Credentials Management**: Store VPN credentials in Kubernetes secrets
2. **Network Policies**: Restrict access to proxy services
3. **Resource Limits**: Prevent resource exhaustion
4. **Regular Updates**: Keep Gluetun image updated
5. **Monitoring**: Enable logging and monitoring

### Security Checklist

- [ ] VPN credentials stored in secrets
- [ ] Network policies configured
- [ ] Resource limits set
- [ ] External access secured (if enabled)
- [ ] Monitoring enabled
- [ ] Regular security updates
- [ ] Firewall rules configured

### Network Security

```yaml
# Example network policy
networkPolicy:
  enabled: true
  ingress:
    # Allow proxy access from specific namespaces
    - from:
        - namespaceSelector:
            matchLabels:
              name: "apps"
      ports:
        - protocol: TCP
          port: 8888
        - protocol: TCP
          port: 1080
```

## Performance Tuning

### Resource Optimization

For high-traffic scenarios:

```yaml
resources:
  limits:
    cpu: 4000m
    memory: 2Gi
  requests:
    cpu: 1000m
    memory: 1Gi
```

### Network Optimization

- Use WireGuard when available (faster than OpenVPN)
- Choose geographically close VPN servers
- Enable port forwarding for better P2P performance
- Use appropriate MTU sizes

### Scaling Considerations

While Gluetun typically runs as a single instance:

- Use multiple instances in different regions for geographic distribution
- Load balance between instances for high availability
- Monitor connection limits and adjust accordingly

## Advanced Configuration

### Custom OpenVPN Configuration

```yaml
gluetun:
  vpn:
    custom:
      enabled: true
      configFileContent: |
        client
        dev tun
        proto udp
        remote your-server.com 1194
        # ... your OpenVPN config
```

### Firewall Customization

```yaml
gluetun:
  env:
    FIREWALL_OUTBOUND_SUBNETS: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
    FIREWALL_VPN_INPUT_PORTS: "12345,54321"
```

## Monitoring and Alerting

### Prometheus Integration

```yaml
serviceMonitor:
  enabled: true
  interval: "30s"
  path: "/v1/metrics"
```

### Custom Alerts

Common alerting scenarios:
- VPN connection down
- High proxy error rate
- Resource exhaustion
- External IP changes

## Migration and Backup

### Configuration Backup

```bash
# Backup VPN configuration
kubectl get secret gluetun-vpn -o yaml > gluetun-vpn-backup.yaml

# Backup PVC data
kubectl create job backup-gluetun --image=busybox -- tar czf /backup/gluetun-$(date +%Y%m%d).tar.gz /data
```

### Disaster Recovery

1. Restore secrets and PVCs
2. Redeploy with same configuration
3. Verify VPN connectivity
4. Test all proxy services

## Contributing

Please read our [Contributing Guide](../../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## Maintainers

| Name | Email |
| ---- | ------ |
| Michael Leer | <michael@leer.dev> |

## Source Code

* <https://github.com/qdm12/gluetun>
* <https://github.com/qdm12/gluetun-wiki>