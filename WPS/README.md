Quick Start
===========

The WPS and WRF versions must be exactly the same. The script `compile_src_WPS.sh` is tested with WRF and WPS version 4.6.

`PrgEnv-intel`:

```
cd build-recipes/WPS/
./get_src_WPS.sh 4.6.0
./compile_src_WPS.sh intel /scratch/$USER/WRF_install/wrf/intel/dmpar/WRF/ &> wps-compile-log.txt
```

`PrgEnv-gnu`:

```
cd build-recipes/WPS/
./get_src_WPS.sh 4.6.0
./compile_src_WPS.sh gnu /scratch/$USER/WRF_install/wrf/gnu/dmpar/WRF/ &> wps-compile-log.txt
```
