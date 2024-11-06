#!/bin/bash
function usage() {
   echo "Usage: $0 compiler wrfpath"  
   echo "	compiler: gnu cray or intel"  
   echo "	wrfpath : absolute path to the installed wrf"  
   echo "	        : contains the main directory which"  
   echo "	        : contains the wrf.exe binary"  
   exit 0
}
function get_code_install(){
if [ $1 = gnu ]; then
   echo "3"
elif [ $1 = intel ]; then
   echo "43"
elif [ $1 = cray ]; then
   echo "39"
fi
}
if [[ $@ == "--help" ||  $@ == "-h" ]]; then
	usage
fi
if [ $# -ne 2 ] ; then
    usage
else
    compiler=$1
    export  WRF_DIR=$2
fi
if [ $compiler = gnu ]; then
   module sw PrgEnv-cray PrgEnv-gnu
elif [ $compiler = intel ]; then
   module sw PrgEnv-cray PrgEnv-intel
   module sw intel/2023.1.0 intel/2024.2.1
fi
module load cray-hdf5 cray-netcdf cray-parallel-netcdf flex
export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
export HDF5=$HDF5_DIR
export PHDF5=$HDF5_DIR
export NETCDF=$NETCDF_DIR
export PNETCDF=$PNETCDF_DIR
module load flex/2.6.4
export FLEX=/usr/bin/flex
export YACC="/usr/bin/yacc -d"
export JASPERLIB=/usr/lib64
export JASPERINC=/usr/include/jasper
export SED=/usr/bin/sed
SRC_DIR=WPS_install/$compiler
rm -rf $SRC_DIR
mkdir -p $SRC_DIR
cp -r WPS $SRC_DIR
cd $SRC_DIR/WPS
./configure <<< $(get_code_install $compiler)
sed -i 's/int2nc.exe:/int2nc.exe: met_data_module.o/g' util/src/Makefile
sed -i 's/$(WRF_INCLUDE) int2nc.o/$(WRF_INCLUDE) met_data_module.o int2nc.o/g' util/src/Makefile
time ./compile 2>&1 | tee compile_wps.log
echo "End of WPS compilation"
echo "==================================================="
echo "ls exe : should have the following files:"
echo "   -binaries: geogrid.exe  metgrid.exe  ungrib.exe "
echo "==================================================="
ls -lrt  *.exe
