#!/bin/bash

if [ -z "$DOCK_INSTALL_PATH" ]; then
    echo "Error: DOCK_INSTALL_PATH is not set."
    exit 1
fi

# Create the split database index
find test_ligs -name '*.db2.tgz' -exec realpath {} \; > ${DOCK_INSTALL_PATH}/test/docking/split_database_index

export EXPORT_DEST="${DOCK_INSTALL_PATH}/test/docking/output"
export INPUT_SOURCE="${DOCK_INSTALL_PATH}/test/docking/split_database_index"
export DOCKFILES="${DOCK_INSTALL_PATH}/test/docking/dockfiles"
export DOCKEXEC="${DOCK_INSTALL_PATH}/dock3/dock64"

bash ${DOCK_INSTALL_PATH}/SUBDOCK/subdock.bash