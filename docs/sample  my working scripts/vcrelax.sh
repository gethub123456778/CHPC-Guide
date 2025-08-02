
#!/bin/bash
#PBS -P MATS1366
#PBS -N vcrelax
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=24:00:00
#PBS -q normal
#PBS -m be
#PBS -M zemenetsega100@gmail.com
#PBS -r n
#PBS -o /home/ztsegaye/lustre/workstation/test/vcrelax/ecut
#PBS -e /home/ztsegaye/lustre/workstation/test/vcrelax/ecut
#PBS

module purge
#module load chpc/python/anaconda/3-2019.10
module load chpc/qespresso/6.7/parallel_studio/2020u1

ulimit -s unlimited
pushd  /home/ztsegaye/lustre/workstation/test/vcrelax/ecut
lfs setstripe -d /home/ztsegaye/lustre/workstation/test/vcrelax/ecut
lfs setstripe -c 12 ./

mpirun -np 24 pw.x <vcrelax1.in  > vcrelax.out


popd

