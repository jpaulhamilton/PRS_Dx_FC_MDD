#!/bin/bash

# Script checks the Liberal clusters that contained stringent cluster,
# And prints out WHICH stringent clusters that a given liberal cluster containts
# Output: blob_controlling/${gender}_n${n}_stat_${stat}_con_lib_intersect.txt
# Example: female_n1_stat_1_con_lib_intersect.txt
# Content:
#BigBlob,OverlapsWithSmalBlob
#1,3
#2,1
#3,2
# Meaning: For results from females, using seed 1, with liberal threshold results form main effect 1 (PRS),
# Those liberal clusters (clusternum 1 , 2 , 3) containted the liberal clusters from the corresponding stringent results (clusternum 1, 3, 2)

FSLDIR=/usr/local/fsl
script_dir=$(pwd)
big_blob_dir=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/big_blobs_keep
#node_mask=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/7networks_liberal_resam.nii.gz

for gender in male female ; do
for n in {1..7} ; do

#For each mask, get each cluster
#stat: 1 = PRS, 2 = MDD, 3 = interaction
for stat in {1..3} ; do
if [ $stat == 1 ] ; then
stat_name=PRS
elif [ $stat == 2 ] ; then
stat_name=MDD
elif [ $stat == 3 ] ; then
stat_name=interaction
fi

curr_big_blob=$big_blob_dir/${gender}_n${n}_stat_${stat}_con_lib_intersect.nii
if [ -f $curr_big_blob ] ; then
#number of clusters?
a=`3dinfo -subbrick_info $curr_big_blob`
number_of_big_clusters=`echo "${a: -1}"`

for c in $(eval echo "{1..$number_of_big_clusters}") ; do
#for c in 1 ; do
if [ ! -f blob_controlling/${gender}_n${n}_stat_${stat}_con_lib_intersect.txt ] ; then
echo "BigBlob,OverlapsWithSmalBlob" >> blob_controlling/${gender}_n${n}_stat_${stat}_con_lib_intersect.txt
fi

#make mask of single cluster
3dcalc -a $curr_big_blob -expr "equals(a,${c})" -prefix temp_${c}.nii

#compare with stringent clusters
#number of total stringent clusters?
stringent_cluster_mask=stringent_cluster_masks/${gender}_n${n}_stat_${stat}_002_mask.nii
a=`3dinfo -subbrick_info $stringent_cluster_mask`
number_of_small_clusters=`echo "${a: -1}"`

overlap_counter=()
for nc in $(eval echo "{1..$number_of_small_clusters}") ; do
3dcalc -a $stringent_cluster_mask -expr "equals(a,${nc})" -prefix NM_temp_${nc}.nii
overlap_count=`3dOverlap temp_${c}.nii NM_temp_${nc}.nii`

if [ $overlap_count != 0 ] ; then
overlap_counter+=($nc)
fi


rm NM_temp_${nc}.nii
#end of nc loop
done

echo "${c},${overlap_counter[@]}" >> blob_controlling/${gender}_n${n}_stat_${stat}_con_lib_intersect.txt
rm temp_${c}.nii
#end of cluster loop
done
#end of of mask exist if
fi






#end of stat loop
done


#end of node loop
done
#end of gender loop
done




