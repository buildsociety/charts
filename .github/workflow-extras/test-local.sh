#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
HELM_VERSION="3.13.2"
HELM_DOCS_VERSION="1.11.3"
KUBECONFORM_VERSION="0.6.4"
YAMLLINT_VERSION="1.32.0"
KUBERNETES_VERSION="1.28.0"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_dependencies() {
    print_header "Checking Dependencies"
    
    # Check if running in charts directory
    if [[ ! -d "stable" ]]; then
        print_error "Please run this script from the charts repository root"
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is required but not installed"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed"
        exit 1
    fi
    
    print_success "All required dependencies found"
}

install_tools() {
    print_header "Installing/Updating Tools"
    
    # Install Helm
    if ! command -v helm &> /dev/null || [[ "$(helm version --short --client | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" != "${HELM_VERSION}" ]]; then
        print_info "Installing Helm ${HELM_VERSION}..."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        DESIRED_VERSION="v${HELM_VERSION}" ./get_helm.sh
        rm get_helm.sh
    fi
    
    # Install helm-docs
    if [[ ! -f "./helm-docs" ]]; then
        print_info "Installing helm-docs ${HELM_DOCS_VERSION}..."
        curl -fsSL -o helm-docs.tar.gz "https://github.com/norwoodj/helm-docs/releases/download/v${HELM_DOCS_VERSION}/helm-docs_${HELM_DOCS_VERSION}_Linux_x86_64.tar.gz"
        tar -xf helm-docs.tar.gz helm-docs
        chmod +x helm-docs
        rm helm-docs.tar.gz
    fi
    
    # Install kubeconform
    if [[ ! -f "./kubeconform" ]]; then
        print_info "Installing kubeconform ${KUBECONFORM_VERSION}..."
        curl -fsSL -o kubeconform.tar.gz "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz"
        tar -xf kubeconform.tar.gz kubeconform
        chmod +x kubeconform
        rm kubeconform.tar.gz
    fi
    
    # Install yamllint
    if ! command -v yamllint &> /dev/null; then
        print_info "Installing yamllint ${YAMLLINT_VERSION}..."
        pip3 install --user yamllint=="${YAMLLINT_VERSION}"
    fi
    
    # Install chart-testing
    if ! command -v ct &> /dev/null; then
        print_info "Installing chart-testing..."
        curl -fsSL -o ct.tar.gz "https://github.com/helm/chart-testing/releases/download/v3.10.1/chart-testing_3.10.1_linux_amd64.tar.gz"
        tar -xf ct.tar.gz ct
        sudo mv ct /usr/local/bin/
        rm ct.tar.gz
    fi
    
    print_success "All tools installed/updated"
}

setup_helm_repos() {
    print_header "Setting Up Helm Repositories"
    
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo add stable https://charts.helm.sh/stable
    helm repo update
    
    print_success "Helm repositories configured"
}

lint_yaml() {
    print_header "YAML Linting"
    
    if command -v yamllint &> /dev/null; then
        if yamllint -c .yamllint.yaml .; then
            print_success "YAML linting passed"
        else
            print_error "YAML linting failed"
            return 1
        fi
    else
        print_warning "yamllint not found, skipping YAML linting"
    fi
}

lint_charts() {
    print_header "Chart Linting"
    
    local failed=false
    find stable -name "Chart.yaml" -exec dirname {} \; | while read -r chart_dir; do
        print_info "Linting $chart_dir"
        if helm lint "$chart_dir" --strict; then
            print_success "$chart_dir passed linting"
        else
            print_error "$chart_dir failed linting"
            failed=true
        fi
    done
    
    if [[ "$failed" == "true" ]]; then
        return 1
    fi
}

generate_docs() {
    print_header "Generating Documentation"
    
    if [[ -x "./helm-docs" ]]; then
        ./helm-docs --chart-search-root=stable --log-level=info
        
        if git diff --quiet; then
            print_success "Documentation is up to date"
        else
            print_warning "Documentation was updated. Please review and commit changes."
            git diff --name-only
        fi
    else
        print_warning "helm-docs not found, skipping documentation generation"
    fi
}

validate_manifests() {
    print_header "Validating Kubernetes Manifests"
    
    if [[ ! -x "./kubeconform" ]]; then
        print_warning "kubeconform not found, skipping manifest validation"
        return 0
    fi
    
    local failed=false
    find stable -name "Chart.yaml" -exec dirname {} \; | while read -r chart_dir; do
        print_info "Validating manifests for $chart_dir"
        if helm template "$chart_dir" | ./kubeconform \
            -strict \
            -ignore-missing-schemas \
            -kubernetes-version "${KUBERNETES_VERSION}" \
            -schema-location default \
            -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
            -verbose; then
            print_success "$chart_dir manifests are valid"
        else
            print_error "$chart_dir manifest validation failed"
            failed=true
        fi
    done
    
    if [[ "$failed" == "true" ]]; then
        return 1
    fi
}

security_scan() {
    print_header "Security Scanning"
    
    if command -v trivy &> /dev/null; then
        trivy config stable/ --format table
        print_success "Security scan completed"
    else
        print_warning "Trivy not found, skipping security scan"
        print_info "Install with: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
    fi
}

