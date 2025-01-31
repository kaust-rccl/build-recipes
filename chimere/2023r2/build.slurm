#!/bin/bash

#SBATCH -t 04:0:0
#SBATCH -c 20
#SBATCH --hint=nomultithread

export CHIMERE_BASE=${PWD}
export CHIMERE_ROOT=${PWD}/chimere_v2023r2

cd $CHIMERE_ROOT

#source $MY_SW/miniconda3-amd64/bin/activate $CHIMERE_BASE/../install
source $MY_SW/miniconda3-amd64/bin/activate /scratch/project/k01/exclude/shaima0d/tickets/57408/install
module swap PrgEnv-cray PrgEnv-gnu
module load cray-netcdf-hdf5parallel
module load cray-hdf5-parallel
module load blitz
module list

export NETCDF=$NETCDF_DIR
export HDF5=$HDF5_DIR
export GRIB_DIR=$CONDA_PREFIX
export JASPERLIB=${CONDA_PREFIX}/lib
export JASPERINC=${CONDA_PREFIX}/include


./build-xios.sh --arch shaheen.gnu 
#./build-chimere.sh --arch shaheen.gnu --oasis
./build-chimere.sh --arch shaheen.gnu
./build-wrf.sh --arch shaheen.gnu


