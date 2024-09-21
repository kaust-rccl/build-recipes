#!/bin/bash
unset LANG
ulimit -s unlimited

#-----------------------------------------------------------------------------------------
#  CHIMERE chemistry-transport model 
#
#  Main script for simulations with CHIMERE in offline or online (WRF) modes.
#  Infos and documentation on: http://www.lmd.polytechnique.fr/chimere
#  contact: chimere@lmd.polytechnique.fr
#
#-----------------------------------------------------------------------------------------
# chimere command line arguments, written as:
# ./chimere.sh -par chimere.par -compil prod -startdate 2021033100 -hours 24 -todo f -restart yes

# Default values

compil_mode=PROD
nhours=24
task=f
chimrestart=yes

while (($# > 0))
do
    case $1 in
    
        "-par") 
            if [ ${2:0:1} == "-" ] ; then
               echo "Wrong chimparams option $2"; exit 1
            else
               export chimparams=$2 
            fi
         shift ; shift ;; 
        "-todo") 
            case $2 in
               f) export tast=f ;;
               s) export task=s ;;
               p) export task=p ;;
               *) echo "Wrong task option $2"; exit 1 ;;
            esac
         shift ; shift ;;
        "-startdate") export idatestart=$2 ; 
            if [[ $(expr "x$2" : "x[0-9]*$") -gt 0 && $(expr length $idatestart) -eq 10 ]] ; then
               export idatestart=$2
            else 
               echo "Wrong startdate option $2"; exit 1
            fi 
         shift ; shift ;;
        "-hours")
            if [ $(expr "x$2" : "x[0-9]*$") -gt 0 ] ; then
               export nhours=$2
            else 
               echo "Wrong nhours option $2"; exit 1
            fi
         shift ; shift ;;
        "-compil")
            case $2 in
               devel) export compil_mode="DEVEL" ;;
               prod) export compil_mode="PROD" ;;
               prof) export compil_mode="PROF" ;;
               *) echo "Wrong compil option $2"; exit 1 ;;
            esac
	     shift ; shift ;;
        "-restart")
            case $2 in
               optional) export chimrestart="optional" ;;
               yes) export chimrestart="yes" ;;
               no) export chimrestart="no" ;;
               nothing) export chimrestart="nothing" ;;
               *) echo "Wrong restart option $2"; exit 1 ;;
            esac
         shift ; shift ;;
        "-h"|"--h"|"--help"|"-help")	
        echo "Usage: ./chimere.sh -par <param_file> -todo <task>"
        echo "                    -startdate <idatestart> -hours <nhours>"
        echo "                    -compil <compil_mode> -restart <chimrestart>"
        echo ""
        echo "The following arguments are mandatory:"
        echo "   <param_file> : chimere.par parameter file "
        echo "   <task> :  (s)equential : only sequential pre-processing part of CHIMERE " 
        echo "             (p)arallel : only parallel computing part of CHIMERE "
        echo "             (f)ull : both pre-preprocessing and computing part of CHIMERE (s+p) "
        echo "   <idatestart> : in format YYYYMMDDHH"
        echo "   <nhours> : number of hours of the run "
        echo ""
        echo "The following arguments are optional:"
        echo "   <compil> : execution in devel or prod mode (default is prod)"
        echo "   <restart> : yes/no/optional/nothing] : "
        echo "               yes aborts if restart end.* file is not found for chimere."
        echo "               no : no restart file - climatology is used"
        echo "               optional takes restart end.* if available, otherwise climatology" 
        echo "               nothing : no need of restart file (i.e. cold start)"
        exit 0 ;;
        *) 
            echo "Wrong option $1" ; exit 1 ;;
    esac
done

if [ -z $idatestart ] ; then
   echo "No startdate provided, exiting ..."
   exit 1 
fi
if [ -z $chimparams ] ; then
   echo "No parameterization file provided, exiting ..."
   exit 1 
fi


