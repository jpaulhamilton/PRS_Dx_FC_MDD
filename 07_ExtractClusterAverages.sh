#!/bin/bash

#The following Code extracts (first) average Z-score value for Liberal clusters (containing a stringent cluster) for each participant (separatley for sex, node/seed, effect)
#The following Code then extracts average Z-score value for stringent clusters for each participant (separatley for sex, node/seed, effect)
#Output is cluster_averages_big_blob/clust_table_${gender}_n${n}_${stat}_clusternum_$c.txt

FSLDIR=/usr/local/fsl
script_dir=$(pwd)
SR_data=/fenix/users/laros/UKB_resting_state/data_new_appled
mask_dir=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/big_blobs_keep

for gender in male female ; do
for n in {1..7} ; do
current_data_dir=$SR_data/$gender/SR/$n



for f in $current_data_dir/*_zstats_applecored_node_${n}.nii.gz ; do

arrIN=(${f//// })
full_file_name=${arrIN[-1]}
arrIN=(${full_file_name//_/ })
current_subject=${arrIN[0]}
PRS=${arrIN[1]}
MDD=${arrIN[2]}

#For this subject, get all data

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
#curr_mask=$mask_dir/${gender}_n${n}_stat_${stat}_con_lib_intersect.nii
#curr_mask=/fenix/users/robka/UKB_rest_analysis/Clust_mask+tlrc.
if [ -f $curr_mask ] ; then
#number of clusters?
a=`3dinfo -subbrick_info $curr_mask`
number_of_clusters=`echo "${a: -1}"`

for c in $(eval echo "{1..$number_of_clusters}") ; do
#for c in 1 ; do
if [ ! -f cluster_averages_big_blob/clust_table_${gender}_n${n}_${stat}_clusternum_$c.txt ] ; then
echo "SUBJ PRS MDD CON" >> cluster_averages_big_blob/clust_table_${gender}_n${n}_${stat}_clusternum_$c.txt
fi

avg=`3dmaskave -q -mask $curr_mask -mrange $c $c $f`
#avg=`3dmaskave -q -mask $curr_mask -mrange 3 4 $f`
echo "$current_subject $PRS $MDD $avg" >> cluster_averages_big_blob/clust_table_${gender}_n${n}_${stat}_clusternum_$c.txt

#end of cluster loop
done
#end of of mask exist if
fi



#end of stat loop
done



#end of file loop
done


#end of node loop
done
#end of gender loop
done







