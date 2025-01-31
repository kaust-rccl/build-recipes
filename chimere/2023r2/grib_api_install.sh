#!/bin/bash
module swap PrgEnv-cray PrgEnv-gnu
module load cray-netcdf-hdf5parallel
module load cray-hdf5-parallel
module load blitz
module list

echo "Installing OpenJPEG which is dependency of grib_api"
tar xvf /sw/sources/openjpeg/1.3/openjpeg-version.1.3.tar.gz
cd openjpeg-version.1.3
mkdir build && cd build
CC=cc CFLAGS=-fPIC cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX -DINCLUDE_INSTALL_DIR=$CONDA_PREFIX/include ..
make -j 1 VERBOSE=1
make install
cd ../

echo "modifying a header file in Jasper so grip_api can compile"
sed -i 's;//bool inmem_;bool inmem_;g' $CONDA_PREFIX/include/jasper/jas_image.h
echo "Installing grib_api"
tar xvf /sw/sources/grib_api/1.14/grib_api-1.14.tgz
cd grib_api-1.14
./autogen.sh
CC=cc FC=ftn \
FCFLAGS="-fallow-argument-mismatch -fallow-invalid-boz" \
CPPFLAGS=-I$(echo ${CONDA_PREFIX}/include/openjpeg) ./configure \
--prefix=${CONDA_PREFIX} \
--with-jasper=${CONDA_PREFIX} \
--with-openjpeg=${CONDA_PREFIX}

make -j 1 VERBOSE=1
make install 
