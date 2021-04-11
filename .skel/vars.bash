#!/bin/bash

# CONTAINER_NAME is already defined elsewhere
## CONTAINER_NAME='REPLACE_CONTAINER_NAME'

# Preferred format: 'hub.url/owner/image:tag'
# Example: 'docker.io/cloudflare/cloudflared:latest'
CONTAINER_IMG='REPLACE_CONTAINER_IMAGE'

# Format: 'relative/path:/mount/point/in/container:options' (one per line)
#   the path is relative to $(container_data_home ${CONTAINER_NAME})'
#   these directories are auto created
# Example: 'config:/etc/config'
CONTAINER_VOLUMES=(
    ''
)

# Format: 'host_port:container_port' (one per line)
# Example: '8080:80' maps port 8080 on the host system to port 80 inside of
#          the container
CONTAINER_PORTS=(
    ''
)

# Format: 'VAR_NAME=value' (one per line)
# Example: 'DATABASE_DB_FILE="/data/database.sqlite"'
CONTAINER_ENV=(
    ''
)

# Additional network(s) to connect to (always connects to CM_CMD_DEFAULT_NETWORK)
CONTAINER_NETWORKS=(
    ''
)

# Custom command line (or arguments) to be passed directly to the entrypoint
# command in the container
#
# Format: (as required by the image)
CONTAINER_CUSTOM_ARGV=''

# Extra options that should be passed to ${CM_CMD} (as defined in the
# configuration file (probably at `../.bin/rc.bash`))
# before the image name (i.e., NOT passed to the image)
#
# See the configuration file for default options
#
# Format: (as required by the image)
CM_CMD_EXTRA_OPTS=''
