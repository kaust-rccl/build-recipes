#!/bin/bash
function usage() {
   echo "Usage: $0 software compiler install"  
   echo "	software : wrf or wrfchem"  
   echo "	compiler : gnu cray or intel"  
   echo "	install  : dmpar or dmsm"  
   exit 0
}
function set_code(){
if [ $1 = dmpar ]; then
   echo  $2
elif [ $1 = dmsm ]; then
   echo  $3
fi
}
function get_code_install(){
if [ $1 = gnu ]; then
   set_code $2 34 35
elif [ $1 = intel ]; then
   set_code $2 50 51
elif [ $1 = cray ]; then
   set_code $2 46 47
fi
}
if [[ $@ == "--help" ||  $@ == "-h" ]]; then
	usage
fi
if [ $# -ne 3 ] ; then
    usage
else
    software=$1
    compiler=$2
    install=$3
fi
if [ $compiler = gnu ]; then
   module sw PrgEnv-cray PrgEnv-gnu
elif [ $compiler = intel ]; then
   module sw PrgEnv-cray PrgEnv-intel
   module sw intel/2023.1.0 intel/2024.2.1
fi
module load cray-hdf5 cray-netcdf cray-parallel-netcdf
export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
export HDF5=$HDF5_DIR
export PHDF5=$HDF5_DIR
export NETCDF=$NETCDF_DIR
export PNETCDF=$PNETCDF_DIR
export PNETCDF_QUILT=1
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
if [[ $compiler = gnu || $compiler = intel ]]; then
   export NETCDF_classic=1
fi
if [ $software = wrfchem ]; then
   module load flex/2.6.4
   export FLEX=/usr/bin/flex
   export YACC="/usr/bin/yacc -d"
   export JASPERLIB=/usr/lib64
   export JASPERINC=/usr/include/jasper
   export SED=/usr/bin/sed
   export WRF_EM_CORE=1
   export WRF_NMM_CORE=0
   export WRF_CHEM=1
   export WRF_KPP=1
fi
module list -t
SRC_DIR=WRF_install/$software/$compiler/$install
rm -rf $SRC_DIR
mkdir -p $SRC_DIR
cp -r WRF $SRC_DIR
cd $SRC_DIR/WRF
./configure <<< $(get_code_install $compiler $install)

if [ $compiler = intel ]; then
   sed -i '/FCOPTIM/s/-O3/-O3 -fp-model precise/' ./configure.wrf
   sed -i '/SCC/s/icc/icx/' ./configure.wrf
   sed -i '/CCOMP/s/icc/icx/' ./configure.wrf
elif [ $compiler = cray ]; then
   sed -i 's/-hnoomp//g' configure.wrf
   sed -i '/OMPCC/s/-homp/-fopenmp/' configure.wrf
   sed -i '/CFLAGS_LOCAL/s/-O3/-O0 -Wno-implicit-function-declaration -Wno-implicit-int/' configure.wrf
fi

sed -i 's;/lib/cpp -P -nostdinc;/lib/cpp -P ;g' ./configure.wrf
sed -i 's/# -DRSL0_ONLY/-DRSL0_ONLY/g' ./configure.wrf
## These following two lines are for only experimental purposes. These lines should be left commented for production.
#sed -i 's/nproc_x .LT. 10/nproc_x .LT. 1/' share/module_check_a_mundo.F
#sed -i 's/nproc_y .LT. 10/nproc_y .LT. 1/' share/module_check_a_mundo.F

if [ $software = wrfchem ]; then
   sed -i -e 's/="-O"/="-O0"/' chem/KPP/configure_kpp
   if [ $compiler = cray ]; then
      sed -i -e 's/="-O0"/="-O0 -Wno-implicit-function-declaration -Wno-implicit-int"/' chem/KPP/configure_kpp
      sed -i '/CFLAGS/s/#-ansi/-Wno-implicit-function-declaration -Wno-implicit-int -Wno-return-type/' chem/KPP/util/wkc/Makefile
   fi
   sed -i -e 's/if [ "$USENETCDFPAR" == "1" ] ; then/if [ "$USENETCDFPAR" = "1" ] ; then/' configure
   sed -i '2041 s/,OPTIONAL//' chem/module_mosaic_addemiss.F
   sed -i '4701 s/),/)/' chem/module_optical_averaging.F
   sed -i '4705 s/),/)/' chem/module_optical_averaging.F
   sed -i '4709 s/),/)/' chem/module_optical_averaging.F
   sed -i '4713 s/),/)/' chem/module_optical_averaging.F
   sed -i '4976 s/),/)/' chem/module_optical_averaging.F
   sed -i '4980 s/),/)/' chem/module_optical_averaging.F
   sed -i '4984 s/),/)/' chem/module_optical_averaging.F
   sed -i '4988 s/),/)/' chem/module_optical_averaging.F
fi

time ./compile -j 4 em_real 2>&1 | tee compile_em_real.log

if [ $software = wrf ];then
   echo "End of WRF compilation"
else
   echo "End of WRF-CHEM compilation"
fi
echo "==================================================="
echo "ls in main: should have the following files:"
echo "   -library : libwrflib.a"
echo "   -binaries: ndown.exe  real.exe  tc.exe  wrf.exe"
echo "==================================================="
ls -lrt  main/*.exe main/*.a
