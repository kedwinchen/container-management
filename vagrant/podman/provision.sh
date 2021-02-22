#!/bin/bash

set -eEuo pipefail

################################################################################
# Determine where this script is stored

# Solve for the current directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

THIS_SCRIPT="${DIR}/$(basename ${0})"

printf "Using (%s) as the path of the provisioner script\n" "${THIS_SCRIPT}"

################################################################################
# Check permissions

printf "Running as %s (%s)\n" "$(whoami)" "$(id)"

if [[ $EUID -ne 0 ]] ; then
    printf "%s\n" "Attempting to elevate..."
    # re-launch as root
    exec sudo -i bash "${THIS_SCRIPT}"
fi

# this should not be able to occur
if [[ $EUID -ne 0 ]] ; then
    # at this point, we should be running as root
    # if not, then using `sudo` failed
    printf "%s\n" "Could not elevate to root"
    exit 1
else
    printf "%s\n" "Successfully elevated privileges"
fi

################################################################################
# Provisioner part

# CUSTOM_ROOT="/usr/local/.programs"
# mkdir -p "${CUSTOM_ROOT}"
# cd "${CUSTOM_ROOT}"

dnf upgrade -y

# Some core packages
dnf install -y cockpit cockpit-ws dnf-plugins-core git python3 python3-pip
systemctl daemon-reload
systemctl enable cockpit.socket

# Install Podman
dnf install -y podman cockpit-podman
systemctl daemon-reload
systemctl enable podman.socket
python3 -m pip install podman-compose

# Enable the user-land service for the default user
# TODO: investigate this; cannot use this right now
# sudo -i -u vagrant systemctl enable --user podman.socket

# cleanup
dnf clean all

# install [current] version of management tooling
CONTAINER_ROOT="/var/srv/containers/"
mkdir -p "${CONTAINER_ROOT}"
cd "${CONTAINER_ROOT}"
chmod -R 6755 "${CONTAINER_ROOT}"
git clone https://gitlab.com/kedwinchen/container-management.git .admin
ln -s "${CONTAINER_ROOT}/.admin/.bin" "${CONTAINER_ROOT}"
ln -s "${CONTAINER_ROOT}/.admin/.skel" "${CONTAINER_ROOT}"
echo 'source /var/srv/containers/.bin/rc.bash' > /etc/profile.d/container-management.sh
restorecon -R /var/srv/containers/
