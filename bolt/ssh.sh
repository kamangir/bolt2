#! /usr/bin/env bash

function bolt_ssh() {
    local task=$(bolt_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        bolt_help_line "ssh ec2/jetson_nano/rpi 1-2-3-4 [./vnc/worker/worker,gpu] [platform] [region]" \
            "ssh to 1-2-3-4 [on platform] [on region] [for vnc/worker/worker,gpu]"
        return
    fi

    local kind=$1
    local address="$2"
    local intent="$3"
    local platform="$4"
    local region="$5"

    if [ -z "$address" ] ; then
        bolt_log_error "ssh address unknown."
        return
    fi

    if [ "$kind" == "ec2" ] ; then
        local ip_address=$(echo "$address" | tr . -)

        if [ -z "$region" ] ; then
            local region=$bolt_s3_region
        fi

        local user="ubuntu"
        local url="ec2-$ip_address.$region.compute.amazonaws.com"

        ssh-keyscan $url >> ~/.ssh/known_hosts

        local url="$user@$url"

        bolt_log "ssh to $url started: $intent $platform"

        bolt_seed ec2 clipboard $intent

        local path=$bolt_path_git/bolt/assets/aws
        local pem_filename="bolt"
        if [ ! -z "$platform" ] ; then
            local path=$bolt_path_git/$platform/assets/aws
            local pem_filename=$platform
        fi

        pushd $path > /dev/null
        chmod 400 $pem_filename.pem
        if [[ "$intent" == "vnc" ]] ; then
            ssh -i $pem_filename.pem -L 5901:localhost:5901 $url
        else
            ssh -i $pem_filename.pem ${url}
        fi
        popd > /dev/null
    elif [ "$kind" == "jetson_nano" ] ; then
        ssh bolt@$address.local
    elif [ "$kind" == "rpi" ] ; then
        ssh pi@$address.local
    else
       bolt_log_error "unknown kind: ssh '$kind'."
    fi
}