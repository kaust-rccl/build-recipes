#!/bin/bash
#SBATCH --time 24:0:0
#SBATCH --partition=ppn

for e in cray intel gnu; do
    nohup ./compile.sh wrfchem ${e} dmpar &> wrf-${e}-compile-log.txt &
done
wait
