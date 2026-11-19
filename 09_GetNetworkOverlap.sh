#!/bin/bash

#This script generates text files which describe which brain netwokrs (1-7 from Yeo et al) that the results clusters are located in
#The script does it first for liberal clusters and then for stringent cluster
#Output: big_blob_network_overlap/clust_table_${gender}_n${n}_${stat}.txt
#Output: stringent_network_overlap_files/clust_table_${gender}_n${n}_${stat}.txt
#Example:
#Output file: clust_table_female_n1_1.txt
#Cluster,OverlapsWith
#1,3 4 6
#2,3 6 7
#3,1 3 6 7
#Meaning: Results from females, seed=1, effect = 1 (PRS)
#Cluster number 1 lands in network 3 4 6
#Cluster number 2 lands in network 3 6 7
#Cluster number 3 lands in network 1 3 6 7 

FSLDIR=/usr/local/fsl
script_dir=$(pwd)
mask_dir=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/big_blobs_keep
node_mask=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/7networks_liberal_resam.nii.gz

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

curr_mask=$mask_dir/${gender}_n${n}_stat_${stat}_con_lib_intersect.nii
if [ -f $curr_mask ] ; then
#number of clusters?
a=`3dinfo -subbrick_info $curr_mask`
number_of_clusters=`echo "${a: -1}"`

for c in $(eval echo "{1..$number_of_clusters}") ; do
#for c in 1 ; do
if [ ! -f big_blob_network_overlap/clust_table_${gender}_n${n}_${stat}.txt ] ; then
echo "Cluster,OverlapsWith" >> big_blob_network_overlap/clust_table_${gender}_n${n}_${stat}.txt
fi

#make mask of single cluster
3dcalc -a $curr_mask -expr "equals(a,${c})" -prefix temp_${c}.nii

#compare with 7 node mask and see which nodes it overlaps with
overlap_counter=()
for NC in 1 2 3 4 5 6 7 ; do
3dcalc -a $node_mask -expr "equals(a,${NC})" -prefix NM_temp_${NC}.nii
overlap_count=`3dOverlap temp_${c}.nii NM_temp_${NC}.nii`

if [ $overlap_count != 0 ] ; then
overlap_counter+=($NC)
fi


rm NM_temp_${NC}.nii
#end of NC loop
done

echo "${c},${overlap_counter[@]}" >> big_blob_network_overlap/clust_table_${gender}_n${n}_${stat}.txt
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





FSLDIR=/usr/local/fsl
script_dir=$(pwd)
mask_dir=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/stringent_cluster_masks
node_mask=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/7networks_liberal_resam.nii.gz

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

curr_mask=$mask_dir/${gender}_n${n}_stat_${stat}_002_mask.nii
if [ -f $curr_mask ] ; then
#number of clusters?
a=`3dinfo -subbrick_info $curr_mask`
number_of_clusters=`echo "${a: -1}"`

for c in $(eval echo "{1..$number_of_clusters}") ; do
#for c in 1 ; do
if [ ! -f stringent_network_overlap_files/clust_table_${gender}_n${n}_${stat}.txt ] ; then
echo "Cluster,OverlapsWith" >> stringent_network_overlap_files/clust_table_${gender}_n${n}_${stat}.txt
fi

#make mask of single cluster
3dcalc -a $curr_mask -expr "equals(a,${c})" -prefix temp_${c}.nii

#compare with 7 node mask and see which nodes it overlaps with
overlap_counter=()
for NC in 1 2 3 4 5 6 7 ; do
3dcalc -a $node_mask -expr "equals(a,${NC})" -prefix NM_temp_${NC}.nii
overlap_count=`3dOverlap temp_${c}.nii NM_temp_${NC}.nii`

if [ $overlap_count != 0 ] ; then
overlap_counter+=($NC)
fi


rm NM_temp_${NC}.nii
#end of NC loop
done

echo "${c},${overlap_counter[@]}" >> stringent_network_overlap_files/clust_table_${gender}_n${n}_${stat}.txt
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




