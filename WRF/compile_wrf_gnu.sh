#!/bin/sh

module swap PrgEnv-cray PrgEnv-gnu
module load cray-hdf5
module load cray-netcdf
module load cray-parallel-netcdf

# DIR : custom name based on wrf version + gcc version
WRF_VERSION="v4.6.0"  # Set the WRF version here
GCC_VERSION=$(cc --version | grep -m 1 'gcc' | grep -oP '\d+\.\d+\.\d+')
DIR=WRF_${WRF_VERSION}_CHEM_GCC_${GCC_VERSION}


########### CPE compilers ####################
export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
############# IO #########################
export HDF5=$HDF5_DIR
export PHDF5=$HDF5_DIR
export NETCDF=$NETCDF_DIR
export PNETCDF=$PNETCDF_DIR
export PNETCDF_QUILT=1
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export NETCDF_classic=1
############ WRF #########################
export FLEX_LIB_DIR=/sw/ex109genoa/flex/2.6.4/lib 
export FLEX=/usr/bin/flex 
export JASPERLIB=/usr/lib64
export JASPERINC=/usr/include/jasper
export YACC="/usr/bin/yacc -d"
########### CHEM #########################
export WRF_CHEM=1
export WRF_KPP=1
export WRF_EM_CORE=1
##########################################


echo "====================="
echo " - Preparing to download and compile WRF :"
echo " - WRF_VERSION = $WRF_VERSION"
echo " - GCC         = $GCC_VERSION"
echo " - WRF_CHEM    = $WRF_CHEM"
echo " - WRF_KPP     = $WRF_KPP"
echo "====================="
sleep 1

# GET SOURCES
rm -rf $DIR
git clone --branch $WRF_VERSION https://github.com/wrf-model/WRF.git $DIR
cd $DIR

./configure <<EOF
34
1
EOF


## CPE WRAPPERS
sed -i 's/gcc/cc/' configure.wrf
sed -i 's/mpicc/cc/' configure.wrf
sed -i 's/gfortran/ftn/' configure.wrf
sed -i 's/mpif90/ftn/' configure.wrf

## MANUAL MODIFICATIONS : works for gcc 12 (and 13)
CONFIGURE_FILE=./configure.wrf
sed -i 's/^DM_CC.*/DM_CC           =       cc/' $CONFIGURE_FILE                                         # Update DM_CC to use "cc" compiler and remove "-cc=$(SCC)" from the configuration
sed -i '/^CFLAGS_LOCAL/s/=\( *\)/=\1-fpermissive /' $CONFIGURE_FILE                                     # Add "-fpermissive to CFLAGS_LOCAL to allow incompatible pointer types
sed -i '/^FCOPTIM/s/=\( *\)/=\1-fallow-argument-mismatch /' $CONFIGURE_FILE                             # Add "-fallow-argument-mismatch" to FCOPTIM to allow argument mismatches
sed -i '/^FCNOOPT/s/=\( *\)/=\1-fallow-argument-mismatch -fallow-invalid-boz  /' $CONFIGURE_FILE        # Add flags to FCNOOPT to allow argument mismatches and invalid boz constants
sed -i '/^FCBASEOPTS_NO_G/s/=\( *\)/=\1-fallow-argument-mismatch -fallow-invalid-boz /' $CONFIGURE_FILE # Add flags to FCBASEOPTS_NO_G to allow argument mismatches and invalid boz constants
# KPP
sed -i 's/-ll //' chem/KPP/kpp/kpp-2.1/src/Makefile                                                     # Remove the linking to the libl library (-ll) from the Makefile
sed -i 's|^YACC=.*|YACC="/usr/bin/yacc -d"|' chem/KPP/configure_kpp                                     # Replace the YACC definition with /usr/bin/yacc -d in the configure_kpp file


## Compilation
time ./compile -j 16 em_real 2>&1 | tee compile_em_real.log
