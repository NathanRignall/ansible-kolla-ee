#!/bin/bash
#
# This script runs Ansible inside a custom Docker container
# that has the correct user pre-configured.
#

set -e

# --- Configuration ---
# The name of the custom image created by the build script.
# Make sure this matches the name in your build_custom_image.sh script.
CUSTOM_IMAGE_NAME="my-kolla-ansible-ee"

# --- Pre-flight Check ---
# Check if the custom Docker image exists.
# If not, exit with instructions to build it first.
if ! docker image inspect "${CUSTOM_IMAGE_NAME}" &> /dev/null; then
  echo "Error: Custom Docker image '${CUSTOM_IMAGE_NAME}' not found."
  echo "Please run the './build_custom_image.sh' script first to build it."
  exit 1
fi

echo "Found custom image: ${CUSTOM_IMAGE_NAME}"
echo "Running Ansible command..."
echo "-------------------------------------"

# --- Execution ---
# Run the ansible command inside the custom container.
# This command is much simpler because the user is already set up in the image.
# It passes all script arguments ($@) to the ansible command inside the container.
docker run -it --rm \
  -v "/home/cloud/kolla-config:/workdir" \
  -v "/home/cloud/openstack:/etc/openstack" \
  -v "${SSH_AUTH_SOCK}:/ssh-agent" \
  -e SSH_AUTH_SOCK="/ssh-agent" \
  "${CUSTOM_IMAGE_NAME}" "$@"
