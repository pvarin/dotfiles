#!/bin/bash

# Create symlinks for all of the files named *.symlink
if [[ "$OSTYPE" == "darwin"* ]]; then
	SCRIPT_DIR=$(dirname "$(greadlink -f "$0")")
else
	SCRIPT_DIR=$(dirname "$(readlink "$0")")
fi
for f in $(find $SCRIPT_DIR -name '*.symlink'); do
    LINK_NAME=$HOME/.$(basename ${f%.symlink})
    ln -sf $f $LINK_NAME
done;

