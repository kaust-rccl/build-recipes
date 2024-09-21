# Build recipie for Chimere 2023 r2 on Shaheen III

## Installation 
- For installation first download the chimere source from https://www.lmd.polytechnique.fr/chimere/2023_getcode.php


- Untar the source in $MY_SW

- Create the conda environment using the yaml file provided. Please follow the guide on how to create the environment on Shaheen III. 

https://docs.hpc.kaust.edu.sa/soft_env/prog_env/python_package_management/conda/shaheen3.html

- Set environment variable CHIMERE_ROOT to the directory path of untarred source


- Run ./shaheen_setup.sh . Please make sure your PWD is where the directory "modifications" is present.


- submit the build.slurm as a job to compile the code:


```sbatch build.slurm``` 
