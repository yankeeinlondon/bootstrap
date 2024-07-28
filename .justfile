set dotenv-load

repo := `pwd`

RESET :='\033[0m'
BOLD := '\033[1m'
GREEN := '\033[38;5;2m'
# this menu
default:
  @echo
  @echo "Bootstrap CLI"
  @echo "------------------"
  @just --list
  @echo

# Install core apps, utils, and configuration for Ubuntu distro
ubuntu:
  ./ubuntu

# Install core apps, utils, and configuration for Debian distro
debian:
  ./debian

# Create a Proxmox VM template
vm-template: 
  ./create-vm-template
