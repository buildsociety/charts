# GitHub Actions for Helm Charts

This directory contains the complete CI/CD pipeline configuration for the Helm charts repository, including workflows, scripts, and configuration files that ensure chart quality, security, and reliability.

## Overview

Our GitHub Actions setup provides:
- **Automated Testing**: Comprehensive chart validation and testing
- **Security Scanning**: Vulnerability detection and best practices validation
- **Quality Assurance**: Code quality checks and documentation validation
- **Automated Releases**: Streamlined chart publishing process
- **Dependency Management**: Automated dependency updates

## Workflows

### 1. CI Pipeline (`workflows/ci.yaml`)

**Triggers**: Pull requests to `stable/**`

**What it does**:
- Lints Helm charts with strict validation
- Generates and validates documentation
- Scans for security vulnerabilities using Trivy
- Validates Kubernetes manifests against multiple K8s versions
- Tests chart installation on kind clusters

**Jobs**:
- `lint-chart`: Helm chart linting and validation
- `lint-docs`: Documentation generation and validation
- `security-scan`: Trivy vulnerability scanning
- `validate-manifests`: Kubernetes manifest validation (K8s 1.26-1.29)
- `install-chart`: Chart installation testing

### 2. Release Pipeline (`workflows/release.yaml`)

**Triggers**: Push to `main` branch with changes in `stable/**`

**What it does**:
- Creates GitHub releases for updated charts
- Publishes charts to GitHub Pages
- Generates release notes automatically
- Updates the chart repository index

### 3. Code Quality (`workflows/code-quality.yaml`)

**Triggers**: Pull requests and pushes to main branches

**What it does**:
- YAML linting for consistent formatting
- Chart schema validation
- Security best practices validation with Checkov
- Documentation completeness checks
- Version consistency validation
- License compliance verification

### 4. Dependency Updates (`workflows/dependency-update.yaml`)

**Triggers**: Weekly schedule (Mondays at 2 AM) and manual dispatch

**What it does**:
- Updates Helm chart dependencies automatically
- Creates pull requests with dependency updates
- Provides detailed change summaries

## Scripts and Tools

### Core Scripts

#### `workflow-extras/helm-docs.sh`
Generates and validates chart documentation using helm-docs.

**Features**:
- Automatic tool installation with caching
- Validation of documentation completeness
- Clear error reporting

#### `workflow-extras/kubeconform.sh`
Validates Kubernetes manifests using kubeconform (replaces deprecated kubeval).

**Features**:
- Multi-version Kubernetes validation
- CRD support via external schema sources
- Comprehensive error reporting

#### `workflow-extras/test-local.sh`
Comprehensive local testing script for developers.

**Usage**:
```bash
# Run all tests
./.github/workflow-extras/test-local.sh

# Quick tests only
./.github/workflow-extras/test-local.sh -q

# Specific tests
./.github/workflow-extras/test-local.sh chart-lint docs

# Show help
./.github/workflow-extras/test-local.sh -h
```

### Configuration Files

#### `workflow-extras/ct.yaml`
Chart testing configuration with enhanced validation settings.

#### `workflow-extras/cr.yaml`
Chart releaser configuration for automated releases.

#### `.yamllint.yaml`
YAML linting rules optimized for Helm charts.

## Local Development

### Prerequisites

- Docker
- Git
- Python 3.x (for yamllint)

### Quick Start

1. **Run Local Tests**:
   ```bash
   ./.github/workflow-extras/test-local.sh -q
   ```

2. **Full Validation**:
   ```bash
   ./.github/workflow-extras/test-local.sh
   ```

3. **Generate Documentation**:
   ```bash
   ./.github/workflow-extras/helm-docs.sh
   ```

### Development Workflow

1. **Before Making Changes**:
   - Run `test-local.sh -q` for quick validation
   - Ensure your environment meets the prerequisites

2. **During Development**:
   - Use `helm lint` for immediate feedback
   - Run `helm template` to validate templating
   - Check YAML formatting with `yamllint`

3. **Before Committing**:
   - Run full test suite: `test-local.sh`
   - Generate documentation: `helm-docs.sh`
   - Commit generated documentation changes

4. **Pull Request Guidelines**:
   - All CI checks must pass
   - Documentation must be current
   - Security scans must be clean
   - Chart version must be incremented

## Security

### Vulnerability Scanning

- **Trivy**: Scans for known vulnerabilities in configurations
- **Checkov**: Validates security best practices
- **SARIF Integration**: Results appear in GitHub Security tab

### Best Practices

- Never commit secrets or credentials
- Use least-privilege permissions
- Regularly update dependencies
- Follow Kubernetes security guidelines
- Validate all external inputs

## Troubleshooting

### Common Issues

#### Permission Errors
```bash
# Make scripts executable
chmod +x .github/workflow-extras/*.sh
```

#### Missing Tools
```bash
# Use the local test script to install tools
./.github/workflow-extras/test-local.sh deps
```

#### YAML Linting Errors
```bash
# Check YAML formatting
yamllint -c .yamllint.yaml .
```

#### Chart Validation Failures
```bash
# Test specific chart
helm lint stable/your-chart --strict
helm template stable/your-chart
```

### Debug Mode

Enable debug output in workflows by setting:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

## Performance Optimization

### Caching Strategy

- **Helm Dependencies**: Cached by `Chart.yaml` hash
- **Tool Binaries**: Cached by version number
- **Repository Data**: Helm repositories cached per workflow

### Parallel Execution

- Security scanning runs parallel to validation
- Multiple Kubernetes versions tested concurrently
- Independent jobs execute simultaneously

## Contributing

### Adding New Workflows

1. Create workflow file in `.github/workflows/`
2. Follow existing naming conventions
3. Include appropriate triggers and permissions
4. Add comprehensive job descriptions
5. Test thoroughly before merging

### Updating Existing Workflows

1. Test changes locally when possible
2. Use workflow dispatch for testing
3. Monitor execution times and resource usage
4. Update documentation accordingly

### Script Modifications

1. Maintain backward compatibility
2. Include error handling and validation
3. Add appropriate logging and output
4. Test on multiple platforms if applicable

## Monitoring

### Workflow Status

Monitor workflow execution in the Actions tab:
- Green checkmarks indicate successful runs
- Red X marks indicate failures requiring attention
- Yellow dots indicate workflows in progress

### Security Alerts

Check the Security tab for:
- Vulnerability scan results
- Security best practice violations
- Dependency security issues

### Performance Metrics

Track workflow performance:
- Execution time trends
- Cache hit rates
- Resource utilization
- Failure rates

## Support

For issues with the GitHub Actions setup:

1. **Check Recent Changes**: Review recent commits for breaking changes
2. **Review Logs**: Examine workflow logs for specific errors
3. **Local Testing**: Use `test-local.sh` to reproduce issues
4. **Create Issues**: Open GitHub issues with detailed error information

---

## Version History

- **v2.0**: Complete modernization with security scanning and enhanced validation
- **v1.5**: Added dependency update automation
- **v1.4**: Introduced code quality workflows
- **v1.3**: Enhanced caching and performance optimizations
- **v1.2**: Updated to modern GitHub Actions
- **v1.1**: Added local testing capabilities
- **v1.0**: Initial GitHub Actions implementation