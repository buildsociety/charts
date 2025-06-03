#!/bin/bash

# NFS Setup Script for Media Centre Helm Chart
# This script helps prepare your environment for using NFS storage with the media-centre chart
# Run this script on all Kubernetes nodes that will mount NFS volumes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
NFS_SERVER=""
NFS_TEST_PATH=""
KUBERNETES_NODES=""
MEDIA_UID=1000
MEDIA_GID=1000

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    print_status "Detected distribution: $DISTRO $VERSION"
}

# Install NFS client packages
install_nfs_client() {
    print_status "Installing NFS client packages..."
    
    case $DISTRO in
        ubuntu|debian)
            apt-get update
            apt-get install -y nfs-common nfs4-acl-tools
            ;;
        centos|rhel|rocky|almalinux)
            if [[ "$VERSION" == "8"* || "$VERSION" == "9"* ]]; then
                dnf install -y nfs-utils nfs4-acl-tools
            else
                yum install -y nfs-utils nfs4-acl-tools
            fi
            ;;
        fedora)
            dnf install -y nfs-utils nfs4-acl-tools
            ;;
        opensuse*|sles)
            zypper install -y nfs-client nfs4-acl-tools
            ;;
        *)
            print_warning "Unsupported distribution: $DISTRO"
            print_status "Please install nfs-common/nfs-utils manually"
            return 1
            ;;
    esac
    
    print_success "NFS client packages installed"
}

# Enable and start required services
start_nfs_services() {
    print_status "Starting NFS client services..."
    
    # Different distributions have different service names
    services=("rpcbind" "nfs-client.target" "nfs-common")
    
    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}"; then
            systemctl enable "$service" 2>/dev/null || true
            systemctl start "$service" 2>/dev/null || true
            print_status "Started service: $service"
        fi
    done
    
    print_success "NFS services started"
}

# Test NFS server connectivity
test_nfs_connectivity() {
    if [[ -z "$NFS_SERVER" ]]; then
        read -p "Enter your NFS server IP address: " NFS_SERVER
    fi
    
    print_status "Testing connectivity to NFS server: $NFS_SERVER"
    
    # Test basic connectivity
    if ! ping -c 3 "$NFS_SERVER" > /dev/null 2>&1; then
        print_error "Cannot reach NFS server at $NFS_SERVER"
        exit 1
    fi
    
    print_success "NFS server is reachable"
    
    # Test RPC services
    print_status "Checking RPC services on NFS server..."
    if ! rpcinfo -p "$NFS_SERVER" > /dev/null 2>&1; then
        print_warning "Cannot query RPC services on $NFS_SERVER"
        print_status "Make sure NFS service is running on the server"
    else
        print_success "RPC services are responding"
    fi
    
    # Show available exports
    print_status "Available NFS exports on $NFS_SERVER:"
    if showmount -e "$NFS_SERVER" 2>/dev/null; then
        print_success "NFS exports listed successfully"
    else
        print_warning "Cannot list NFS exports"
        print_status "Make sure your IP is allowed in NFS exports"
    fi
}

# Test NFS mount
test_nfs_mount() {
    if [[ -z "$NFS_TEST_PATH" ]]; then
        echo "Available exports:"
        showmount -e "$NFS_SERVER" 2>/dev/null || echo "Cannot list exports"
        read -p "Enter NFS path to test (e.g., /volume1/media): " NFS_TEST_PATH
    fi
    
    print_status "Testing NFS mount: $NFS_SERVER:$NFS_TEST_PATH"
    
    # Create test mount point
    TEST_MOUNT="/mnt/nfs-test-$$"
    mkdir -p "$TEST_MOUNT"
    
    # Attempt mount with NFSv4.1
    if mount -t nfs4 -o nfsvers=4.1,hard,intr "$NFS_SERVER:$NFS_TEST_PATH" "$TEST_MOUNT"; then
        print_success "NFS mount successful"
        
        # Test write permissions
        TEST_FILE="$TEST_MOUNT/.nfs-test-$$"
        if touch "$TEST_FILE" 2>/dev/null; then
            print_success "Write permissions OK"
            rm -f "$TEST_FILE"
        else
            print_warning "No write permissions - check NFS export settings"
        fi
        
        # Show mount details
        print_status "Mount details:"
        mount | grep "$TEST_MOUNT"
        
        # Unmount
        umount "$TEST_MOUNT"
        print_success "NFS test mount completed successfully"
    else
        print_error "NFS mount failed"
        print_status "Check NFS server configuration and exports"
        exit 1
    fi
    
    # Cleanup
    rmdir "$TEST_MOUNT"
}

