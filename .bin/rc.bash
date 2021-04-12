#!/bin/bash

if [[ -z "${CONTAINER_ROOT}" ]]; then
    export CONTAINER_ROOT='/var/srv/containers'
fi
PATH="${CONTAINER_ROOT}/.bin:${PATH}"

if [[ -z "${CM_CMD}" ]]; then
    export CM_CMD='podman'
fi

case "${CM_CMD}" in
    'podman')
        TO_ALIAS='docker'
        ;;
    'docker')
        TO_ALIAS='podman'
        ;;
    *)
        printf '%s: UNSUPPORTED CM_CMD (got: %s)\n' "${0}" "${CM_CMD}"
        ;;
esac

if ! command -v "${CM_CMD}" &>/dev/null ; then
    printf '%s: COULD NOT FIND PREFERRED CM_CMD (got: %s)\n' "${0}" "${CM_CMD}"
    if command -v "${TO_ALIAS}" &>/dev/null ; then
        printf '%s: USING ALTERNATIVE CM_CMD (%s) AS PRIMARY\n' "${0}" "${TO_ALIAS}"
        export CM_CMD="${TO_ALIAS}"
    else
        printf '%s: WARNING: BOTH ALTERNATIVE (%s) AND PRIMRAY CM_CMD (%s) AS PRIMARY\n' "${0}" "${TO_ALIAS}" "${CM_CMD}"
    fi
fi

if command -v "${TO_ALIAS}" &>/dev/null ; then
    printf '%s: Found `%s`, but using `%s` as CM_CMD (not creating alias)\n' "${0}" "${TO_ALIAS}" "${CM_CMD}"
else
    alias "${TO_ALIAS}"="${CM_CMD}"
fi

export CM_CMD_DEFAULT_NETWORK="${CM_CMD_DEFAULT_NETWORK:-${CM_CMD}-bridge-default}"

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

function container_name_safe_str {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi

    local container_name="${1}"

    printf '%s' ${container_name} | tr -- '/ ' '-'
}

function container_network_str {
    if [[ $# -ne 1 ]] ; then
        printf "Usage: %s container_name\n" "${0}"
        return 1
    fi
    local container_name="${1}"

    source "$(container_home ${container_name})/vars.bash"
    container_name="$(container_name_safe_str ${container_name})"

    # only use CM_CMD_DEFAULT_NETWORK for creation, other networks specified in CONTAINER_NETWORKS array will be attached later
    printf -- '--hostname=%s --network-alias=%s --network=%s' "${container_name}" "${container_name}" "${CM_CMD_DEFAULT_NETWORK}"
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
    local net_str="$(container_network_str ${container_name})"

    # opt_str="--name ${container_name} --restart=always ${port_str} ${vol_str} ${env_str} ${CM_CMD_CUSTOM_OPTS} ${CONTAINER_IMG} ${CONTAINER_CUSTOM_ARGV}"
    container_name="$(container_name_safe_str ${container_name})"
    opt_str="--name=${container_name} --restart=unless-stopped ${net_str} ${port_str} ${vol_str} ${env_str} ${CM_CMD_EXTRA_OPTS} ${CONTAINER_IMG} ${CONTAINER_CUSTOM_ARGV}"
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
