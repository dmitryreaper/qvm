# QVM
## Overview
A bash script for quick creation and management of QEMU virtual machines with support for multiple architectures and installation from ISO images.

## Usage
### Basic VM Creation
```bash
./install.sh -n my-vm
```

### Full Options
```bash
./install.sh -n my-vm -d 30G -a x86_64 -m 4096 -c 4 -i ~/Downloads/os.iso
```

### Command Options
| Option | Description                          | Default           |
|--------|--------------------------------------|-------------------|
| `-n`   | VM name (required)                   | `namevm`          |
| `-d`   | Disk size (e.g., 20G)                | `20G`             |
| `-a`   | Architecture (`x86_64`/`aarch64`)    | `x86_64`          |
| `-m`   | Memory in MB                         | `2048`            |
| `-c`   | CPU cores                            | `2`               |
| `-i`   | ISO file path for installation       | `name.iso`        |
| `-h`   | Show help message                    | `-`               |

## Examples
### Create Ubuntu VM with Installation
```bash
./install.sh -n ubuntu-server -d 40G -m 4096 -i ubuntu-22.04.iso
```

### Create ARM64 Testing VM
```bash
./install.sh -n android-arm64 -a aarch64 -m 8192 -c 4
```

### Create Minimal VM
```bash
./install.sh -n minimal-vm -d 10G -m 1024
```

### Run VM
```bash
./start_your_vm_name.sh
```