# Create example NFS server configuration
create_nfs_server_config() {
    cat > /tmp/nfs-server-setup.txt << 'EOF'
# NFS Server Configuration Guide

## For Ubuntu/Debian NFS Server:
sudo apt-get install nfs-kernel-server

# Create directories
sudo mkdir -p /srv/nfs/media/{movies,tv,music,books}
sudo mkdir -p /srv/nfs/downloads

# Set ownership (important!)
sudo chown -R 1000:1000 /srv/nfs/media
sudo chown -R 1000:1000 /srv/nfs/downloads
sudo chmod -R 755 /srv/nfs/media
sudo chmod -R 755 /srv/nfs/downloads

# Configure exports (/etc/exports)
# Replace 192.168.1.0/24 with your network
/srv/nfs/media    192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
/srv/nfs/downloads 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)

# Apply configuration
sudo exportfs -rav
sudo systemctl restart nfs-kernel-server
sudo systemctl enable nfs-kernel-server

## For Synology NAS:
1. Control Panel → Shared Folder → Create folders: media, downloads
2. Control Panel → File Services → NFS → Enable NFS service
3. Edit shared folder → NFS Permissions:
   - Hostname/IP: 192.168.1.0/24
   - Privilege: Read/Write
   - Squash: No mapping
   - Security: sys
   - Enable "Allow connections from non-privileged ports"

## For QNAP NAS:
1. Control Panel → Privilege → Shared Folders → Create folders
2. Control Panel → Network & File Services → NFS Service → Enable
3. Control Panel → Privilege → Shared Folders → Edit → NFS Host Access:
   - Access Right: Read/Write
   - Host: 192.168.1.0/24
   - Sync: Async
   - No root squash: Yes

## Test NFS exports:
showmount -e YOUR_NFS_SERVER_IP
EOF

    print_status "NFS server configuration guide saved to /tmp/nfs-server-setup.txt"
    print_status "Use this guide to configure your NFS server if needed"
}

# Generate Kubernetes NFS StorageClass
create_nfs_storageclass() {
    cat > /tmp/nfs-storageclass.yaml << EOF
# NFS StorageClass for dynamic provisioning (optional)
# You'll need to install an NFS CSI driver like nfs-subdir-external-provisioner

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-media
provisioner: nfs.csi.k8s.io
parameters:
  server: ${NFS_SERVER}
  share: /volume1/media
  # Additional parameters as needed
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - nfsvers=4.1
  - hard
  - intr
  - rsize=1048576
  - wsize=1048576

---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-downloads
provisioner: nfs.csi.k8s.io
parameters:
  server: ${NFS_SERVER}
  share: /volume1/downloads
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - nfsvers=4.1
  - hard
  - intr
  - rsize=1048576
  - wsize=1048576
EOF

    print_status "NFS StorageClass examples saved to /tmp/nfs-storageclass.yaml"
}

# Generate example PV/PVC manifests
create_nfs_examples() {
    cat > /tmp/nfs-pv-examples.yaml << EOF
# Example NFS PersistentVolume and PersistentVolumeClaim
# Use these if you want to manually create NFS volumes

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: shared-media-nfs
  labels:
    type: nfs
    usage: media
spec:
  capacity:
    storage: 10Ti
  accessModes:
    - ReadWriteMany
  nfs:
    server: ${NFS_SERVER}
    path: /volume1/media
  mountOptions:
    - nfsvers=4.1
    - hard
    - intr
    - rsize=1048576
    - wsize=1048576
    - timeo=600
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-media-nfs
  namespace: media
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Ti
  volumeName: shared-media-nfs
  storageClassName: ""

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: shared-downloads-nfs
  labels:
    type: nfs
    usage: downloads
spec:
  capacity:
    storage: 2Ti
  accessModes:
    - ReadWriteMany
  nfs:
    server: ${NFS_SERVER}
    path: /volume1/downloads
  mountOptions:
    - nfsvers=4.1
    - hard
    - intr
    - rsize=1048576
    - wsize=1048576
    - timeo=600
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-downloads-nfs
  namespace: media
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Ti
  volumeName: shared-downloads-nfs
  storageClassName: ""
EOF

    print_status "NFS PV/PVC examples saved to /tmp/nfs-pv-examples.yaml"
}

