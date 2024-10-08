#-*-makefile-*-

### This header file is automatically included in the secondary Makefiles.
### Please tune it to your own installation

### Specify where the headers and libraries of your netCDF package reside.
# Example :
#   if the file libnetcdf.a is located at
#   /opt/netcdf-3.5.1-IFORT-64/lib/libnetcdf.a
#   then NETCDFLIB=/opt/netcdf-3.5.1-IFORT-64/lib
#
#   if the file netcdf.mod is located at
#   /opt/netcdf-3.5.1-IFORT-64/include/netcdf.mod
#   then NETCDFINC=/opt/netcdf-3.5.1-IFORT-64/include
#
# To avoid trouble, netCDF should have been compiled with the
# same compiler you use to build CHIMERE
# In most Linux distributions, netCDF has been compiled using gfortran.
# This may not be compatible with the f90 compilers required for CHIMERE.
#
NETCDFBIN_F	=       $(my_netcdfF90bin)
NETCDFBIN_C	=       $(my_netcdfCbin)
NETCDFLIB	=       $(my_netcdfF90lib)
NETCDFINC	=       $(my_netcdfF90inc)
HDF5LIB		=       $(my_hdflib)
HDF5INC		=       $(my_hdfinc)

### If you want to build the ECMWF meteo interface, you need the ECMWF
#   "GRIB_API" package and you must tell where to find it
GRIBLIB         =       $(my_griblib)
GRIBINC         =       $(my_gribinc)
JASPLIB         =       $(my_jasperlib)
BLITZLIB	=	$(my_blitzinc)

### Where is your compiler located
### You can get it by issuing the command "which ifort"
REALFC	=	ftn

REALCC	=	cc

### Where is your mpif77 wrapper located
### You can get it by issuing the command "which mpif77"
MF90	=	ftn

### Choose your execution mode { PROD | DEVEL }
### PROD is fast, DEVEL allows for more checking and error tracking
MODE	=	${my_mode}

### If you work with a high resolution grid and many levels, the size of
#   your data segment may be higher than 2 GB. In this case, CHIMERE shall
#   be compiled with special options. If you choose BIGARRAY = YES, then
#   these special options will be selected, at the expense of a slower
#   run-time execution. Please note that the lam and netCDF libraries
#   shall also be built for large addressing space. Refer to the LAM and NETCDF
#   HOWTOs in this directory.
BIGARRAY = ${my_bigarray}

### With some 4 GNU/Linux distribution, you may
#   experience problems with ifort and Interprocedural Optimisation.
#   If this is the case, you should disable it.
#   Otherwise just comment out the following line to get the maximum
#   performance of CHIMERE.
#FC4_BUG = -no-ipo

#########################################################################
### In principle, you should not have to modify too many things below ...
# NetCDF config for various possible cases (nc-config/nf-config, hdf5, etc.)
INFCONFIG		=	$(shell [ -e $(NETCDFBIN_F)/nf-config ]&& echo yes)
INCCONFIG		=	$(shell [ -e $(NETCDFBIN_C)/nc-config ]&& echo yes)
ifeq ($(INFCONFIG),yes)
	NCCONFIG          =       $(NETCDFBIN_F)/nf-config
else ifeq ($(INCCONFIG),yes)
	NCCONFIG          =       $(NETCDFBIN_C)/nc-config
else
	NCCONFIG          =       none
endif
#
ifeq ($(NCCONFIG),none)
	NCFLIB		=	$(shell [ -e $(NETCDFLIB)/libnetcdff.a ]&& echo twolibs)
	CULIB		=	$(shell nm $(NETCDFLIB)/libnetcdf.a | grep -q curl && echo need_curl)
	HDLIB		=	$(shell [ -e $(NETCDFBIN_C)/nc-config ]&& $(NETCDFBIN_C)/nc-config --has-hdf5)
	ifeq ($(NCFLIB),twolibs)
	CDFLIB          =       -lnetcdff -lnetcdf
	else
	CDFLIB          =       -lnetcdf
	endif
	ifeq ($(HDLIB),yes)
	CDFLIB1          =       $(CDFLIB) -lhdf5 -lhdf5_hl
	else
	CDFLIB1          =       $(CDFLIB)
	endif
	ifeq ($(CULIB),need_curl)
	CDFLIBS         =       $(CDFLIB1) -lcurl
	else
	CDFLIBS         =       $(CDFLIB1)
	endif
	NETCDFLIBS		=	$(CDFLIBS) -L${NETCDFLIB} -L${HDF5LIB}
