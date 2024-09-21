#!/bin/bash
export LANG=en_US
export LC_NUMERIC=C
export LC_ALL=C
ulimit -s unlimited

# Main script for compilation of CHIMERE + OASIS

export chimere_root=`pwd`
arch_defined=false
arch_path='mychimere'
export xios_path='XIOS'
export my_bigarray=Yes
compil_mode=PROD
compile_oasis=false
compile_xios=false

# Deal with prompt 
while (($# > 0))
do
    case $1 in
        "-h"|"--h"|"--help"|"-help") 
            echo "build-chimere.sh - installs CHIMERE and OASIS3-MCT on your architecture"
            echo "build-chimere.sh [options]"
            echo "      [ -h | --h | -help | --help ] : this help message"
            echo "      [--dev | --devel] : compilation in development/debug mode (default : production mode)"
            echo "      [--mychimere | --arch arch] : to choose target architecture (file mychimere/mychimere-arch must exist - default : last architecture used)"
            echo "      [--avail] : to know available target architectures"
            echo "      [--oasis] : to force oasis (re)-compilation "
            echo "      [--xios] : to force XIOS (re)-compilation "
            exit ;;
        "--arch_path") arch_path=$2; shift; shift ;;
        "--xios_path") xios_path=$2; shift; shift ;;
        "--mychimere"|"--arch") arch=$2 ; arch_defined=true ; shift ; shift ;;
        "--devel"|"--dev") compil_mode=DEVEL ; shift ;;
        "--prod") compil_mode=PROD ; shift ;;
        "--prof") compil_mode=PROF ; shift ;;
        "--avail") ls ${arch_path}/mychimere-* | cut -d"-" -f1 --complement | sed 's/^/    /'  ; exit ;;
        "--oasis") compile_oasis=true  ; shift ;;
        "--xios") compile_xios=true  ; shift ;;
        *) code=$1 ; shift ;;

    esac
done

# Where are the source codes
sed -i s:^xios_path=.*:xios_path="${xios_path}":g ./mychimere/statcodes_paths.sh
source ./mychimere/statcodes_paths.sh

export my_mode=${compil_mode}

./scripts/chimere-banner.sh c

# Initialize variables
if ${arch_defined}
then 

    if test -f ${arch_path}/mychimere-${arch}
    then 
        old_arch=$(basename -- $(readlink -f src/mychimere.sh) | cut -d"-" -f1 --complement) 
        if [ ${old_arch} != ${arch} ] ; then
           compile_oasis=true
        fi
        \rm -f src/mychimere.sh
        ln -s ${chimere_root}/${arch_path}/mychimere-${arch} src/mychimere.sh
    else
        echo "Architecture file ${arch_path}/mychimere-${arch} does not exist"
        echo 'Provide an existing one  with : ./build-chimere.sh --arch myarch'
        echo 'List of available architecture file :'
        ls ${arch_path}/mychimere-* | cut -d"-" -f1 --complement | sed 's/^/    /' 
        exit 1
    fi
elif test -e src/mychimere.sh
then
    echo " WARNING : no target architecture file "
    echo " WARNING : using older architecture file "
    ls -l src/mychimere.sh | cut -d">" -f2
    arch=`ls -l src/mychimere.sh | cut -d">" -f2 | awk -F/ '{print $NF}' | cut -d"-" -f1 --complement`
else
    echo 'No architecture file found. You need one'
    echo 'Provide if with : ./build-chimere.sh --arch myarch'
    echo 'List of available architecture file :'
    ls mychimere/mychimere-* | cut -d"-" -f1 --complement | sed 's/^/    /' 
    exit 1
fi

echo ' '
source src/mychimere.sh 

#./scripts/check_config.sh

rm -f src/Makefile.hdr || exit 1
ln -s ../mychimere/makefiles.hdr/${my_hdr} src/Makefile.hdr || exit 1

# MAKE,AWK and NCDUMP are set by the calling script. We check it again
${my_make} --version 2>/dev/null >/dev/null || \
    { echo "You need gmake to run CHIMERE. Bye ..."; exit 1; }

chimverb=5
chimbuild=${chimere_root}/build
exedir=${chimere_root}/exe_${my_mode}
export tmplab=`date +"%s"`


# Compilation of programs in the ${chimbuild} directory

rm -rf ${chimbuild}
mkdir  ${chimbuild}


mkdir -p ${exedir}


#---------------------------------------------------------------------------------------

compildef=ftn #`grep ^FC ${chimere_root}/src/Makefile.hdr|sed s/[[:blank:]]//g`
compilo=`eval echo ${compildef}|sed s,FC,,|sed s,=,,`
unset compildef

which $compilo >/dev/null 2>&1 || { echo "${0}: No real compiler defined. Bye."; exit 1; }

if [ $chimverb -ge 2 ] ; then
    echo "   Compiler: "$compilo
    echo "   Status in: "${garbagedir}/make.${tmplab}.log
    echo "   Using ${my_mode} mode for compiling under architecture ${arch}"
    echo " "
fi

cd ${chimbuild}

if [ -d ${exedir} ] ; then
    [ ${chimverb} -gt 3 ] && echo "   Removing ${exedir}"
    rm -rf ${exedir}
