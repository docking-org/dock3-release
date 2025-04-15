# dock3-release
Submodules the exact repos used for building the current DOCK3 release provided on the license server


## To build the release:

### Docker build environment (recommended):

* Build the environment
    ```
    wget https://developer.download.nvidia.com/hpc-sdk/23.7/nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz
    docker build -t dock3-release-env .
    ```
* Note: Someone has probably already built this docker image on gimel/epyc so you can skip this unless the docker environment is missing or you needed to update the Dockerfile to upgrade ubuntu,python,poetry,PGI,etc

* Create the release:
    ```
    docker run --rm -v $(pwd):/release dock3-release-env [version_number]
    ```

### Other method (our PSI machine is too old to have poetry so we don't do this):
    
* Ensure you have the following:
  * PGI compiler
  * Poetry
* Create the release:
    ```
    ./make_release.sh [version_number]
    ```


Both methods will output dock-[version_number].tgz which is ready to put on the license server


## To make a new release:
Update the git submodules to point to the new github repos you want and rebuild! 

## Installing the release

* Untar the dock-[version_number].tgz
    ```
    tar -xzf dock-[version_number].tgz
    ```
* This will give you the DOCK3.8 folder containing all the required software

### Requirements
* python >=3.8.1, <3.11
* SGE, Slurm, or GNU Parallel


### "Installing" DOCK

* DOCK is provided as a pre-compiled binary that does not need direct installation. However, you should set the following environment variable:
  ```
  export DOCK_INSTALL_PATH=[absolute/path/to/DOCK3.8]
  ```

* Many of the legacy3 scripts will also expect:
  ```
  export DOCKBASE=[absolute/path/to/DOCK3.8/legacy3]
  ```

### Installing pydock


* Pydock is provided as a pip installable package which we recommend installing into a new python venv

    ```
    python3 -m venv ${DOCK_INSTALL_PATH}/pydock_env
    source ${DOCK_INSTALL_PATH}/pydock_env/bin/activate
    pip install ${DOCK_INSTALL_PATH}/pydock3/dist/pydock3-0.1.0rc1-py3-none-any.whl
    ```

### Installing building pipeline

* We are still developing this, but the current building installation instructions are [here](https://github.com/docking-org/zinc22-3d)


## Testing the install

We provide a test folder containing test scripts to ensure that the core functionalities are working

### Testing DOCK (subdock)

Choose your parallel execution environment (SGE, Slurm, or GNU Parallel):
```
export USE_SGE=true
OR
export USE_SLURM=true
OR
export USE_PARALLEL=true
```

Run:
```
cd ${DOCK_INSTALL_PATH}/test/docking
./test_subdock.sh
```

If everything works you should see a folder called `output` containing folders `1`, `2`, `3`, `4` (one for each `.db2.tgz` in test_ligs) each containing an `OUTDOCK` file and `test.mol2.gz.0` pose file. If you don't see these files check the `logs` folder to inspect the stderr and stdout for the jobs which will give hints as to what went wrong.

#### Common Issues
* If running on an HPC system, ensure that your `${DOCK_INSTALL_PATH}` is accessible from the compute nodes

### Testing pydock


Ensure your pydock environment is activated:
```
source ${DOCK_INSTALL_PATH}/pydock_env
```

#### Test blastermaster:
```
cd ${DOCK_INSTALL_PATH}/test/pydock
pydock3 blastermaster - new
cd blastermaster_job
pydock3 blastermaster - run
```

This may take a little while, but if it works you should get folders: `dockfiles` containing your docking grids and `visualization` containing files for visualizing the grids.

#### Test dockopt:
* To be implemented!

### Testing Building

* To be implemented!
