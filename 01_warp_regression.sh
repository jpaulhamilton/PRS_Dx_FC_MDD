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
#The processes calculates smoothness estimates using AFNIs 3dFWHMx function (applied on the final residuals)
#(The smoothness estimates are used, at a later stage in 3dCluststim)

startdir=$(pwd)

#VARS imported from 01_warp_regression_launch_script.sh
gender=$1
DR_zips=$2
results_dir=$3
i=$4
subject=$5
zip_file=$6

#Define vars: Template, FSL-dir, Parallel-factor within FSL-processes, Seed-mask, ID
T=/UKB2/new_7_nodes/MNI152_T1_2mm_brain_mask_bin.nii.gz
FSLDIR=/home/robka/fsl/bin
FSLPARALLEL=2; export FSLPARALLEL
node_mask=/UKB2/new_7_nodes/7networks_liberal_resam.nii.gz
resid_dir=${gender}_residuals


#Check if subject is allready done (i.e. has 7 output maps)
ns=`ls $results_dir/${subject}_zstats_applecored_node_* | wc -l`
if [ ! $ns == 7 ] ; then
echo "running subject $subject"

#Get names and path
cp $DR_zips/$zip_file $results_dir/
sleep 5
cd $results_dir/


#unzip - enter - fix
unzip -qq $zip_file -d $subject
sleep 5
rm $zip_file
cd $subject
if [ -d $subject ] && [ ! -f filtered_func_data_clean.nii.gz ] && [ -f $subject/example_func2standard_warp.nii.gz ] ; then
mv $subject/* .
rm -r $subject
fi
#other layout (some zip-files had a diffrent structure)
if [ -d $fMRI ] && [ ! -f filtered_func_data_clean.nii.gz ] && [ -f fMRI/rfMRI.ica/reg/example_func2standard_warp.nii.gz ] && [ -f fMRI/rfMRI.ica/filtered_func_data_clean.nii.gz ] ; then
mv fMRI/rfMRI.ica/reg/example_func2standard_warp.nii.gz .
mv fMRI/rfMRI.ica/filtered_func_data_clean.nii.gz .
mv fMRI/rfMRI_25.dr .
rm -r fMRI
fi


#CLEAN UP - remove old results and clean up in extracted dir
if [ -d reg_standard ] && [ -f rfMRI_100.dr/dr_stage2.nii.gz ] && [ -f reg_standard/filtered_func_data_clean.nii.gz ] ; then
echo "Removing reg_standard/filtered_func_clean + clean_s"
rm reg_standard/filtered_func_data_clean.nii.gz
rm reg_standard/filtered_func_data_clean_s.nii.gz
else
echo "subject done or DR about to start"
fi




#IF data needed for correlation analysis excist, and result-dir does not excist, then run!
if [ -f filtered_func_data_clean.nii.gz ] && [ ! -d reg_standard ] ; then



#processing
mkdir reg_standard
template=$T


#Warp clean fmri to MNI-space
echo "applying warp!"
$FSLDIR/applywarp --ref=$template --in=filtered_func_data_clean --out=reg_standard/filtered_func_data_clean --warp=example_func2standard_warp --interp=spline
sleep 5

#Mask the clean fmri-data with template (masking is now done later in the process to accomodate apple-cor)
if [ -f reg_standard/filtered_func_data_clean.nii.gz ] ; then
echo "Not masking dset"
#$FSLDIR/fslmaths reg_standard/filtered_func_data_clean -mas $template reg_standard/filtered_func_data_clean
sleep 5
fi

#Make STD-over time mask
echo "making std-over-time mask"
$FSLDIR/fslmaths reg_standard/filtered_func_data_clean -Tstd -bin reg_standard/filtered_func_data_clean_stdmask
sleep 5



#Smooth the data -  FSL-formum says this is reasonable (1.8 mm)
if [ -f reg_standard/filtered_func_data_clean_stdmask.nii.gz ] ; then
echo "smoothing data"
$FSLDIR/fslmaths reg_standard/filtered_func_data_clean -s 1.8 reg_standard/filtered_func_data_clean_s
sleep 5
fi

#If data exist, run apple-corr
if [ -f reg_standard/filtered_func_data_clean_s.nii.gz ] ; then
echo "running final regression"

mkdir rfMRI_7.nodes
apple_m_path=/UKB2/new_7_nodes/apple
apple_input=reg_standard/filtered_func_data_clean_s.nii.gz
matlab -nosplash -nodisplay -nojvm -r "addpath(genpath('${apple_m_path}')), applecor('${apple_input}','apple'), exit" >> apple_log_$subject.txt
$FSLDIR/fsl_glm -i reg_standard/filtered_func_data_clean_s -d apple_regs.1D --out_res=reg_standard/residuals --demean -m $template




#Loop through the 7 Yeo resting state netowrk masks
for d in {1..7} ; do

#Do this if the results does not allready excist
if [ ! -f $results_dir/${subject}_zstats_applecored_node_$d.nii.gz ] ; then

#Create average time course from each of the 7 masks
3dmaskave -q -mask $node_mask -mrange ${d} ${d} reg_standard/residuals.nii.gz >> rfMRI_7.nodes/node_${d}_applecored.txt


#Run main regression to generate z-stats for each node (they are apple-corred), also produce residual time-series
$FSLDIR/fsl_glm -i reg_standard/residuals -d rfMRI_7.nodes/node_${d}_applecored.txt --out_z=rfMRI_7.nodes/zstats_applecored_node_$d --demean -m $template
$FSLDIR/fslmaths rfMRI_7.nodes/zstats_applecored_node_$d -mas $template rfMRI_7.nodes/zstats_applecored_node_$d
sleep 5
if [ -f rfMRI_7.nodes/zstats_applecored_node_$d.nii.gz ] ; then
cp rfMRI_7.nodes/zstats_applecored_node_$d.nii.gz $results_dir/${subject}_zstats_applecored_node_$d.nii.gz
fi

fi

done

#CREATE NEW RESIDUALS: This is supposed to be the final error-times-series datasets, from which we estimate spatial smoothness
#reg_standard/residuals = residuals from main regression
#rfMRI_7.nodes/residuals = residuals from main regression, but with the 7-time-series also "regressed out"

1dcat rfMRI_7.nodes/node_1_applecored.txt rfMRI_7.nodes/node_2_applecored.txt rfMRI_7.nodes/node_3_applecored.txt rfMRI_7.nodes/node_4_applecored.txt rfMRI_7.nodes/node_5_applecored.txt rfMRI_7.nodes/node_6_applecored.txt rfMRI_7.nodes/node_7_applecored.txt >> rfMRI_7.nodes/all_nodes_applecored.txt
$FSLDIR/fsl_glm -i reg_standard/residuals -d rfMRI_7.nodes/all_nodes_applecored.txt --out_res=rfMRI_7.nodes/residuals --demean -m $template

#MASK BOTH RESIDUALS
$FSLDIR/fslmaths rfMRI_7.nodes/residuals -mas $template rfMRI_7.nodes/residuals
$FSLDIR/fslmaths reg_standard/residuals -mas $template reg_standard/residuals

#SAVE ORIGINAL RESIDUALS
cp reg_standard/residuals.nii.gz /UKB2/new_7_nodes/fenix_UKB_new/residuals_${gender}/${subject}_residuals_applecored.nii.gz

#Calculate smoothness (se 7networks_liberal_resam.nii.gz as mask, since we will only run stats within the union-mask of the 7-networks
3dFWHMx -ACF NULL -input rfMRI_7.nodes/residuals.nii.gz -mask 7networks_liberal_resam.nii.gz | grep -i -A 1 ACF >> temp_${subject}_acf.txt
acf_x=`sed '2q;d' temp_${subject}_acf.txt`
a=`echo $acf_x | awk '{split($0,array," ")} END{print array[1]}'`
b=`echo $acf_x | awk '{split($0,array," ")} END{print array[2]}'`
c=`echo $acf_x | awk '{split($0,array," ")} END{print array[3]}'`

echo "$a $b $c" >> /UKB2/new_7_nodes/ALL_${gender}_acf.txt


sleep 5
fi


cd ..

rm -r $subject



else
cd ..

rm -r $subject
fi

fi

