WRF-Chem
========

Quick Start
===========

Interactive
-----------

Directly run the following lines:
```
git clone https://github.com/kaust-rccl/build-recipes.git
cd build-recipes/WRF
source compile_wrf_gnu.sh &> wrfchem-gnu-compile-log.txt
```

History
=======

2024-09-26 `compile_wrf_gnu.sh` to compile WRF-Chem with quilting in PrgEnv-gnu.

2024-08-21 WRF-Chem is built for the three environments successfully.

WRF
===

Quick Start
===========

PrgEnv-gnu is currently recommended so you can download source code of WRF and compile it as follows:

```
git clone https://github.com/kaust-rccl/build-recipes.git
cd build-recipes/WRF
./get_src.sh 4.6.0
./compile_src.sh wrf gnu dmpar &> wrf-gnu-compile-log.txt
```

The following command compiles WRF for three PrgEnv's:

```
git clone https://github.com/kaust-rccl/build-recipes.git
cd build-recipes/WRF
./get_src.sh 4.6.0
for e in cray intel gnu; do
    nohup ./compile_src.sh wrf ${e} dmpar &> wrf-${e}-compile-log.txt &
done
```

History
=======
2024-08-20 WRF is built for the three environments successfully.




