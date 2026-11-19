#!/bin/bash

# cycles through conservative and liberally thresholded maps
# and writes a volume that keeps liberally thresholded clusters
# that overlap with conservatively defined clusters
# Script generates ${sex}_n${network}_stat_${stat}_con_lib_intersect.nii files, which are the clusters from liberal thresholding
# IF that cluster contains a stringent cluster (from the same "effect")
# Output: big_blobs_keep/${sex}_n${network}_stat_${stat}_con_lib_intersect.nii


for sex in male female ; do

for network in 1 2 3 4 5 6 7 ; do

for stat in 1 2 3 ; do


if [ -f ./stringent_cluster_masks/${sex}_n${network}_stat_${stat}_002_mask.nii ] ; then
blobcount=`3dBrickStat -max ./big_blobs_all/${sex}_n${network}_stat_${stat}_02_mask.nii`

i=0
while [ ${i} -lt ${blobcount} ] ; do
i=$((${i} + 1))
3dcalc -a ./big_blobs_all/${sex}_n${network}_stat_${stat}_02_mask.nii -expr "equals(a,${i})" -prefix temp_${i}.nii
intercount=`3dOverlap temp_${i}.nii ./stringent_cluster_masks/${sex}_n${network}_stat_${stat}_002_mask.nii`
echo ${intercount}
if [ ${intercount} == 0 ] ; then
rm temp_${i}.nii
fi
done

temp_files=`ls temp* | wc -l`

if [ $temp_files != 0 ] ; then
3dMean -sum -prefix keepers.nii temp_*.nii
3dClusterize -inset keepers.nii -idat 0 -ithr 0 -NN 1 -within_range 1 1 -pref_map ./big_blobs_keep/${sex}_n${network}_stat_${stat}_con_lib_intersect.nii

rm temp_*.nii
rm keepers.nii
fi

fi

done

done

done


