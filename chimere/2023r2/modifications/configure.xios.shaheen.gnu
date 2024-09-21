################################################################################
###################                Projet XIOS               ###################
################################################################################

%CCOMPILER      cc
%FCOMPILER      ${my_mpif90}
%LINKER         ${my_mpif90}  

%BASE_CFLAGS    -w -std=c++11 -D__XIOS_EXCEPTION -include 'limits' -include 'numeric' -include 'array'
%PROD_CFLAGS    -O3 -DBOOST_DISABLE_ASSERTS
%DEV_CFLAGS     -g -O2 
%DEBUG_CFLAGS   -g 

%BASE_FFLAGS    -D__NONE__ -ffree-form -ffree-line-length-none 
%PROD_FFLAGS    -O3
%DEV_FFLAGS     -g -O2
%DEBUG_FFLAGS   -g 

%BASE_INC       -D__NONE__
%BASE_LD        -lstdc++

%CPP            cpp
%FPP            cpp -P
%MAKE           make
