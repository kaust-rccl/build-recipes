#!/bin/bash
#SBATCH --time 12:0:0
#SBATCH --partition=ppn

for e in cray intel gnu; do
    nohup ./compile_src.sh wrfchem ${e} dmpar &> wrf-${e}-compile-log.txt &
done
wait
