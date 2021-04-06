#!/bin/bash

if [ -n "$DID_LINK" ]; then
    return 0
fi
export DID_LINK=y

# Get the script directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    SCRIPT_DIR=$(dirname "$(greadlink -f "${BASH_SOURCE[0]}")")
else
    SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
fi

# Create symlinks for all of the files named *.symlink
for f in $(find $SCRIPT_DIR -name '*.symlink'); do
    LINK_NAME=$HOME/.$(basename ${f%.symlink})
    ln -sf $f $LINK_NAME
done;

# Append the bashrc.append file to bashrc and same for zshrc
if [[ $(basename $SHELL) = bash ]]; then
    [ -f $SCRIPT_DIR/bashrc.append ] && source $SCRIPT_DIR/bashrc.append
    [ -n "$BDI" ] && [ -f $SCRIPT_DIR/bdi_bashrc.append ] && source $SCRIPT_DIR/bdi_bashrc.append
fi

if [[ $(basename $SHELL) = zsh ]]; then
    [ -f $SCRIPT_DIR/zshrc.append ] && source $SCRIPT_DIR/zshrc.append
fi

