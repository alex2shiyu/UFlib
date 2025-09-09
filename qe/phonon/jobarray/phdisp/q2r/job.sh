





 EXEFILE=/global/cfs/cdirs/m2626/sypeng/soft/qe-7.2_GPU-nvdia23.1-toolkit/bin/q2r.x
 INPUTFILE=q2r.in
 OUTPUTFILE=q2r.out

  srun -N $total_nodes -n $total_mpi_tasks -c $cpus_per_task \
     --cpu_bind=cores --gpus-per-task=1 --gpu-bind=single:1 \
     $EXEFILE -npools $total_mpi_tasks -i $INPUTFILE > $OUTPUTFILE
