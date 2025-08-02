
#!/bin/bash
#PBS -P MATS1366
#PBS -N dos
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=96:00:00
#PBS -q smp
#PBS -m be
#PBS -M zementsega100@gmail.com
#PBS -r n
#PBS -o /home/ztsegaye/lustre/workstation/wsse/wsse2
#PBS -e /home/ztsegaye/lustre/workstation/wsse/wsse2
#PBS

module purge
#module load chpc/python/anaconda/3-2019.10
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
pushd  /home/ztsegaye/lustre/workstation/wsse/wsse2
lfs setstripe -d  /home/ztsegaye/lustre/workstation/wsse/wsse2
lfs setstripe -c 12 .

projwfc.x   < pdos.in> pdos.out 
popd