# Check kernel NFS support
check_nfs_support() {
    print_status "Checking NFS kernel support..."
    
    if [[ -f /proc/filesystems ]] && grep -q nfs /proc/filesystems; then
        print_success "NFS filesystem support is available"
    else
        print_warning "NFS filesystem support may not be available"
    fi
    
    # Check for NFS modules
    if lsmod | grep -q nfs; then
        print_success "NFS modules are loaded"
    else
        print_status "Loading NFS modules..."
        modprobe nfs 2>/dev/null || print_warning "Could not load NFS module"
        modprobe nfsv4 2>/dev/null || print_warning "Could not load NFSv4 module"
    fi
}

# Performance tuning recommendations
show_performance_tips() {
    cat << 'EOF'

# NFS Performance Tuning Tips

## Network Optimization:
- Use Gigabit Ethernet or faster
- Enable jumbo frames if supported (MTU 9000)
- Use dedicated network for NFS traffic if possible

## Mount Options for Performance:
- nfsvers=4.1 (use latest stable version)
- rsize=1048576,wsize=1048576 (1MB buffer for high bandwidth)
- timeo=600 (60 second timeout)
- retrans=2 (reduce retries on good networks)
- proto=tcp (use TCP for reliability)

## Storage Strategy:
- Use local fast storage for application configs
- Use NFS for media libraries (mostly read operations)
- Consider local storage for active downloads, NFS for completed

## Kubernetes Considerations:
- Set proper fsGroup in security context
- Use ReadWriteMany for shared volumes
- Consider using multiple smaller volumes vs one large volume

EOF
}

# Main execution
main() {
    echo "========================================"
    echo "   NFS Setup for Media Centre Chart"
    echo "========================================"
    echo
    
    check_root
    detect_distro
    
    print_status "This script will:"
    print_status "1. Install NFS client packages"
    print_status "2. Start required services"
    print_status "3. Test NFS connectivity"
    print_status "4. Generate configuration examples"
    echo
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled"
        exit 0
    fi
    
    # Install and configure NFS client
    install_nfs_client
    start_nfs_services
    check_nfs_support
    
    # Test NFS connectivity
    echo
    read -p "Test NFS connectivity? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        test_nfs_connectivity
        test_nfs_mount
    fi
    
    # Generate configuration files
    create_nfs_server_config
    create_nfs_storageclass
    create_nfs_examples
    
    echo
    print_success "NFS setup completed successfully!"
    echo
    print_status "Generated files:"
    print_status "- /tmp/nfs-server-setup.txt (NFS server configuration guide)"
    print_status "- /tmp/nfs-storageclass.yaml (Kubernetes StorageClass examples)"
    print_status "- /tmp/nfs-pv-examples.yaml (PV/PVC examples)"
    echo
    print_status "Next steps:"
    print_status "1. Configure your NFS server using the guide in /tmp/nfs-server-setup.txt"
    print_status "2. Run this script on all Kubernetes nodes"
    print_status "3. Install media-centre chart with NFS configuration:"
    print_status "   helm install media-centre ./charts/incubator/media-centre \\"
    print_status "     -f examples/values-nfs.yaml -n media --create-namespace"
    echo
    
    show_performance_tips
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --nfs-server)
            NFS_SERVER="$2"
            shift 2
            ;;
        --test-path)
            NFS_TEST_PATH="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --nfs-server IP    NFS server IP address"
            echo "  --test-path PATH   NFS path to test"
            echo "  --help            Show this help"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main function
main "$@"