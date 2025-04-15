# dock3-release
Submodules the exact repos used for building the current DOCK3 release provided on the license server


### To build the release:

Docker build environment (recommended):
    - Build the environment:
        wget https://developer.download.nvidia.com/hpc-sdk/23.7/nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz
        docker build -t dock3-release-env .
    - Note: Someone has probably already built this docker image on gimel/epyc so you can skip this unless the docker environment is missing or you needed to update the Dockerfile to upgrade ubuntu,python,poetry,PGI,etc

    - Create the release:
        docker run --rm -v $(pwd):/release dock3-release-env [version_number]

Other method (our PSI machine is too old to have poetry so we don't do this):
    - Ensure you have the following:
        PGI compiler
        Poetry
    - Create the release:
        ./make_release.sh [version_number]

This will output dock-[version_number].tgz which is ready to put on the license server


### To make a new release:
Just update the git submodules to point to the new github repos you want and rebuild! 