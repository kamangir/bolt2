#! /usr/bin/env bash

function bolt_notebook() {
    local task=$(bolt_unpack_keyword "$1" help)

    if [ "$task" == "help" ] ; then
        bolt_help_line "notebook browse [notebook] [args]" \
            "browse $bolt_asset_name/notebook.ipynb [and pass args]."
        bolt_help_line "notebook build [notebook]" \
            "build $bolt_asset_name/notebook.ipynb."
        bolt_help_line "notebook host [notebook]" \
            "host $bolt_asset_name/notebook.ipynb on ec2."
        return
    fi

    local notebook_name=$2
    if [ -z "$notebook_name" ] or [ "$notebook_name" == "-" ] then
        local notebook="notebook"
    fi

    export bolt_notebook_input="${@:3}"

    if [ "$task" == "build" ] ; then
        jupyter-nbconvert $notebook_name.ipynb -y --ExecutePreprocessor.timeout=-1 --execute --allow-errors --to html --output-dir $bolt_asset_folder

        mv $bolt_asset_folder/$notebook_name.html $bolt_asset_folder/$bolt_asset_name.html

        return
    fi

    if [ "$task" == "browse" ] ; then
        bolt_tag set $bolt_asset_name notebook

        if [ ! -f $notebook_name.ipynb ]; then
            cp $bolt_path_bolt/assets/script/notebook.ipynb ./$notebook_name.ipynb
            bolt_log "$notebook_name.ipynb copied."
        fi

        jupyter notebook

        return
    fi

    if [ "$task" == "host" ] ; then
        echo "wip"
        return
    fi

    bolt_log_error "unknown task: notebook '$task'."
}