else
	NETCDFLIBS		=	$(shell $(NCCONFIG) --flibs | gawk '{for (i=1;i<=NF;i++) if(substr($$i,1,2)=="-L" || substr($$i,1,2)=="-l") st=st" "$$i}END{print st}')
endif

# End netcdf config

MPIFC	=	$(MF90)
FC	=	$(REALFC)
MPIFLAG	=	MPI

##### IFORT #####
COMPILO	=	FINE
F77=$(FC)
ifeq	($(MODE),DEVEL)
# For debug/development
#F77FLAGS1 = -I${NETCDFINC} -fpe0 -ip -mp1 -prec-div -fpp -ftrapuv -pg  -check bounds  -traceback -DIFORT -D$(MPIFLAG) $(FC4_BUG) -r8 -warn unused # -real-size 64 -craype-verbose
F77FLAGS1 = -I${NETCDFINC} -cpp -ftrapuv -pg  -check bounds -traceback  -D$(MPIFLAG) $(FC4_BUG)  -warn unused # -real-size 64 -craype-verbose -g
CCFALGS= -g -traceback -debug all -craype-verbose
endif
ifeq	($(MODE),PROD)
# for production
#F77FLAGS1 = -I${NETCDFINC} -fpe0 -fpp -O2  -ip -mp1 -prec-div -DIFORT -D$(MPIFLAG) $(FC4_BUG) -r8 # -real-size 64 -fdefault-real-8
F77FLAGS1 = -I${NETCDFINC} -cpp -ftrapv -pg  -fcheck=bounds -fbacktrace -D$(MPIFLAG) $(FC4_BUG)  -Wunused -freal-4-real-8 -fno-range-check -ffree-line-length-0 -fallow-argument-mismatch -fallow-invalid-boz # -real-size 64 -craype-verbose
CCFLAGS= -lifcore -O3 -fp-model fast=2 -g
endif
ifeq	($(MODE),PROF)
# for profiling
#F77FLAGS1 = -I${NETCDFINC} -fpe0 -fpp  -traceback -DIFORT -D$(MPIFLAG) $(FC4_BUG) -r8 -g -p # -real-size 64
F77FLAGS1 = -I${NETCDFINC} -cpp -g -traceback -D$(MPIFLAG) $(FC4_BUG)  -warn unused # -real-size 64 -craype-verbose
CCFALGS= -g -traceback -debug all
endif

ifeq	($(BIGARRAY),YES)
# For data segment > 2GB
F77FLAGS = $(F77FLAGS1) -mcmodel=medium -i-dynamic
else
F77FLAGS = $(F77FLAGS1)
endif
FFLAGS_BIG = $(F77FLAGS) -free -lstdc++ 
#FFLAGS = -I${GRIBINC}  $(F77FLAGS) -free -lstdc++ -no-wrap-margin
FFLAGS = -I${GRIBINC}  $(F77FLAGS) -free -lstdc++  -g



# For OASIS compilation
export CHAN=MPI1
export F90=$(my_mpif90) -I${my_mpiinc}
export F=$(F90)
export f90=$(F90)
export f=$(F90)
export CC=$(my_mpicc) -I${my_mpiinc}
export LD=$(my_mpif90) -L${my_mpilib}
export NETCDF_INCLUDE1=$(my_netcdfF90inc)
export NETCDF_INCLUDE2=/usr/lib64/gfortran/modules
export NETCDF_LIBRARY=-L/usr/lib64 $(CDFLIB) $(my_hdflib)
export FLIBS=$(NETCDF_LIBRARY)
export CPPDEF=-Duse_netCDF -Duse_comm_$(CHAN) -D__VERBOSE -DTREAT_OVERLAY
export F90FLAGS=-g -ffree-line-length-0 -fbounds-check $(CPPDEF) -I${NETCDF_INCLUDE1} -I${NETCDF_INCLUDE2}
export f90FLAGS=-g -ffree-line-length-0 -fbounds-check $(CPPDEF) -I${NETCDF_INCLUDE1} -I${NETCDF_INCLUDE2}
export fFLAGS=-g -ffree-line-length-0 -fbounds-check $(CPPDEF) -I${NETCDF_INCLUDE1} -I${NETCDF_INCLUDE2}
export CCFLAGS=$(CPPDEF) -I${NETCDF_INCLUDE} -I${GFORTRAN_INC_MOD}


# Misc. commands
RM	=	/bin/rm -f
AR	=	/usr/bin/ar
CPP	=	/usr/bin/cpp
LN	=	/bin/ln -sf
CD	=	cd

.SUFFIXES:
