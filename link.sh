#!/bin/bash

# Create symlinks for all of the files named *.symlink
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
for f in $(find $SCRIPT_DIR -name '*.symlink'); do
    LINK_NAME=$HOME/.$(basename ${f%.symlink})
    ln -sf $f $LINK_NAME
done;

