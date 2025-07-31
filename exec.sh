#!/bin/bash

IMAGE="nathanrignall/kolla-ansible-ee"

USER_ID=$(id -u)
GROUP_ID=$(id -g)
USER_NAME="customuser"
GROUP_NAME="customgroup"

# Run everything in a single container
# Create user, then use 'sudo' to switch to that user
docker run -t --rm -it --user root \
  -v "/home/cloud/kolla-config:/workdir" \
  -v "/home/cloud/openstack:/etc/openstack" \
  -v "${SSH_AUTH_SOCK}:/ssh-agent" \
  -e SSH_AUTH_SOCK="/ssh-agent" \
  "${IMAGE}" /bin/bash -c "
    groupadd -g ${GROUP_ID} ${GROUP_NAME} &>/dev/null || true
    useradd -u ${USER_ID} -g ${GROUP_ID} -d /workdir ${USER_NAME} &>/dev/null || true
    # Add the new user to the sudoers file to allow passwordless sudo
    echo '${USER_NAME} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
    # Use 'sudo' to execute the final command as the new user
    exec sudo -E -u ${USER_NAME} -- \"\$@\"
  " bash "$@"
