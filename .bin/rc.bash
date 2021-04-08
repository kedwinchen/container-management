#!/bin/bash

if [[ -z "${CONTAINER_ROOT}" ]]; then
    export CONTAINER_ROOT='/var/srv/containers'
fi
PATH="${CONTAINER_ROOT}/.bin:${PATH}"

if command -v podman &>/dev/null ; then
    export CM_CMD='podman'
    if command -v docker &> /dev/null ; then
        printf '%s: Found `docker`, but using `podman` as CM_CMD (not creating alias)' "${0}"
    else
        alias docker='podman'
    fi
elif command -v docker &>/dev/null ; then
    export CM_CMD='docker'
    if command -v podman &> /dev/null ; then
        printf '%s: Found `podman`, but using `docker` as CM_CMD' "${0}"
        printf '%s: Aborting... (should not be able to get here)' "${0}"
        exit 1
    else
        alias podman='docker'
    fi
else
    export CM_CMD='UNKNOWN'
    alias podman='echo "SUITABLE COMMAND FOR CM_CMD NOT FOUND"'
    alias docker='podman'
    exit 1
fi

function container_home {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi
    local container_name="${1}"
    printf "%s/%s" "${CONTAINER_ROOT}" "${container_name}"
}

function container_data_home {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi

    printf "%s/data" "$(container_home ${1})"
}

function container_vol_str {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi
    local container_name="${1}"

    source "$(container_home ${container_name})/vars.bash"
    local data_home="$(container_data_home ${container_name})"

    local vol_str=""
    for v in ${CONTAINER_VOLUMES[@]}; do
        vol_str="-v ${data_home}/${v} ${vol_str}"
    done
    printf '%s' "${vol_str}"
}

function container_port_str {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi
    local container_name="${1}"

    source "$(container_home ${container_name})/vars.bash"

    local port_str=""
    for p in ${CONTAINER_PORTS[@]}; do
        port_str="-p ${p} ${port_str}"
    done
    printf '%s' "${port_str}"
}

function container_env_str {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi
    local container_name="${1}"

    source "$(container_home ${container_name})/vars.bash"

    local env_str=""
    for p in ${CONTAINER_ENV[@]}; do
        env_str="-e ${p} ${env_str}"
    done
    printf '%s' "${env_str}"
}

function container_cmcmd_opt_str {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi
    local container_name="${1}"

    source "$(container_home ${container_name})/vars.bash"

    local port_str="$(container_port_str ${container_name})"
    local vol_str="$(container_vol_str ${container_name})"
    local env_str="$(container_env_str ${container_name})"

    # opt_str="--name ${container_name} --restart=always ${port_str} ${vol_str} ${env_str} ${CM_CMD_CUSTOM_OPTS} ${CONTAINER_IMG} ${CONTAINER_CUSTOM_ARGV}"
    opt_str="--name ${container_name} --restart=unless-stopped ${port_str} ${vol_str} ${env_str} ${CM_CMD_EXTRA_OPTS} ${CONTAINER_IMG} ${CONTAINER_CUSTOM_ARGV}"
    printf '%s' "${opt_str}"
}

#alias pstart="${CM_CMD} start"
alias pstop="${CM_CMD} stop"
# alias prs="${CM_CMD} restart"
alias prm="${CM_CMD} rm"
alias pmkill="${CM_CMD} kill"
alias plog="${CM_CMD} logs"
alias plogs="plog"
alias plogf="${CM_CMD} logs -f"
alias plogsf="plogf"
alias pps="${CM_CMD} ps"
