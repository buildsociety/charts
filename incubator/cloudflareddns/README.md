# Cloudflare Dynamic DNS Helm Chart

This Helm chart deploys the [hotio/cloudflareddns](https://github.com/hotio/cloudflareddns) container to automatically update Cloudflare DNS records with your dynamic IP address.

## TL;DR

```bash
helm install cloudflareddns ./cloudflareddns \
  --set cloudflareddns.credentials.email="your.email@example.com" \
  --set cloudflareddns.credentials.apiKey="your-api-key" \
  --set cloudflareddns.hosts="subdomain.example.com" \
  --set cloudflareddns.zones="example.com" \
  --set cloudflareddns.recordTypes="A"
```

## Introduction

This chart bootstraps a Cloudflare Dynamic DNS deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Cloudflare account with API access
- Domain(s) managed by Cloudflare

## Installing the Chart

To install the chart with the release name `cloudflareddns`:

```bash
helm install cloudflareddns ./cloudflareddns
```

## Uninstalling the Chart

To uninstall/delete the `cloudflareddns` deployment:

```bash
helm delete cloudflareddns
```

## Configuration

The following table lists the configurable parameters of the Cloudflare Dynamic DNS chart and their default values.

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `ghcr.io/hotio/cloudflareddns` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Cloudflare Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cloudflareddns.env.PUID` | Process user ID | `1000` |
| `cloudflareddns.env.PGID` | Process group ID | `1000` |
| `cloudflareddns.env.UMASK` | File creation mask | `002` |
| `cloudflareddns.env.TZ` | Timezone | `Etc/UTC` |
| `cloudflareddns.env.INTERVAL` | Update interval in seconds | `300` |
| `cloudflareddns.env.DETECTION_MODE` | IP detection method | `dig-whoami.cloudflare` |
| `cloudflareddns.env.LOG_LEVEL` | Log verbosity (0-5) | `3` |

### Credentials

You can use either Email + Global API Key OR API Token:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cloudflareddns.credentials.email` | Cloudflare account email | `""` |
| `cloudflareddns.credentials.apiKey` | Cloudflare global API key | `""` |
| `cloudflareddns.credentials.apiToken` | Cloudflare API token (recommended) | `""` |
| `cloudflareddns.credentials.apiTokenZone` | Zone-specific API token | `""` |
| `cloudflareddns.credentials.existingSecret` | Use existing secret for credentials | `""` |

### DNS Records

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cloudflareddns.hosts` | Semicolon-separated list of hostnames | `""` |
| `cloudflareddns.zones` | Semicolon-separated list of zones | `""` |
| `cloudflareddns.recordTypes` | Semicolon-separated list of record types | `""` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.size` | Size of persistent volume claim | `1Gi` |
| `persistence.accessMode` | Access mode for PVC | `ReadWriteOnce` |
| `persistence.storageClass` | Storage class for PVC | `""` |
| `persistence.existingClaim` | Use existing PVC | `""` |

## Examples

### Basic Configuration with API Key

Create a `values-basic.yaml` file:

```yaml
cloudflareddns:
  credentials:
    email: "your.email@example.com"
    apiKey: "your-global-api-key"
  hosts: "home.example.com;vpn.example.com"
  zones: "example.com;example.com"
  recordTypes: "A;A"
```

Install:
```bash
helm install cloudflareddns ./cloudflareddns -f values-basic.yaml
```

### Using API Token (Recommended)

Create a `values-token.yaml` file:

```yaml
cloudflareddns:
  credentials:
    apiToken: "your-api-token"
  hosts: "home.example.com;office.example.com;vpn.example.com"
  zones: "example.com;example.com;example.com"
  recordTypes: "A;A;AAAA"
  env:
    INTERVAL: "600"  # Check every 10 minutes
    LOG_LEVEL: "4"   # More verbose logging
```

### Multiple Domains

Create a `values-multi.yaml` file:

```yaml
cloudflareddns:
  credentials:
    apiToken: "your-api-token"
  hosts: "home.example.com;home.another.com;vpn.example.com"
  zones: "example.com;another.com;example.com"
  recordTypes: "A;A;A"
```

### Using Existing Secret

First, create a secret:
```bash
kubectl create secret generic cloudflare-creds \
  --from-literal=cf-email=your.email@example.com \
  --from-literal=cf-apikey=your-api-key
```

Then use it in your values:
```yaml
cloudflareddns:
  credentials:
    existingSecret: "cloudflare-creds"
    existingSecretKeys:
      email: "cf-email"
      apiKey: "cf-apikey"
  hosts: "home.example.com"
  zones: "example.com"
  recordTypes: "A"
```

## IP Detection Modes

The following detection modes are available:

- `dig-google.com` - Use Google's DNS
- `dig-opendns.com` - Use OpenDNS
- `dig-whoami.cloudflare` - Use Cloudflare (default)
- `curl-icanhazip.com` - Use icanhazip.com
- `curl-wtfismyip.com` - Use wtfismyip.com
- `curl-ipecho.net` - Use ipecho.net
- `curl-ifconfig.me` - Use ifconfig.me

## Creating a Cloudflare API Token

1. Log in to your Cloudflare account
2. Go to My Profile → API Tokens
3. Click "Create Token"
4. Use the "Edit zone DNS" template or create a custom token with:
   - Permissions: Zone → DNS → Edit
   - Zone Resources: Include → All zones (or specific zones)
5. Copy the token and use it in your configuration

## Troubleshooting

Check the logs:
```bash
kubectl logs deployment/cloudflareddns
```

Common issues:
- **Authentication errors**: Verify your API credentials
- **DNS update failures**: Check that the zones and hosts match exactly
- **IP detection failures**: Try a different detection mode