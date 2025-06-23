#!/bin/bash

# Get the PREFIX from ph-ref.in
PREFIX=`awk -F= '{if($0~"prefix") print $NF}' ph-ref.in | sed "s/'//g" | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`

#should be in the work directory of PHonon calculation
echo `pwd`
mkdir -p save/${PREFIX}.phsave

for q_folder in ph-*/;
do
   NQ=`echo $q_folder | sed 's/\///' | awk 'BEGIN{FS="-"}{print $NF}'`
   DIR="$q_folder/tmp/_ph0"
   echo Collecting from $DIR

   #copy prefix.phsave
   cp ${DIR}/${PREFIX}.phsave/* save/${PREFIX}.phsave/

   #copy prefix.dyn0
   cp ${q_folder}/${PREFIX}.dyn0 save/  #${PREFIX}.dyn_q${NQ}

   #copy dyn files
   cp ${q_folder}/${PREFIX}.dyn${NQ}.xml save/  #${PREFIX}.dyn_q${NQ}
   cp ${q_folder}/${PREFIX}.dyn* ./

   #copy dvscf files
   cp ${DIR}/${PREFIX}.q_${NQ}/${PREFIX}.dvscf1 save/${PREFIX}.dvscf_q${NQ}
   #copy prefix.d2nsbare  prefix.dnsbare  prefix.dnsbare_pattern  prefix.dnsscf  prefix.dvscf1
   #write a loop to copy all files with suffix .d2nsbare, .dnsbare, .dnsbare_pattern, .dnsscf, .dvscf1,
   #before copying, check if the file exists
   for suffix in d2nsbare dnsbare dnsbare_pattern dnsscf; do
       filename=${DIR}/${PREFIX}.q_${NQ}/${PREFIX}.${suffix}
       if [ -f "$filename" ]; then
           cp "$filename" save/${PREFIX}.${suffix}_q${NQ}
       else
           echo "File $filename does not exist, skipping."
       fi
   done
done
