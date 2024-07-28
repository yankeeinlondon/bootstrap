# Bootstrap

> available as @yankeeinlondon/bootstrap on `npm`

## Purpose / Goal

A few basic bash scripts to help in bootstrapping a new OS environment.

Scripts include:

### `debian` and `ubuntu`

- sets up a new install of either of these distros
  - installs core packages:
    - utils:
      - iperf3
      - htop
      - fzf
      - git, gh
      - ...
    - apps:
      - neovim
      - ...
    - language support (optional):
      - rust
      - JS/TS
  - injects the **nala** package manager over bare use of **apt**
  - installs the [Starship](https://starship.rs/) prompt
  - sets up sensible config defaults for `git`

### `create-vm-template`

- creates a VM template on a [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) node
- provides template from a cloud-image of any of the following distros:
  - Debian
  - Ubuntu
  - Fedora
  - Centos

## Usage

The available shell scripts can be executed in the following ways:

- simply execute the script after cloning
- if you've added this repo as a dependency then the scripts will be exposed to your npm scripts
- the [just](https://github.com/casey/just) runner is used here to provide both an inventory of the scripts provided as well as a simple means to run them:
  - simply type `just` (after having installed this tool) and you'll be presented with a menu of options
  - or, type `just [cmd]` to run a particular command/script

