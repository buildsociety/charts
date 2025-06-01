# Homer Helm Chart

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 20.07.2](https://img.shields.io/badge/AppVersion-20.07.2-informational?style=flat-square)

## Description

A Helm chart for Homer - A very simple static homepage for your server

## Features

🏠 **Simple Dashboard** - Clean and customizable homepage for all your services  
🎨 **Themeable** - Light and dark themes with custom color schemes  
📱 **Responsive** - Works great on desktop and mobile devices  
🔧 **Easy Configuration** - Simple YAML-based configuration  
⚡ **Fast & Lightweight** - Static site with minimal resource usage  

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installation

### Add the Helm repository

```bash
helm repo add trozz https://trozz.github.io/charts
helm repo update
```

### Install the chart

```bash
helm install homer trozz/homer --namespace homer --create-namespace
```

### Install with custom values

```bash
helm install homer trozz/homer -f values.yaml --namespace homer --create-namespace
```

## Configuration

The following table lists the configurable parameters of the Homer chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of Homer replicas | `1` |
| `title.text` | Dashboard title text | `"Homer"` |
| `title.icon` | Dashboard title icon | `fas fa-home` |
| `header` | Show header | `true` |
| `footer` | Show footer | `false` |
| `message.style` | Message style (Bulma CSS classes) | `"is-warning"` |
| `message.title` | Message title | `"Optional message!"` |
| `message.content` | Message content | `"Lorem ipsum..."` |
| `links` | Header links array | See values.yaml |
| `columns` | Number of columns (auto, 3, 4, 5) | `auto` |
| `connectivityCheck` | Enable connectivity check | `false` |
| `theme` | Default theme | `default` |
| `colors.light` | Light theme colors | See values.yaml |
| `colors.dark` | Dark theme colors | See values.yaml |
| `services` | Service groups and items | See values.yaml |
| `image.repository` | Homer image repository | `b4bz/homer` |
| `image.tag` | Homer image tag | `20.07.2` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full chart name | `""` |
| `podSecurityContext` | Pod security context | See values.yaml |
| `securityContext` | Container security context | See values.yaml |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts | `[{host: "homer.internal", paths: ["/"]}]` |
| `ingress.tls` | Ingress TLS configuration | See values.yaml |
| `resources` | Resource limits and requests | `{}` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity | `{}` |

## Examples

### Basic Installation

```yaml
# values-basic.yaml
title:
  text: "My Dashboard"
  icon: fas fa-server

services:
  - name: "My Apps"
    icon: fas fa-cloud
    items:
      - name: "Application 1"
        icon: fas fa-code
        url: "https://app1.example.com"
        target: "_blank"
      - name: "Application 2"
        icon: fas fa-database
        url: "https://app2.example.com"
        target: "_blank"

ingress:
  enabled: false
```

### Production Setup with Custom Theme

```yaml
# values-production.yaml
title:
  text: "Production Dashboard"
  icon: fas fa-server

message:
  style: "is-info"
  title: "Welcome!"
  content: "This is our production service dashboard."

links:
  - name: "Wiki"
    icon: fas fa-book
    url: "https://wiki.example.com"
  - name: "GitHub"
    icon: fab fa-github
    url: "https://github.com/yourorg"
  - name: "Email"
    icon: fas fa-envelope
    url: "mailto:admin@example.com"

theme: dark

colors:
  dark:
    highlight_primary: "#007bff"
    highlight_secondary: "#6c757d"
    highlight_hover: "#0056b3"
    background: "#1a1a1a"
    card_background: "#2d2d2d"
    text: "#f8f9fa"
    text_header: "#ffffff"
    text_title: "#ffffff"
    text_subtitle: "#dee2e6"
    card_shadow: "rgba(0, 0, 0, 0.5)"
    link_hover: "#007bff"

services:
  - name: "Infrastructure"
    icon: fas fa-server
    items:
      - name: "Kubernetes Dashboard"
        icon: fas fa-dharmachakra
        subtitle: "Cluster management"
        url: "https://k8s.example.com"
        target: "_blank"
      - name: "Grafana"
        icon: fas fa-chart-line
        subtitle: "Metrics & monitoring"
        url: "https://grafana.example.com"
        target: "_blank"
      - name: "Prometheus"
        icon: fas fa-fire
        subtitle: "Metrics collection"
        url: "https://prometheus.example.com"
        target: "_blank"
  
  - name: "Applications"
    icon: fas fa-globe
    items:
      - name: "GitLab"
        icon: fab fa-gitlab
        subtitle: "Code repository"
        url: "https://gitlab.example.com"
        target: "_blank"
      - name: "Jenkins"
        icon: fas fa-industry
        subtitle: "CI/CD pipelines"
        url: "https://jenkins.example.com"
        target: "_blank"

ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: homer-basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
  hosts:
    - host: dashboard.example.com
      paths:
        - /
  tls:
    - secretName: homer-tls
      hosts:
        - dashboard.example.com

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

### Multi-Environment Dashboard

```yaml
# values-multi-env.yaml
title:
  text: "Environment Hub"
  icon: fas fa-network-wired

columns: 3

services:
  - name: "Development"
    icon: fas fa-code-branch
    items:
      - name: "Dev Kubernetes"
        icon: fas fa-dharmachakra
        subtitle: "Development cluster"
        tag: "k8s"
        tagstyle: "is-success"
        url: "https://dev-k8s.example.com"
      - name: "Dev Apps"
        icon: fas fa-rocket
        subtitle: "Development applications"
        url: "https://dev.example.com"
  
  - name: "Staging"
    icon: fas fa-theater-masks
    items:
      - name: "Staging Kubernetes"
        icon: fas fa-dharmachakra
        subtitle: "Staging cluster"
        tag: "k8s"
        tagstyle: "is-warning"
        url: "https://staging-k8s.example.com"
      - name: "Staging Apps"
        icon: fas fa-rocket
        subtitle: "Staging applications"
        url: "https://staging.example.com"
  
  - name: "Production"
    icon: fas fa-industry
    items:
      - name: "Prod Kubernetes"
        icon: fas fa-dharmachakra
        subtitle: "Production cluster"
        tag: "k8s"
        tagstyle: "is-danger"
        url: "https://prod-k8s.example.com"
      - name: "Prod Apps"
        icon: fas fa-rocket
        subtitle: "Production applications"
        url: "https://prod.example.com"
```

## Service Configuration

Each service item can have the following properties:

```yaml
services:
  - name: "Group Name"
    icon: "fas fa-icon"
    items:
      - name: "Service Name"
        subtitle: "Optional description"
        icon: "fas fa-icon"
        url: "https://service.url"
        target: "_blank"  # or "_self"
        tag: "optional-tag"
        tagstyle: "is-info"  # Bulma tag styles
```

## Custom Themes

You can customize the appearance by modifying the color values:

```yaml
colors:
  light:
    highlight_primary: "#3367d6"
    highlight_secondary: "#4285f4"
    highlight_hover: "#5a95f5"
    background: "#f5f5f5"
    card_background: "#ffffff"
    text: "#363636"
    text_header: "#424242"
    text_title: "#303030"
    text_subtitle: "#424242"
    card_shadow: "rgba(0, 0, 0, 0.1)"
    link_hover: "#363636"
  dark:
    # Dark theme colors...
```

## Security Considerations

1. **Basic Authentication**: Use ingress annotations to add basic auth
2. **Network Policies**: Restrict access to the dashboard
3. **Read-only Filesystem**: Default security context uses read-only root filesystem

### Adding Basic Authentication

```bash
# Create auth file
htpasswd -c auth admin

# Create secret
kubectl create secret generic homer-basic-auth --from-file=auth -n homer

# Add to ingress annotations
nginx.ingress.kubernetes.io/auth-type: basic
nginx.ingress.kubernetes.io/auth-secret: homer-basic-auth
```

## Troubleshooting

### Common Issues

1. **Dashboard not loading**
   - Check pod logs: `kubectl logs -l app.kubernetes.io/name=homer -n homer`
   - Verify ingress configuration
   - Check service endpoints

2. **Custom configuration not applied**
   - Ensure values are properly formatted YAML
   - Check ConfigMap is mounted correctly
   - Verify no syntax errors in configuration

## Upgrading

```bash
helm upgrade homer trozz/homer -n homer
```

## Uninstallation

```bash
helm uninstall homer -n homer
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This Helm chart is distributed under the MIT License.

## Links

- [Homer GitHub Repository](https://github.com/bastienwirtz/homer)
- [Chart Repository](https://github.com/trozz/charts)
- [Font Awesome Icons](https://fontawesome.com/icons)