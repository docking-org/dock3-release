#!/bin/bash

build() {
    dir=$1
    cd "$dir" || exit
    # Two makes because of the compiling bugs
    COMPILER=pgf make
    COMPILER=pgf make
    cd - > /dev/null || exit
}

clean() {
    dir=$1
    cd "$dir" || exit
    COMPILER=pgf make clean
    cd - > /dev/null || exit
}


# dock3
build dock3/src/libfgz
build dock3/src/i386
cp dock3/src/i386/dock64 dock3
clean dock3/src/libfgz
clean dock3/src/i386

# dock3-symmetry
build dock3-symmetry/src/libfgz
build dock3-symmetry/src/i386
cp dock3-symmetry/src/i386/dock64 dock3
clean dock3-symmetry/src/libfgz
clean dock3-symmetry/src/i386

# Pydock
# TODO: pydock3 shouldn't include DOCK executable as a submodule but should instead use DOCKEXEC or DOCKBASE or something. For now we will just do this
cp -r dock3 pydock3/pydock3/docking
cd pydock3
poetry build
cd ..

# legacy3
# TODO: legacy3 shouldnt include the DOCK executable in docking and again should be restructured.
cp -r dock3 legacy3/docking/DOCK

# zinc22-3d
# Nothing needs to be done for now!

# SUBDOCK
# Nothing needs to be done for now!

# Create the tar'd release
mkdir -p DOCK3.8
cp -r dock3 dock3-symmetry legacy3 pydock3 SUBDOCK zinc22-3d DOCK3.8
tar czf dock-"$1".tgz DOCK3.8