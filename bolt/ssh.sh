#! /usr/bin/env bash

function bolt_ssh() {
    local task=$(bolt_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        bolt_help_line "ssh ec2/jetson_nano/rpi 1-2-3-4 [./vnc/worker/worker,gpu] [region=region_1,user=ec2-user/ubuntu]" \
            "ssh to 1-2-3-4 [on region_1] [for vnc/worker/worker,gpu] [as user]."
        return
    fi

    local kind=$1
    local address="$2"
    local intent="$3"

    local options="$4"

    if [ -z "$address" ] ; then
        bolt_log_error "ssh address unknown."
        return
    fi

    if [ "$kind" == "ec2" ] ; then
        local ip_address=$(echo "$address" | tr . -)
        local region=$(bolt_option "$options" "region" $bolt_s3_region)
        local url="ec2-$ip_address.$region.compute.amazonaws.com"

        ssh-keyscan $url >> ~/.ssh/known_hosts

        local user=$(bolt_option "$options" user ubuntu)
        local url="$user@$url"

        bolt_log "ssh to $url started: $intent"

        bolt_seed ec2 clipboard $intent

        pushd $bolt_path_git/bolt/assets/aws > /dev/null
        chmod 400 bolt.pem
        if [[ "$intent" == "vnc" ]] ; then
            ssh -i bolt.pem -L 5901:localhost:5901 $url
        else
            ssh -i bolt.pem $url
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