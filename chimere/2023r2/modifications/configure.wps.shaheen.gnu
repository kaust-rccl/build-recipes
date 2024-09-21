# configure.wps
#
# This file was automatically generated by the configure script in the
# top level directory. You may make changes to the settings in this
# file but be aware they will be overwritten each time you run configure.
# Ordinarily, it is necessary to run configure once, when the code is
# first installed.
#
# To permanently change options, change the settings for your platform
# in the file arch/configure.defaults, the preamble, and the postamble -
# then rerun configure.
#

.SUFFIXES: .F .f .c .o

SHELL           	=       /bin/sh

NCARG_LIBS		=	-L$(NCARG_ROOT)/lib -lncarg -lncarg_gks -lncarg_c \
				-L/usr/X11R6/lib -lX11

NCARG_LIBS2		=	# May be overridden by architecture specific value below

FDEFS			=	-DUSE_JPEG2000 -DUSE_PNG

# Listing of options that are usually independent of machine type.
# When necessary, these are over-ridden by each architecture.

ARFLAGS			=	

PERL			=	perl

RANLIB			=	echo

WRF_DIR			=	../WRF

WRF_INCLUDE     =       -I$(WRF_DIR)/external/io_netcdf \
                        -I$(WRF_DIR)/external/io_grib_share \
                        -I$(WRF_DIR)/external/io_grib1 \
                        -I$(WRF_DIR)/external/io_int \
                        -I$(WRF_DIR)/inc \
                        -I$(my_netcdfF90inc)

WRF_LIB         =       -L$(WRF_DIR)/external/io_grib1 -lio_grib1 \
                        -L$(WRF_DIR)/external/io_grib_share -lio_grib_share \
                        -L$(WRF_DIR)/external/io_int -lwrfio_int \
                        -L$(WRF_DIR)/external/io_netcdf -lwrfio_nf \
                        -L$(my_netcdfF90lib) -L$(my_netcdfClib) -lnetcdff -lnetcdf  \
                        -Bdynamic -lz\

#### Architecture specific settings ####

COMPRESSION_LIBS	=  # intentionally left blank, fill in COMPRESSION_LIBS below

COMPRESSION_INC		=  # intentionally left blank, fill in COMPRESSION_INC below

#
#   Settings for Linux x86_64, gfortran    (dmpar) 
#
#
COMPRESSION_LIBS    = -L$(my_jasperlib) -ljasper -lpng -lz
COMPRESSION_INC     = -I$(my_jasperinc)
FDEFS               = -DUSE_JPEG2000 -DUSE_PNG
SFC                 = ${my_mpif90}
SCC                 = ${my_mpicc} 
DM_FC               = ${my_mpif90}
DM_CC               = ${my_mpicc}
FC                  = $(DM_FC) 
CC                  = $(DM_CC)
LD                  = $(FC)
FFLAGS              = -ffree-form -O -fconvert=big-endian -frecord-marker=4 -fallow-argument-mismatch -fallow-invalid-boz -craype-verbose
F77FLAGS            = -ffixed-form -O -fconvert=big-endian -frecord-marker=4 -fallow-argument-mismatch -fallow-invalid-boz -craype-verbose
FCSUFFIX            = 
FNGFLAGS            = $(FFLAGS)
LDFLAGS             =
CFLAGS              = -craype-verbose
CPP                 = cpp -P -traditional
CPPFLAGS            = -D_UNDERSCORE -DBYTESWAP -DLINUX -DIO_NETCDF -DBIT32 -DNO_SIGNAL -D_MPI
RANLIB              = ranlib 

########################################################################################################################
#
#	Macros, these should be generic for all machines

LN		=	ln -sf
MAKE		=	make -i -r
RM		= 	/bin/rm -f
CP		= 	/bin/cp
AR		=	ar ru

.IGNORE:
.SUFFIXES: .c .f .F .o

#	There is probably no reason to modify these rules

.c.o:
	$(RM) $@
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<	

.f.o:
	$(RM) $@ $*.mod
	$(FC) $(F77FLAGS) -c $< $(WRF_INCLUDE)

.F.o:
	$(RM) $@ $*.mod
	$(CPP) $(CPPFLAGS) $(FDEFS) $(WRF_INCLUDE) $< > $*.f90
	$(FC) $(FFLAGS) -c $*.f90 $(WRF_INCLUDE)
#	$(RM) $*.f90
