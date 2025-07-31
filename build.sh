#!/bin/bash
#
# This script builds a custom Docker image with a specific user
# to avoid TTY and permission issues when running Ansible.
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# The original base image you are using
BASE_IMAGE="nathanrignall/kolla-ansible-ee"

# The name for your new custom image. Change this if you like.
CUSTOM_IMAGE_NAME="my-kolla-ansible-ee"

# Get the current user's ID and Group ID
# This ensures file permissions on mounted volumes are correct.
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# --- Script Logic ---

# Create a temporary directory for the build context
BUILD_DIR=$(mktemp -d)
echo "Created temporary build directory: ${BUILD_DIR}"

# Create the Dockerfile inside the temporary directory
# This Dockerfile will add a new user matching your current user's IDs.
cat > "${BUILD_DIR}/Dockerfile" <<EOF
# Start from your specified base image
FROM ${BASE_IMAGE}

# Explicitly switch to root to ensure we have permissions to create users.
# This is important if the base image already sets a non-root user.
USER root

# Use ARG to get build-time variables for user/group details
ARG UID=${USER_ID}
ARG GID=${GROUP_ID}
ARG USER_NAME=ansible
ARG GROUP_NAME=ansible

# Create the group and user inside the container
# This runs as root by default.
# The user will have the same UID/GID as the host user.
RUN groupadd --gid \${GID} \${GROUP_NAME} && \\
    useradd --uid \${UID} --gid \${GID} --create-home --shell /bin/bash \${USER_NAME}

# Set the default user for the container.
# Any subsequent commands (like ansible-playbook) will run as this user.
USER \${USER_NAME}

# Set a working directory for convenience
WORKDIR /workdir
EOF

echo "--- Dockerfile Created ---"
cat "${BUILD_DIR}/Dockerfile"
echo "--------------------------"

# Build the new Docker image using a bash array for robustness
echo "Building custom image: ${CUSTOM_IMAGE_NAME}..."
build_args=(
  --build-arg "UID=${USER_ID}"
  --build-arg "GID=${GROUP_ID}"
  -t "${CUSTOM_IMAGE_NAME}"
  "${BUILD_DIR}"
)
docker build "${build_args[@]}"

# Clean up the temporary directory
rm -rf "${BUILD_DIR}"

echo ""
echo "Build complete!"
echo "A new Docker image named '${CUSTOM_IMAGE_NAME}' has been created."
echo ""
echo "--- How to Use ---"
echo "You can now run your Ansible playbooks with a much simpler command:"
echo ""
echo "docker run -it --rm \\"
echo "  -v \"/home/cloud/kolla-config:/workdir\" \\"
echo "  -v \"/home/cloud/openstack:/etc/openstack\" \\"
echo "  -v \"\${SSH_AUTH_SOCK}:/ssh-agent\" \\"
echo "  -e SSH_AUTH_SOCK=\"/ssh-agent\" \\"
echo "  ${CUSTOM_IMAGE_NAME} ansible-playbook your-playbook.yml"
echo ""