test_charts() {
    print_header "Testing Charts"
    
    if command -v ct &> /dev/null; then
        if ct lint --config .github/workflow-extras/ct.yaml; then
            print_success "Chart testing passed"
        else
            print_error "Chart testing failed"
            return 1
        fi
    else
        print_warning "chart-testing not found, skipping chart tests"
    fi
}

template_charts() {
    print_header "Templating Charts"
    
    local failed=false
    find stable -name "Chart.yaml" -exec dirname {} \; | while read -r chart_dir; do
        print_info "Templating $chart_dir"
        if helm template test "$chart_dir" > /dev/null; then
            print_success "$chart_dir templating successful"
        else
            print_error "$chart_dir templating failed"
            failed=true
        fi
    done
    
    if [[ "$failed" == "true" ]]; then
        return 1
    fi
}

check_versions() {
    print_header "Checking Version Consistency"
    
    find stable -name "Chart.yaml" -exec dirname {} \; | while read -r chart_dir; do
        local chart_version
        local app_version
        chart_version=$(grep "^version:" "$chart_dir/Chart.yaml" | cut -d' ' -f2)
        app_version=$(grep "^appVersion:" "$chart_dir/Chart.yaml" | cut -d' ' -f2 | tr -d '"')
        
        print_info "Chart: $chart_dir"
        print_info "  Chart version: $chart_version"
        print_info "  App version: $app_version"
        
        if [[ ! $chart_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            print_error "Chart version $chart_version doesn't follow semantic versioning"
            return 1
        fi
        
        print_success "Version format valid for $chart_dir"
    done
}

update_dependencies() {
    print_header "Updating Dependencies"
    
    find stable -name "Chart.yaml" -exec dirname {} \; | while read -r chart_dir; do
        if [[ -f "$chart_dir/Chart.yaml" ]] && grep -q "^dependencies:" "$chart_dir/Chart.yaml"; then
            print_info "Updating dependencies for $chart_dir"
            helm dependency update "$chart_dir"
        fi
    done
    
    print_success "Dependencies updated"
}

cleanup() {
    print_header "Cleaning Up"
    
    # Remove downloaded tools if they exist
    [[ -f "./helm-docs" ]] && rm -f ./helm-docs
    [[ -f "./kubeconform" ]] && rm -f ./kubeconform
    
    print_success "Cleanup completed"
}

show_help() {
    echo "Usage: $0 [OPTIONS] [COMMANDS]"
    echo ""
    echo "Local testing script for Helm charts"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --cleanup  Clean up downloaded tools after testing"
    echo "  -q, --quick    Run quick tests only (lint, template)"
    echo ""
    echo "COMMANDS (run all if none specified):"
    echo "  deps           Check and install dependencies"
    echo "  repos          Set up Helm repositories"
    echo "  yaml-lint      Lint YAML files"
    echo "  chart-lint     Lint Helm charts"
    echo "  docs           Generate documentation"
    echo "  validate       Validate Kubernetes manifests"
    echo "  security       Run security scan"
    echo "  test           Run chart tests"
    echo "  template       Template charts"
    echo "  versions       Check version consistency"
    echo "  update-deps    Update chart dependencies"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 -q                 # Run quick tests"
    echo "  $0 chart-lint docs    # Run only chart linting and docs generation"
    echo "  $0 -c                 # Run all tests and cleanup"
}

main() {
    local commands=()
    local cleanup_after=false
    local quick_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--cleanup)
                cleanup_after=true
                shift
                ;;
            -q|--quick)
                quick_mode=true
                shift
                ;;
            deps|repos|yaml-lint|chart-lint|docs|validate|security|test|template|versions|update-deps)
                commands+=("$1")
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Set default commands if none specified
    if [[ ${#commands[@]} -eq 0 ]]; then
        if [[ "$quick_mode" == "true" ]]; then
            commands=(deps repos chart-lint template)
        else
            commands=(deps repos yaml-lint chart-lint docs validate security test template versions)
        fi
    fi
    
    print_header "Starting Local Chart Testing"
    print_info "Running commands: ${commands[*]}"
    
    local failed=false
    
    # Run selected commands
    for cmd in "${commands[@]}"; do
        case $cmd in
            deps)
                check_dependencies && install_tools || failed=true
                ;;
            repos)
                setup_helm_repos || failed=true
                ;;
            yaml-lint)
                lint_yaml || failed=true
                ;;
            chart-lint)
                lint_charts || failed=true
                ;;
            docs)
                generate_docs || failed=true
                ;;
            validate)
                validate_manifests || failed=true
                ;;
            security)
                security_scan || failed=true
                ;;
            test)
                test_charts || failed=true
                ;;
            template)
                template_charts || failed=true
                ;;
            versions)
                check_versions || failed=true
                ;;
            update-deps)
                update_dependencies || failed=true
                ;;
        esac
    done
    
    # Cleanup if requested
    if [[ "$cleanup_after" == "true" ]]; then
        cleanup
    fi
    
    # Final result
    print_header "Testing Complete"
    if [[ "$failed" == "true" ]]; then
        print_error "Some tests failed. Please review the output above."
        exit 1
    else
        print_success "All tests passed successfully!"
    fi
}

# Run main function with all arguments
main "$@"