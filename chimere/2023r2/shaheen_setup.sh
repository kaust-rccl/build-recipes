#!/bin/bash

if [ -z ${CHIMERE_ROOT} ]; then
	echo "Please set environment variable CHIMERE_ROOT before running this script"
       exit 1
fi


cd modifications
OASIS_DIR=${CHIMERE_ROOT}/oasis3-mct
MYCHIMERE=${CHIMERE_ROOT}/mychimere


cp build-chimere.sh ${CHIMERE_ROOT}/
cp configure.wps.shaheen.gnu $MYCHIMERE/config_wps/
cp configure.wrf.shaheen.gnu $MYCHIMERE/config_wrf433/ 
cp configure.xios.shaheen.gnu $MYCHIMERE/config_xios/
cp Makefile.hdr.shaheen.gnu $MYCHIMERE/makefiles.hdr/
cp mychimere-shaheen.gnu $MYCHIMERE/
patch -p 1 ${CHIMERE_ROOT}/WPS4.1/ungrib/src/ngl/g2/dec_jpeg2000.c ./dec_jpeg2000.patch


cp make_CHIMERE $OASIS_DIR/util/make_dir/
cp make.inc $OASIS_DIR/util/make_dir/ 
cp TopMakefileOasis3 $OASIS_DIR/util/make_dir/
cp ../chimere.sh ${CHIMERE_ROOT}/
cp ../statcodes_paths.sh ${MYCHIMERE}/
