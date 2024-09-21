#!/bin/bash

#---------------------------------------------------------------------------------
#	Architecture file for compiling and running CHIMERE	
#	Specify path to libraries, compilers and utilities 
#---------------------------------------------------------------------------------


#---------------------------------------------------------------------------------
# 	Compilers
#---------------------------------------------------------------------------------
export my_compilerF90=ftn				# Path to Fortran 90 compiler
export my_compilerC=cc	                	# Path to C compiler
export my_compilerCpp=CC			# Path to C++ compiler


#---------------------------------------------------------------------------------
# 	MPI - parallel execution of chimere
#---------------------------------------------------------------------------------
export  my_mpiframe=      			# implementaion of MPI norm [ ompi / ccrt ] TO REMOVE
export  my_mpibin=${MPICH_DIR}/bin 		# Path to MPI binary directory
export  my_mpirun=$(which srun)    		# Path to mpirun to execute parallel job in MPI
export  my_mpif90=ftn	# Wrapper to my_compilerF90 to link with MPI library
export  my_mpicc=cc		# Wrapper to my_compilerC to link with MPI library
export  my_mpilib=${MPICH_DIR}/lib 		# Path to MPI libraries directory
export  my_mpiinc=${MPICH_DIR}/include   	# Path to MPI include files directory


#---------------------------------------------------------------------------------
# 	HDF5  - parallel version	
#---------------------------------------------------------------------------------
export my_hdflib=${HDF5_DIR}/lib		# Path to HDF5 parallel library directory
export my_hdfinc=${HDF5_DIR}/include		# Path to HDF5 parallel include files directory


#---------------------------------------------------------------------------------
# 	NETCDF-C  - link with HDF5 parallel 
#---------------------------------------------------------------------------------
export my_netcdfCbin=${NETCDF_DIR}/bin 		# Path to NETCDF-C (linked with HDF5 parallel) binaries directory 
export my_netcdfClib=${NETCDF_DIR}/lib		# Path to NETCDF-C (linked with HDF5 parallel) library directory


#---------------------------------------------------------------------------------
# 	NETCDF-Fortran  - link with HDF5 parallel and NETCDF-C
#---------------------------------------------------------------------------------
export my_netcdfF90bin=${NETCDF_DIR}/bin         # PATH to NETCDF-Fortran (linked with HDF5 parallel and NETCDF-C) binaries  directory
export my_netcdfF90lib=${NETCDF_DIR}/lib		# Path to NETCDF-Fortran (linked with HDF5 parallel and NETCDF-C) library  directory
export my_netcdfF90inc=${NETCDF_DIR}/include		# Path to NETCDF-Fortran (linked with HDF5 parallel and NETCDF-C) include files  directory


#---------------------------------------------------------------------------------
# 	GRIB  - link with jasper 
#---------------------------------------------------------------------------------
export my_griblib=${CONDA_PREFIX}/lib     			# Path to GRIB library directory
export my_gribinc=${CONDA_PREFIX}/include 			# Path to GRIB include files directory
export my_jasperlib=${CONDA_PREFIX}/lib 			# Path to JASPER library directory
export my_jasperinc=${CONDA_PREFIX}/include			# Path to JASPER include files directory


#---------------------------------------------------------------------------------
# 	BLITZ
#---------------------------------------------------------------------------------
export my_blitzinc=${BLITZ_DIR}/include		 # Path to BLITZ include files 


#---------------------------------------------------------------------------------
# 	Utilities	
#---------------------------------------------------------------------------------
export my_make=$(which make) 		# Path to make 
export my_awk=$(which awk)			# Path to awk
export my_ncdump=$(which ncdump)		# Path to ncdump
export my_python3=$(which python3)


#---------------------------------------------------------------------------------
# 	Makefile header needed to compile CHIMERE and WRF 
#	     - with this architecture configuration - 	
#---------------------------------------------------------------------------------
export my_hdr=Makefile.hdr.shaheen.gnu   			# Makefile header to compile CHIMERE in makefiles.hdr directory
export configure_wrf_file_name=configure.wrf.shaheen.gnu  	# Makefile header to compile WRF in config_wrf directory
export configure_wps_file_name=configure.wps.shaheen.gnu  	# Makefile header to compile WPS in config_wps directory
export configure_xios_file_name=configure.xios.shaheen.gnu


#---------------------------------------------------------------------------------
#	Export of Shared Library to be available at run time 	
#---------------------------------------------------------------------------------
export LD_LIBRARY_PATH=${my_griblib}:${LD_LIBRARY_PATH}
export PATH=${CONDA_PREFIX}/bin:${PATH}


