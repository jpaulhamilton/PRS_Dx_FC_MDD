#!/bin/bash

#This script will launch the processing script 01_warp_regression.sh, using parallel processing on a multi-thread cpu server
#The processes warps UKB-rsfMRI data to MNI-space (MNI152_T1_2mm_brain_mask_bin.nii.gz)
#The processes applies smoothing the data with 1.8 mm kernel
#The processes runt applecor on the warped data
#The processes generates 7 average time courses from the 7 Yeo et.al network masks applied to the post-applecor data
#The processes run 7 full brain correlations using the created averge timecourses from the post-applecor data - also saves original residuals (error-term) from this correlation
#The processes applies the template (MNI152_T1_2mm_brain_mask_bin.nii.gz) as a mask on each of 7 generated Z-score maps
#The processes creates final "residuals" / error-time-series for estimation of spatial smoothness (for family-wise-error-corrections)
#The processes creates final residuals by running a regression on the original residuals using all 7 time-courses (Yeo et al seeds) and save the error-term (final-residuals)
#The processes masks both the original residuals and final residuals with the template (MNI152_T1_2mm_brain_mask_bin.nii.gz)
#The processes calculates smoothness estimates using AFNIs 3dFWHMx function (applied on the final residuals
#(The smoothness estimates are used, at a later stage in 3dCluststim)

startdir=$(pwd)

#VARS
gender=males
#gender=females

#Paths and maximum parallel subjects
DR_zips=/UKB2/prop_match_data/$gender
results_dir=/UKB2/new_7_nodes/$gender
MaximumThreads=8


cd $DR_zips
sub_list=(*)
cd $startdir

while read i; do
  

arrIN=(${i//.zip/ })
subject=${arrIN[0]}
zip_file=$i


ns=`ls $results_dir/${subject}_zstats_applecored_node_* | wc -l`

if [ ! $ns == 7 ] ; then

./run_DR_execute_7nodes_fix.sh $gender $DR_zips $results_dir $i $subject $zip_file &

((threads++))
if [ $threads -eq "$MaximumThreads" ]; then
wait
threads=0
fi

fi

#done
done <missing_list_${gender}.txt
