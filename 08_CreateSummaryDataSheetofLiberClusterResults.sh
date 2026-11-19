#!/bin/bash

#This generates all_averages_$gender.csv
# The file(s) contains the average Z-score value from each of the liberal clusters (containing a stringent cluster)
# The output file has a column for each cluster (split by node/seed and effect)


FSLDIR=/usr/local/fsl
script_dir=$(pwd)
SR_data=/fenix/users/laros/UKB_resting_state/data_new_appled
#mask_dir=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/big_blobs_keep
avg_data_dir=/fenix/users/laros/UKB_resting_state/data_new_appled/stats/cluster_averages_big_blob



for gender in female male ; do
once_per_gender=1
once_per_gender2=1
mapfile -t subjects < $script_dir/subject_list_${gender}.txt



for subject in "${subjects[@]}"; do
echo "Runnign subject $subject which is a $gender"
once_per_subject=1
subject_pos=3
header_pos=3

#goign into reseults files dir
cd $avg_data_dir


for res_file_name in *_${gender}*.txt ; do
once_per_res_file=1

#echo $res_file_name
#extract seed-node, effect and related cluster num - to make column names
arrIN=(${res_file_name//_/ })
node_num=${arrIN[3]}
effect_num=${arrIN[4]}
clust_num=${arrIN[6]}
arrIN2=(${clust_num//./ })
clust_num=${arrIN2[0]}
#get PRS and MDD status - this is only run once per subject

row=$(awk -v subj="$subject" '$1 == subj {print; exit}' "$res_file_name")
arrIN3=(${row// / })

if [ $once_per_subject -eq 1 ] ; then
PRS_status=${arrIN3[1]}
MDD_status=${arrIN3[2]}
#set
subject_array[0]=$subject
subject_array[1]=$PRS_status
subject_array[2]=$MDD_status
fi
once_per_subject=0


#set first row info
if [ $once_per_gender -eq 1 ] ; then
#declare header of gender file
declare -a header
# Add known columns
header[0]="SUBJ"
header[1]="PRSstatus"
header[2]="MDDstatus"
fi
once_per_gender=1


#alter header by adding a column once per this loop:
#if [ $name_count -eq 0 ] ; then
header_in="Node_${node_num}_Stat${effect_num}_Clust${clust_num}"
header[$header_pos]=$header_in
header_pos=$((header_pos + 1))
#fi

#name_count=1


#alter subject array by adding matching data for the above column
subject_array[$subject_pos]=${arrIN3[3]}
subject_pos=$((subject_pos + 1))







#done file name
done
cd $script_dir

#Here we print our results - header should only be printed once (beofre first subject).
#Then one per subject loop
#print header
#printprint

if [ $once_per_gender2 -eq 1 ] ; then
printf '%s ' "${header[@]}" >> all_averages_$gender.csv
echo >> all_averages_$gender.csv
fi
once_per_gender2=0
unset header

#print subject
printf '%s ' "${subject_array[@]}" >> all_averages_$gender.csv
echo >> all_averages_$gender.csv
unset subject_array


#done subject
done



#done gender
done




