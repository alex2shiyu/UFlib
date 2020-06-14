#!/bin/bash
logdir=/public/home/sypeng/LOG/qs.dat
searchdir=/public/home/sypeng/work
for ((i=1;i<81;i=i+1));
do 
    echo -n '-' >> $logdir;
done
echo '' >> $logdir
echo `date +'%Y-%m-%d %H:%M:%S'` >> $logdir
for ((i=1;i<41;i=i+1));
do 
    echo -n '-' >> $logdir;
done
echo '' >> $logdir
squeue -u sypeng | tee -a $logdir | more
for ((i=1;i<61;i=i+1));
do 
    echo -n '-' ;
done
echo ''
for ((i=1;i<41;i=i+1));
do 
    echo -n '-' >> $logdir;
done
echo '' >> $logdir;
#for id in \$(squeue -u sypeng | tail -n +2 | awk '{print \$1}');
for id in $(squeue -u sypeng | tail -n +2 | awk '{print $1}');
#xxlist=squeue -u sypeng | tail -n +2 | awk '{print \$1}'
#for id in xxlist
do 
    ssid='slurm-'"$id"'.out'
    find $searchdir -name $ssid | tee -a $logdir | more ;
done
for ((i=1;i<81;i=i+1));
do 
    echo -n '-' >> $logdir;
done
echo '' >> $logdir
