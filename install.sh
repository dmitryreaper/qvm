#!/bin/bash

# Default parameters
DEFAULT_ARCH="x86_64"
DEFAULT_DISK_SIZE="20G"
DEFAULT_MEMORY="2048"
DEFAULT_CPU="2"
DEFAULT_ISO=""

# Help function
show_help() {
    echo "QEMU Virtual Machine Installer"
    echo "Usage: $0 -n <vm_name> [-d <disk_size>] [-a <architecture>] [-m <memory>] [-c <cpu>] [-i <iso_file>]"
    echo "  -n  VM name (required)"
    echo "  -d  Disk size (default: $DEFAULT_DISK_SIZE)"
    echo "  -a  Architecture (x86_64, aarch64, ppc64, default: $DEFAULT_ARCH)"
    echo "  -m  Memory in MB (default: $DEFAULT_MEMORY)"
    echo "  -c  CPU cores (default: $DEFAULT_CPU)"
    echo "  -i  Installation ISO file path (optional)"
    echo ""
    echo "Example: ./install.sh -n myvm -d 30G -a x86_64 -m 4096 -c 4 -i ubuntu.iso"
    exit 0
}

# Parse arguments
while getopts ":n:d:a:m:c:i:h" opt; do
    case $opt in
        n) VM_NAME="$OPTARG" ;;
        d) DISK_SIZE="$OPTARG" ;;
        a) ARCH="$OPTARG" ;;
        m) MEMORY="$OPTARG" ;;
        c) CPU="$OPTARG" ;;
        i) ISO_FILE="$OPTARG" ;;
        h) show_help ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done

# Check required arguments
if [ -z "$VM_NAME" ]; then
    echo "Error: VM name must be specified"
    show_help
fi

# Set default values
: ${DISK_SIZE:=$DEFAULT_DISK_SIZE}
: ${ARCH:=$DEFAULT_ARCH}
: ${MEMORY:=$DEFAULT_MEMORY}
: ${CPU:=$DEFAULT_CPU}

# Create VM directory
VM_DIR="$HOME/qemu-vms/$VM_NAME"
mkdir -p "$VM_DIR"
cd "$VM_DIR" || exit 1

# Disk filename
DISK_FILE="${VM_NAME}.qcow2"

# Create disk
echo "Creating virtual disk $DISK_FILE ($DISK_SIZE)..."
qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"

# Determine QEMU parameters based on architecture
case "$ARCH" in
    x86_64)
        QEMU_CMD="qemu-system-x86_64"
        MACHINE_TYPE="pc,accel=kvm"
        ;;
    aarch64)
        QEMU_CMD="qemu-system-aarch64"
        MACHINE_TYPE="virt,accel=kvm,gic-version=3"
        ;;
    ppc64)
        QEMU_CMD="qemu-system-ppc64"
        MACHINE_TYPE="pseries,accel=kvm"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Base startup command
BASE_CMD=(
    "$QEMU_CMD"
    -m "$MEMORY"
    -smp "$CPU"
    -machine "$MACHINE_TYPE"
    -drive "file=$DISK_FILE,format=qcow2"
    -netdev "user,id=net0"
    -device "virtio-net-pci,netdev=net0"
    -vga "qxl"
    -usb
    -device "usb-tablet"
)

# Add ISO if specified
if [ -n "$ISO_FILE" ]; then
    if [ ! -f "$ISO_FILE" ]; then
        echo "Error: ISO file not found: $ISO_FILE"
        exit 1
    fi
    BASE_CMD+=(-cdrom "$ISO_FILE" -boot "d")
fi

# VM installation summary
echo -e "\nVirtual Machine Installation Summary:"
echo "-----------------------------------"
echo "VM Name:        $VM_NAME"
echo "Architecture:   $ARCH"
echo "Disk:           $DISK_FILE ($DISK_SIZE)"
echo "Memory:         ${MEMORY}MB"
echo "CPU Cores:      $CPU"
echo "ISO:           ${ISO_FILE:-None}"
echo "VM Directory:   $VM_DIR"
echo ""

# Generate startup script
START_SCRIPT="start_${VM_NAME}.sh"
echo "#!/bin/bash" > "$START_SCRIPT"
echo "# Start script for $VM_NAME" >> "$START_SCRIPT"
echo "cd \"$VM_DIR\"" >> "$START_SCRIPT"
printf "%s " "${BASE_CMD[@]}" >> "$START_SCRIPT"
echo "" >> "$START_SCRIPT"
chmod +x "$START_SCRIPT"

echo "Startup script created: $VM_DIR/$START_SCRIPT"

# Installation complete message
echo -e "\nInstallation complete!"
if [ -n "$ISO_FILE" ]; then
    echo -e "\nTo begin installation, run:"
    echo "  $VM_DIR/$START_SCRIPT"
else
    echo -e "\nTo start the virtual machine, run:"
    echo "  $VM_DIR/$START_SCRIPT"
fi
