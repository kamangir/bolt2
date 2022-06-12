#! /usr/bin/env bash

function bolt2() {
    bolt_bolt2 $@
}

function bolt_bolt2() {
    local task=$(bolt_unpack_keyword $1 help)
    
    if [ "$task" == "help" ] ; then
        bolt_help_line "bolt2 validate" \
            "validate bolt2."
        bolt_help_line "bolt2 terraform" \
            "terraform bolt2."
        return
    fi

    if [ "$task" == "terraform" ] ; then
        conda activate base
        conda remove -y --name bolt2 --all

        conda create -y -n bolt2 python=3.9
        conda activate bolt2

        conda install -y -c conda-forge tensorflow
        conda install -y -c conda-forge keras
        conda install -y -c conda-forge matplotlib
        conda install -y -c conda-forge jupyter
        conda install -y pandas
        conda install -y -c conda-forge scikit-learn

        # https://stackoverflow.com/a/65993776/17619982
        conda install -y numpy==1.19.5

        pushd $bolt_path_bolt > /dev/null
        pip3 install -e .
        popd > /dev/null

        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m bolt2.bootstrap \
            validate
        lspci -v | grep NVIDIA
        nvidia-smi
        return
    fi

    bolt_log_error "unknown task: bolt2 '$task'."
}