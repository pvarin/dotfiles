#!/bin/bash

# Get the script directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    SCRIPT_DIR=$(dirname "$(greadlink -f "$0")")
else
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
fi

# Create symlinks for all of the files named *.symlink
for f in $(find $SCRIPT_DIR -name '*.symlink'); do
    LINK_NAME=$HOME/.$(basename ${f%.symlink})
    ln -sf $f $LINK_NAME
done;

# Append the bashrc.append file to bashrc and same for zshrc
if [[ $DID_APPEND != yes ]]; then
    if [ -f $SCRIPT_DIR/bashrc.append ] && [ -f ~/.bashrc ]; then
        echo -e "\n[[ \$DID_APPEND != yes ]] && export DID_APPEND=yes && source $SCRIPT_DIR/bashrc.append" >> ~/.bashrc
    fi
    if [ -f $SCRIPT_DIR/zshrc.append ] && [ -f ~/.zshrc ]; then
        echo -e "\n[[ \$DID_APPEND != yes ]] && export DID_APPEND=yes && source $SCRIPT_DIR/zshrc.append" >> ~/.zshrc
    fi
fi