fi

# if a directory already exists, copy in the TMP

imakecompil=1

mkdir -p ${exedir}

wait

if [[ $chimverb -ge 2 ]] ; then
    echo "   Copy of source files"
fi

\cp -fp ${chimere_root}/src/*                       ${chimbuild}

echo "   Use netcdf4/HDF5 parallel library"

# if the user wants to force the compilation, make clean

cd ${chimbuild}

${my_make} clean >/dev/null 2>&1

echo "   Start compilation"


# OASIS compilation
if [ ${compile_oasis} == false ]; then 
    [ -d ${oasis_dir}/bin/lib ] && cd ${oasis_dir}/bin/lib
    if test -e libmct.a && test -e libmpeu.a && test -e libpsmile.MPI1.a ; then 
        echo "   OASIS already compiled. If you want to recompile OASIS please run build-chimere.sh --oasis"
    else
        compile_oasis=true
    fi
fi
if ${compile_oasis} ; then
    echo "   Compiling OASIS..."
    rm -rf ${oasis_dir}/bin
    (cd ${oasis_dir}/util/make_dir; make oasis3_psmile -f TopMakefileOasis3 > ${garbagedir}/make.oasis.${tmplab}.log 2>&1) 
    if [ $? -ne 0 ] ; then
	echo
	echo "================================================="
	tail -20 ${garbagedir}/make.oasis.${tmplab}.log
	echo "================================================="
	echo "OASIS compilation aborted"
	echo "Check file ${garbagedir}/make.oasis.${tmplab}.log"
	echo
	exit 1
    fi
fi

cd ${chimere_root}
# XIOS compilation
if [ ${compile_xios} == false ]; then 
    old_arch=`basename -- $(readlink -f ${xios_dir}/arch.fcm)`
    old_arch=`echo ${old_arch%.*} | sed s/arch-//`
    if test -e "${xios_dir}/bin/xios_server.exe" && [ $arch == $old_arch ] ; then
       echo "   XIOS already compiled. If you want to recompile XIOS please run build-chimere.sh --xios"        
    else
       compile_xios=true
    fi
fi
if ${compile_xios} ; then
    ./build-xios.sh --arch $arch 2>&1
	if [ $? -ne 0 ] ; then
	    echo
	    echo "================================================="
	    tail -20 ${garbagedir}/make.xios.${tmplab}.log
	    echo "================================================="
	    echo "XIOS compilation aborted"
	    echo "Check file ${garbagedir}/make.xios.${tmplab}.log"
	    echo
	    exit 1
	fi
fi
cd ${chimbuild}

# check SSH compilation
if [ -d ${ssh_dir} ]; then 
    old_arch=`basename -- $(readlink -f ${ssh_dir}/mymodules.sh)`
    old_arch=`echo ${old_arch} | sed s/mychimere-//`
    libsshcount=$(find ${ssh_dir}/src/ -maxdepth 1 -name "libssh*.a" -printf '.' | wc -m)
    if [ $libsshcount == "8" ] && [ $arch == $old_arch ] ; then                                         
       export iuse_ssh=USE_SSH    
       echo "   SSH-aerosol already compiled with the same architecture used in CHIMERE. If you want to recompile SSH please build-ssh.sh --arch $arch in SSH-aerosol folder."
    else 
        echo "   SSH-aerosol not compiled. If you want to use SSH-aerosol, please run build-ssh.sh --arch $arch in SSH-aerosol folder."
        echo "   CHIMERE compilation continues without SSH-aerosol."
    fi
fi

# CHIMERE compilation
echo "   Compiling CHIMERE..."
${my_make} all > ${garbagedir}/make.${tmplab}.log 2>&1

if [ $? -ne 0 ] ; then
    echo
    echo "================================================="
    tail -20 ${garbagedir}/make.${tmplab}.log
    echo "================================================="
    echo "CHIMERE compilation aborted"
    echo "Check file ${garbagedir}/make.${tmplab}.log"
    echo
    exit 1
fi
N_warnings_gfortran=`grep -c "Warning" ${garbagedir}/make.${tmplab}.log`
N_warnings_ifort=`grep -c "remark" ${garbagedir}/make.${tmplab}.log`
N_warnings=$(($N_warnings_ifort+$N_warnings_gfortran))
if [ ${N_warnings} -ne "0" ] ; then
    echo -e "\033[01;31;1m   "${N_warnings}" Warnings in CHIMERE compilation. Check file ${garbagedir}/make.${tmplab}.log \033[m"
fi
# if the compilation is OK, save in exedir

[ $? -eq 0 ] || { echo "Abnormal termination of chimere-compil.sh"; exit 1; }

echo -n "   Compilation OK. Saving compiled code to ${exedir}..."
echo

# Copy of results in the EXE directory
# only fortran , C and executable files

rm -rf ${exedir} && mkdir ${exedir}

cp  *.e mychimere.sh ${exedir} || { echo " failed. Bye"'!' ; exit 1; }


ldd ${exedir}/*.e >> ${garbagedir}/checkConfig.log
cd ${chimere_root}

exit 0

