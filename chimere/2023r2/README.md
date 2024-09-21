# Build recipie for Chimere 2023 r2 on Shaheen 3

## Installation 
- For installation first download the chimere source from https://www.lmd.polytechnique.fr/chimere/2023_getcode.php


- Untar the source in $MY_SW


- Set environment variable CHIMERE_ROOT to the directory path of untarred source


- Run ./shaheen_setup.sh . Please make sure your PWD is where the directory "modifications" is present.


- submit the build.slurm as a job to compile the code:


```sbatch build.slurm``` 
