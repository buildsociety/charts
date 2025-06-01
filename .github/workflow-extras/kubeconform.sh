#!/bin/bash
set -euo pipefail

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/main -- stable | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"
KUBECONFORM_VERSION="${KUBECONFORM_VERSION:-0.6.4}"
KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.28.0}"

# Function to install kubeconform
install_kubeconform() {
    if [[ ! -f "./kubeconform" ]] || [[ ! -x "./kubeconform" ]]; then
        echo "Installing kubeconform v${KUBECONFORM_VERSION}..."
        curl --silent --show-error --fail --location \
            --output /tmp/kubeconform.tar.gz \
            "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz"
        tar -xf /tmp/kubeconform.tar.gz kubeconform
        chmod +x kubeconform
        rm /tmp/kubeconform.tar.gz
    else
        echo "kubeconform already installed"
    fi
}

# Function to validate kubeconform installation
validate_installation() {
    if [[ ! -x "./kubeconform" ]]; then
        echo "❌ kubeconform installation failed"
        exit 1
    fi
    
    local version
    version=$(./kubeconform -v 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    echo "✅ kubeconform v${version} ready"
}

# Function to validate a single chart
validate_chart() {
    local chart_dir="$1"
    echo "Validating ${chart_dir}..."
    
    # Generate manifests and validate
    if ! helm template "${chart_dir}" | ./kubeconform \
        -strict \
        -ignore-missing-schemas \
        -kubernetes-version "${KUBERNETES_VERSION}" \
        -schema-location default \
        -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
        -verbose; then
        echo "❌ Validation failed for ${chart_dir}"
        return 1
    fi
    
    echo "✅ ${chart_dir} validated successfully"
}

# Main execution
echo "Starting Kubernetes manifest validation..."
echo "Kubernetes version: ${KUBERNETES_VERSION}"
echo "Kubeconform version: ${KUBECONFORM_VERSION}"

# Install kubeconform
install_kubeconform
validate_installation

# Check if there are charts to validate
if [[ -z "${CHART_DIRS}" ]]; then
    echo "No charts found to validate"
    exit 0
fi

echo "Charts to validate:"
echo "${CHART_DIRS}" | sed 's/^/  - /'

# Validate each chart
validation_failed=false
for chart_dir in ${CHART_DIRS}; do
    if [[ -d "${chart_dir}" ]]; then
        if ! validate_chart "${chart_dir}"; then
            validation_failed=true
        fi
    else
        echo "⚠️  Chart directory ${chart_dir} not found, skipping"
    fi
done

# Final result
if [[ "${validation_failed}" == "true" ]]; then
    echo "❌ One or more charts failed validation"
    exit 1
fi

echo "✅ All charts validated successfully against Kubernetes ${KUBERNETES_VERSION}"