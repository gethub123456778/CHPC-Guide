#!/bin/bash
#PBS -P MATS1366
#PBS -N Dos
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=24:00:00
#PBS -q normal
#PBS -m be
#PBS -M zementsega100@gmail.com
#PBS -r n
#PBS -o /home/ztsegaye/lustre/workstation/wsse/sample/ecut/dos
#PBS -e /home/ztsegaye/lustre/workstation/wsse/sample/ecut/dos
#PBS

module purge
#module load chpc/python/anaconda/3-2019.10
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
pushd  /home/ztsegaye/lustre/workstation/wsse/sample/ecut/dos
lfs setstripe -d /home/ztsegaye/lustre/workstation/wsse/sample/ecut/dos
lfs setstripe -c 12 ./

   mpirun -np 24 dos.x <dos-5.in> dos-5.out


popd

