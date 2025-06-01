#!/bin/bash
set -euo pipefail


HELM_DOCS_VERSION="1.11.3"

# Function to install helm-docs
install_helm_docs() {
    if [[ ! -f "./helm-docs" ]] || [[ ! -x "./helm-docs" ]]; then
        echo "Installing helm-docs v${HELM_DOCS_VERSION}..."
        curl --silent --show-error --fail --location \
            --output /tmp/helm-docs.tar.gz \
            "https://github.com/norwoodj/helm-docs/releases/download/v${HELM_DOCS_VERSION}/helm-docs_${HELM_DOCS_VERSION}_Linux_x86_64.tar.gz"
        tar -xf /tmp/helm-docs.tar.gz helm-docs
        chmod +x helm-docs
        rm /tmp/helm-docs.tar.gz
    else
        echo "helm-docs already installed"
    fi
}

# Function to validate helm-docs installation
validate_installation() {
    if [[ ! -x "./helm-docs" ]]; then
        echo "❌ helm-docs installation failed"
        exit 1
    fi
    
    local version
    version=$(./helm-docs --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    echo "✅ helm-docs v${version} ready"
}

# Install and validate
install_helm_docs
validate_installation

echo "Generating documentation..."
./helm-docs --chart-search-root=stable --log-level=info

echo "Checking for documentation changes..."
if ! git diff --exit-code; then
    echo "❌ Documentation is out of date. Please run 'helm-docs' and commit the changes."
    echo ""
    echo "Changed files:"
    git diff --name-only
    exit 1
fi

echo "✅ Documentation is up to date."
