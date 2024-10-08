WRF
===

Quick Start
===========

PrgEnv-gnu is currently recommended so you can download source code of WRF and compile it as follows:

```
./get_src.sh 4.6.0
./compile_src.sh wrf gnu dmpar &> wrf-gnu-compile-log.txt
```

The following command compiles WRF for three PrgEnv's:

```
./get_src.sh 4.6.0
for e in cray intel gnu; do
    nohup ./compile_src.sh wrf ${e} dmpar &> wrf-${e}-compile-log.txt &
done
```

History
=======
2024-08-20 WRF is built for the three environments successfully.



WRF-Chem
========

Quick Start
===========

Interactive
-----------

Directly run the following lines:
```
./get_src.sh 4.6.0
for e in cray intel gnu; do
    nohup ./compile_src.sh wrfchem ${e} dmpar &> wrf-${e}-compile-log.txt &
done
```

Through SLURM
-------------
```
sbatch -N 1 -t 24:0:0 compile.slurm
```

History
=======

2024-08-21 WRF-Chem is built for the three environments successfully.
