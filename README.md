# Kolla-Ansible Deployment Guide

This repository provides a ready-to-use execution environment and configuration templates to deploy OpenStack services using Kolla Ansible. Follow the instructions below to set up your configuration, generate passwords, and execute a full deployment using the Docker image `nathanrignall/kolla-ansible-ee:2024.1`.

Deployment uses a prebuilt container ansible execution environment for ansible so that it can be executed in an offline environment.

## Getting Started

### Create Work Folder
Create a working directory and navigate into it:

```bash
mkdir kolla-config && cd kolla-config
```

## Setup Base Configuration

### Copy Global and Password Configuration Files
Copy the sample configuration files to a local `kolla` directory:

```bash
docker run --rm -it -v "$(pwd):/workdir" nathanrignall/kolla-ansible-ee:2024.1 cp /usr/local/share/kolla-ansible/etc_examples/kolla/ /workdir/kolla
```

### Copy the All-in-One Inventory File
Copy the inventory file into your working directory:

```bash
docker run --rm -it -v "$(pwd):/workdir" nathanrignall/kolla-ansible-ee:2024.1 cp /usr/local/share/kolla-ansible/ansible/inventory/multinode /workdir/
```

### Update Inventory File
Edit the `multinode` file to include your host addresses:

```bash
nano multinode
```

## Prepare Configuration

### Generate Passwords
Generate the necessary passwords and update the passwords configuration file:

```bash
docker run --rm -it -v "$(pwd):/workdir" nathanrignall/kolla-ansible-ee:2024.1 kolla-genpwd -p /workdir/kolla/passwords.yml
```

### Configure Globals
Edit the globals configuration file to suit your environment:

```bash
nano kolla/globals.yml
```

## Deployment

### Check Status
Verify connectivity and status of your hosts:

```bash
docker run --rm -it -v "$(pwd):/workdir" nathanrignall/kolla-ansible-ee:2024.1 ansible -i /workdir/multinode all -m ping
```

### Execute Prechecks
Run the pre-deployment checks:

```bash
docker run --rm -it -v "$(pwd):/workdir" nathanrignall/kolla-ansible-ee:2024.1 kolla-ansible prechecks -i /workdir/multinode --configdir /workdir/kolla
```

### Complete Deployment
Deploy the OpenStack services:

```bash
docker run --rm -it -v "$(pwd):/workdir" nathanrignall/kolla-ansible-ee:2024.1 kolla-ansible deploy -i /workdir/multinode --configdir /workdir/kolla
```

## Additional Information

- **Customization:**  
  Modify `globals.yml` and `passwords.yml` as necessary for your environment.
  
- **Documentation:**  
  For more detailed configuration options and troubleshooting, refer to the [Kolla Ansible documentation](https://docs.openstack.org/kolla-ansible/latest/).