echo "----------------------------------------------"
echo "Compilation mode: "${compil_mode}
echo "Parameter file: "${chimparams}
echo "Task: "${task}
echo "Starting date: "${idatestart}
echo "Nb of hours to run: "${nhours}
echo "Restart: "${chimrestart}

# Store the CHIMERE directory
export chimere_root=`pwd`

source ./mychimere/statcodes_paths.sh

export machine_name=`hostname`
# model pathname
export version=`basename ${chimere_root}`

#---------------------------------------------------------------------------------------
# Directory where executables are stored
export exedir=${chimere_root}/exe_${compil_mode}

if [  ! -d ${exedir} ] ; then
   echo "${exedir} is absent"
   echo "Please compile CHIMERE with ./build-chimere.sh"
   exit 1
fi

if [ ! -f ${exedir}/chimere.e ] ; then
   echo "${exedir}/chimere.e is absent"
   echo "Please compile CHIMERE with ./build-chimere.sh"
   exit 1
fi


#---------------------------------------------------------------------------------------
# All system definitions

source ${exedir}/mychimere.sh || \
{ echo '=> Try running ./config.sh mychimere.sh.<my_configuration>' ; exit 1 ; }


# AWK and NCDUMP are set by the calling script. We check it again
${my_awk} --version 2>/dev/null >/dev/null || \
    { echo "You need gawk to run CHIMERE. Bye ..."; exit 1; }
which ${my_ncdump} 2>/dev/null >/dev/null || \
    { echo "You need ncdump to run CHIMERE. Bye ..."; exit 1; }

#---------------------------------------------------------------------------------------
# First print on screen
. ${chimere_root}/scripts/chimere-banner.sh r

# which column of chimere.par should we run? This overrides the "runs" line of chimere.par

runlist=$(gawk '$1=="runs"{s="";for (i=3;i<=NF;i++) if (substr($i,1,1)=="#") break; else s=s" "$i; print s}' ${chimparams})

echo 'runlist: ' ${runlist}

