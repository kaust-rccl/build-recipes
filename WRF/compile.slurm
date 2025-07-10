#!/bin/bash
#SBATCH --time 24:0:0
#SBATCH --partition=ppn

for e in gnu; do
    nohup ./compile.sh wrf ${e} dmpar &> wrf-${e}-compile-log.txt &
done
wait
