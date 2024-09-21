#!/bin/bash
unset LANG

# Static paths of external libraries. Do not change.

# Static path for the OASIS/XIOS/SSH
xios_path=XIOS
export oasis_dir=${chimere_root}/oasis3-mct 
export xios_dir=${chimere_root}/${xios_path} 
export ssh_dir=${chimere_root}/ssh-aerosol

# Static paths for WRF and WPS
export dir_wrf=${chimere_root}/WRF
export dir_wps=${chimere_root}/WPS4.1

# Static paths for the log files
# compilation
export garbagedir=${chimere_root}/compilogs
export logdir=${chimere_root}/RUN_LOGS
export logfile=runChimere

mkdir -p ${logdir}
mkdir -p ${garbagedir}

# compilation keys. Do not change them unless you know what you are doing.
export iuse_ssh=NO_SSH    
export iuse_xios=USE_XIOS
