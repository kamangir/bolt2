#! /usr/bin/env bash

function bolt2() {
    bolt_bolt2 $@
}

function bolt_bolt2() {
    local task=$(bolt_unpack_keyword $1 help)
    
    if [ "$task" == "help" ] ; then
        bolt_help_line "bolt2 create_conda_env" \
            "create conda env."
        return
    fi

    if [ "$task" == "create_conda_env" ] ; then
        conda activate base
        conda remove -y --name bolt2 --all

        conda create -y -n bolt2 python=3.9
        conda activate bolt2

        conda install -y -c conda-forge tensorflow
        conda install -y -c conda-forge keras
        conda install -y -c conda-forge matplotlib
        conda install -y -c conda-forge jupyter

        pushd $bolt_path_bolt > /dev/null
        pip3 install -e .
        popd > /dev/null

        return
    fi

    bolt_log_error "unknown task: bolt2 '$task'."
}