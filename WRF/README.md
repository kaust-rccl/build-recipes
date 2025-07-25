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
2025-07-09 Updated `compile_wrf_gnu.sh` to compile WRF-Chem and ran the reframe test successfully with cpe/25.03 and PrgEnv-gnu/8.6.0.

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
./compile.sh wrf gnu dmpar &> wrf-gnu-compile-log.txt
```

History
=======
2025-07-10 Updated `compile.sh` to compile WRF and ran the reframe test successfully with cpe/25.03 and PrgEnv-gnu/8.6.0.

2024-08-20 WRF is built for the three environments successfully.




