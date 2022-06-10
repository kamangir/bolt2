#! /usr/bin/env bash

function bolt_notebook() {
    local task=$(bolt_unpack_keyword "$1" help)

    if [ "$task" == "help" ] ; then
        bolt_help_line "notebook browse [notebook] [args]" \
            "browse $bolt_asset_name/notebook.ipynb [and pass args]."
        bolt_help_line "notebook build [notebook]" \
            "build $bolt_asset_name/notebook.ipynb."
        bolt_help_line "notebook connect 1-2-3-4 [setup]" \
            "[setup and] connect to jupyter notebook on ec2:1-2-3-4."
        bolt_help_line "notebook host [setup]" \
            "[setup and] host jupyter notebook on ec2."
        return
    fi

    if [ "$task" == "build" ] || [ "$task" == "browse" ] ; then
        local notebook_name=$2
        if [ -z "$notebook_name" ] || [ "$notebook_name" == "-" ] ; then
            local notebook_name="notebook"
        fi

        export bolt_notebook_input="${@:3}"
    fi

    if [ "$task" == "build" ] ; then
        jupyter-nbconvert \
            $notebook_name.ipynb \
            -y --ExecutePreprocessor.timeout=-1 --execute --allow-errors \
            --to html \
            --output-dir $bolt_asset_folder

        mv $bolt_asset_folder/$notebook_name.html $bolt_asset_folder/$bolt_asset_name.html

        return
    fi

    if [ "$task" == "browse" ] ; then
        if [ ! -f $notebook_name.ipynb ]; then
            cp $bolt_path_bolt/assets/script/notebook.ipynb ./$notebook_name.ipynb
            bolt_log "$notebook_name.ipynb copied."
        fi

        jupyter notebook

        return
    fi

    # https://docs.aws.amazon.com/dlami/latest/devguide/setup-jupyter.html
    if [ "$task" == "connect" ] ; then
        local options="$3"
        local do_setup=$(bolt_option_int "$options" "setup" 0)

        if [ "$do_setup" == 1 ] ; then
            local ip_address=$(echo "$2" | tr . -)
            ssh \
                -i $bolt_path_git/bolt/assets/aws/bolt.pem \
                -N -f -L 8888:localhost:8888 \
                ubuntu@ec2-$ip_address.$bolt_s3_region.compute.amazonaws.com
        fi

        open https://localhost:8888
        return
    fi

    if [ "$task" == "host" ] ; then
        local options="$3"
        local do_setup=$(bolt_option_int "$options" "setup" 0)

        if [ "$do_setup" == 1 ] ; then
            jupyter notebook password

            mkdir -p $bolt_path_home/ssl
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout $bolt_path_home/ssl/mykey.key \
                -out $bolt_path_home/ssl/mycert.pem
        fi

        jupyter notebook \
            --certfile=$bolt_path_home/ssl/mycert.pem \
            --keyfile $bolt_path_home/ssl/mykey.key

        return
    fi

    bolt_log_error "unknown task: notebook '$task'."
}