if [ $# -ge 6 ] ; then
   export runlist=$6
fi

#---------------------------------------------------------------------------------------------------
# Get CHIMERE parameters with the chimere.par file

# Get the 1st column to run to set params for the 1st time
for r in ${runlist} ; do
   ru=${r}
   break
done

export chimparash=${chimparams}_${ru}.sh
echo "chimparash file : "`pwd`"/${chimparash}"

. ${chimere_root}/scripts/define_params.sh ${ru} ${idatestart} ${nhours} || exit 1
if [ ${nproc_chimere} == -999 ] ; then
   echo "*** ERROR : nproc_chimere value not specified, exiting"
   exit 1
fi
if [ ${online} != "0" ] && [ ${nproc_wrf} == -999 ] ; then
   echo "*** ERROR : nproc_wrf value not specified, exiting"
   exit 1
fi

# Deduced parameter necessary for WRF preparation
export sdtphys=$((${dtphys}*60))

# Define TMP directory on time for all simulations

export tmplab=$(date +%Y%m%d_%H-%M)
export chimere_tmp=${simuldir}/tmp${di}-${lab}_${task}_${tmplab}
rm -rf ${chimere_tmp}
mkdir -p ${chimere_tmp}

echo "   TMP directory: "${chimere_tmp}
echo "   Execution mode: "${compil_mode}

#---------------------------------------------------------------------------------------------------
# Compilation of WRF and OASIS if online=1
#    Thompson scheme for indirect effects needs:
#       qr_acr_qg.dat qr_acr_qs.dat freezeH2O.dat for WRF3.7
#       qr_acr_qgV3.dat qr_acr_qsV2.dat freezeH2O.dat for WRF4.3
#       They take a long time to be generated. 
#       They are already prepared and in the chemprep/data dir.


export wrf_exe="wrf"
if [ ${online} == "1" ] || [ ${runwrfonly} != "0" ] ; then

   # symbolic links for the Thompson look-up tables
   ln -s ${bigfilesdir}/freezeH2O.dat  ${chimere_tmp}/freezeH2O.dat
   ln -s ${bigfilesdir}/qr_acr_qg.dat  ${chimere_tmp}/qr_acr_qg.dat
   ln -s ${bigfilesdir}/qr_acr_qs.dat  ${chimere_tmp}/qr_acr_qs.dat
   ln -s ${bigfilesdir}/qr_acr_qgV3.dat  ${chimere_tmp}/qr_acr_qgV3.dat
   ln -s ${bigfilesdir}/qr_acr_qsV2.dat  ${chimere_tmp}/qr_acr_qsV2.dat

   # real.exe compiled without OASIS key
   # ndown.exe compiled without OASIS key
   # wrf.exe compiled with OASIS key

   cp ${dir_wrf}/main/*.exe ${chimere_tmp}/.

   export real_exe="real_nO.exe"
   export ndown_exe="ndown_nO.exe"
   export wrf_exe="wrf_O.exe"
   if [ ${runwrfonly} != "0" ] ; then
      export wrf_exe="wrf_nO.exe"
      \cp ${chimere_root}/scripts/wrf_dates.py ${chimere_tmp} 
   fi
  
   if [ ! -f ${chimere_tmp}/${wrf_exe} ] ; then
      echo "${wrf_exe} is absent"
      echo "Please compile WRF with ./build-wrf.sh"
      exit 1
   fi
fi #runwrfonly!=0 or online=1 


# WRF namelist and geog common to offline and online

   export dirowps=${simuldir}/WPS

   echo 
   echo -e "\033[1;47m o Get WRF simulation params from domainlist.nml  \033[0m"

   export runs=${ru}
   . ${chimere_root}/scripts/wrf-params.sh || exit 1
 
   #echo 'passing of wrf arrays into chimere.sh'
   #for idom in 1 2 3 ; do
   #  echo "${idom} ${wrfdom_array[${idom}]} ${geog_file_array[${idom}]}"
   #done
       
   echo 
   echo "Generate WRF namelists from templates"

   . ${chimere_root}/scripts/wrf_makeWPS_namelist.sh || exit 1

#------------------------------------------------------------------------------
if [ ${runwrfonly} == "0" ] ; then

# Bring the scripts and executables into the chimere_tmp directory
# Copy of the exe dir without compilation
. ${chimere_root}/scripts/chimere-copyexe.sh

#------------------------------------------------------------------------------
# chemprep: Make chemistry input files

. ${chimere_root}/scripts/make-chemistry.sh

fi #runwrfonly

#------------------------------------------------------------------------------
# Prepare the domains, and stop if the 'geog' file is needed for anthropogenic preparation
# if online=0 use of chimere-domain.sh to create a false 'geog'
# if online=1, use of geogrid and WPS to prepare the geog file.
# Results are copied in /domains/${dom}

cd ${chimere_root}
echo "Now in "${chimere_root}
for runs in ${runlist} ; do
   export runs
   export chimparash=${chimparams}_${runs}.sh
   if [ ${runwrfonly} == "0" ] ; then
      . ${chimere_root}/scripts/define_params.sh ${runs} ${idatestart} ${nhours}
   fi
   echo
   echo -e "\033[1;47m o Prepare domain and landuse for run ${runs} and domain ${dom} \033[0m"
   . ${chimere_root}/scripts/chimere-domain.sh ${runs}
   [ $? == 0 ] || { echo "Abnormal termination of chimere-domain.sh"; exit 1; }
done
# stop to prepare other data if necessary 
if [ $istopdom -ne 0 ] ; then
   echo "Domains are now ready in ${chimere_root}/domains"
   echo "Now stopping because of istopdom non zero"
   exit 1
fi
# loop over the nested domains is inside this script
if [ ${online} == "1" ] || [ ${runwrfonly} != "0" ] ; then
   . ${chimere_root}/scripts/wrf_makeWRF_namelist.sh || exit 1
fi


#------------------------------------------------------------------------------
# Main loop over the several domains

echo "Runlist: "${runlist}

for runs in ${runlist} ; do


   # Get simulation parameters for the current run, redefine dates, and define some common derived params
   cd ${chimere_root}
   export chimparash=${chimparams}_${runs}.sh
   . ${chimere_root}/scripts/define_params.sh ${runs} ${idatestart} ${nhours} || exit 1

   echo
   echo -e "\033[1;47m o Run $runs starts for domain ${dom} \033[0m"
   echo "   Simulation directory: ${simuldir}"
   echo "   Verbose mode level: "${chimverb}
   
   if [ ${runwrfonly} == "0" ] ; then
     # Prepare the surface data (landuse, z0 etc.)
     . ${chimere_root}/scripts/chimere-datasurf.sh
   fi

   # Initialization of common parameters
   . ${chimere_root}/scripts/chimere-init.sh || exit 1

   if [ $online == "1" ] || [ ${runwrfonly} != "0" ] ; then

   # Obtain the AEROSOL size distribution from ${fnaerosol} for WRF
   # The size distribution of the CHIMERE aerosols is on the third line
   # WRF wants micrometers not meters
      if [ ${bins} == "1" ] ;  then
         export binschimere=`cat ${fnaerosol} | head -3 | tail -1`   
         export chm_sections=`echo $binschimere | \
	        gawk '{ for(i = 1; i <= NF; i++) { printf "  %8.6f, ",$i*1.E+6; } }'`
      else
         # If no aerosols, we create a fake list
         echo 'no aerosols : writing a dummy size distribution in WRF namelist'
         nbinpun=$(($nbins + 1))
         export chm_sections=""
         for i in `seq  $(($nbins + 1))` ; do
            export chm_sections=${chm_sections}' '${i}'.,'
         done
      fi
      echo 'Writing the CHIMERE size distribution into the WRF namelist'
      
      sed -e "s/ _CHM_SECTIONS_/$chm_sections/g" ${chimere_tmp}/namelist_NEW.input > ${chimere_tmp}/namelist_NEW.input.0
      sed -e "s/_WRFRESTART_/$wrfrestart/g" ${chimere_tmp}/namelist_NEW.input.0 > ${chimere_tmp}/namelist_NEW.input.1
      mv -f ${chimere_tmp}/namelist_NEW.input.1 ${chimere_tmp}/namelist.input     # For real use
      cp ${chimere_tmp}/namelist.input ${simuldir}/namelist.input             # For backup

   fi #runwrfonly
   
   # STEP 1 : SEQUENTIAL
   
   export nproc_chimere=$(($nzdoms*$nmdoms))
   
   if [ "${task:0:1}" != "p" ] ; then
      . ${chimere_root}/scripts/chimere-step1.sh
      [ $? == 0 ] || { echo "Abnormal termination of step1.sh"; exit 1; }
   fi   
   if [ "${task:0:1}" == "p" ] ; then
      [ ${iusebound} = "2" ] && iusebound=1
      [ ${iuseini} = "2" ] && iuseini=1
      if [ ${online} == "0" ] && [ ${meteo} == "WRF" ] && [ ${runwrfonly} == "0" ] ; then
         checkexist ${dirowps}/prepwrf.nml_${idatestart}_${nhours}
         cp ${dirowps}/prepwrf.nml_${idatestart}_${nhours} ${chimere_tmp}/prepwrf.nml
         cp ${dirowps}/wrf_dates.txt_${idatestart}_${nhours} ${chimere_tmp}/wrf_dates.txt
      fi
      . ${chimere_root}/scripts/chimere-namelist.sh
      [ $? -eq 0 ] || { echo "Abnormal termination of chimere-namelist.sh"; exit 1; }
   fi
   if [ ${online} == "1" ] || [ ${runwrfonly} != "0" ] ; then
      if [ "${task:0:1}" == "p" ] ; then
         for file in `ls ${dirowps}/*_d0?_${idatestart}` ; do
             fileo=`echo $(basename $file) | awk -F'(_)' '{print $1"_"$2}'`
             ln -sf $file $fileo
         done 
         for file in `ls ${dirowps}/geo_em_d0?` ; do
             ln -sf $file $(basename $file)
         done
         ln -sf ${dirowps}/namelist.input_${idatestart} namelist.input
         for f in  ${dir_wrf}/test/em_real/* ; do
             fname=$(basename "$f")
             if [[ $fname != "namelist"* ]]; then
                # namelist.input has already been generated for the run we do not want to crush it
                ln -sf $f ${chimere_tmp}/ || { echo "Failed linking $f into ${chimere_tmp}. Bye."; exit 1; }
             fi
         done
      fi
      echo "Create the OASIS namcouple"

      # Namcouple file creation from chimere.par parameters.
      . ${chimere_root}/scripts/create_namcouple.sh || exit 1

      # Checkexist.
      cd ${chimere_tmp}
      checkexist ${namcouple}

      echo "Check online parameters consistency"

      . ${chimere_root}/scripts/check-online-params.sh || exit 1

      # If WRF restart option is set to yes then copy the restart file into chimere_tmp directory.
      echo "Check WRF restart option"

      if [[ `get_wrf_param restart` == ".true." ]]; then
          wrstdate=$(date +%Y-%m-%d_00:00:00 -d ${idatestart:0:8})
          wrf_rstfile=${simuldir}/wrfrst_d01_${wrstdate}

          checkexist ${wrf_rstfile}
          echo " o WRF restart file found: "${wrf_rstfile}
          \cp ${wrf_rstfile} ${chimere_tmp}
          if [ $runwrfonly -ge 2 ] ; then
             wrf_rstfile=${simuldir}/wrfrst_d02_${wrstdate}
             \cp ${wrf_rstfile} ${chimere_tmp} || exit 1
          fi
      fi

      echo "Launch WRF-CHIMERE execution"
      echo "   Number of processors for WRF: "${nproc_wrf} " and for CHIMERE: "${nproc_chimere}
      echo "   Number of processors for XIOS: "${nproc_xios}  
      echo "   with mpirun: "${my_mpirun}
      echo "   with WRF: "${wrf_exe}
  
   fi #runwrfonly
   wait


   # STEP 2 : PARALLEL
   
   lamparams="${my_lamparams}"
   ompiparams="${my_ompiparams}"
   
   if [ ${my_mpiframe} == "lam" ] ; then
      export mpiparams="${lamparams}"
   elif [ ${my_mpiframe} == "openmpi" ] ; then
      export mpiparams="${ompiparams}"
   elif [ ${my_mpiframe} == "ccrt" ] ; then
      export mpiparams=""
   elif [ ${my_mpiframe} == "ompi" ] ; then
      export mpiparams=""      
   else
     echo "Seems like Cray"
     #echo "Unknown MPI frame ${my_mpiframe}. Bye"
     #exit 1
   fi
   export mpiparams

   # Run parallel part (CHIMERE core)
   if [ "${task:0:1}" != "s" ] ; then
      echo "Howdy I am in $PWD"
      ${chimere_root}/scripts/chimere-step2.sh
      [ $? == 0 ] || { echo "Abnormal termination of step2.sh"; exit 1; }
   fi

   cd ${chimere_root}

done

#---------------------------------------------------------------------------------------
# clean-up

echo "Clean up tmp files"
[ ${do_clean} == "full" ] && rm -Rf ${chimere_tmp}
[ ${do_clean} == "light" ] && rm -f ${chimere_tmp}/*.nc
if [ "${task:0:1}" == "p" ] && [ "${online}" == 0 ] && [ "${meteo}" == "WRF" ] && [ ${runwrfonly} == "0" ] ; then
   rm -f ${dirowps}/prepwrf.nml_${idatestart}_${nhours}
   rm -f ${dirowps}/wrf_dates.txt_${idatestart}_${nhours}
fi

wait 

echo "End of CHIMERE simulation"   
