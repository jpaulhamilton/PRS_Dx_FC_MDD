#!/bin/bash

#This script runs through all results (sex, network, stat (1=PRS, 2=MDD, 3=Inteaction)
#The script uses 3dClusterize to create binary results masks, only keeping significant clusters
#The scrip uses the thresholds calculated by 3dFWHMx (executed in 01_warp_regression.sh) + 3dClustsim (executed in 03_3dClustSim.sh) to get "stringent" masks (p<0.002 + min 34 voxels)
#The scrip uses p<0.002 and min 149 voxels (males) and p<0.002 and min 150 voxels (females) to get "liberal"/"bigBlob" masks

cd stringent_clusters/

for sex in male female ; do

for network in 1 2 3 4 5 6 7 ; do

for stat in 1 2 3 ; do



if [ $sex == male ] ; then
#Small blobs
3dClusterize -nosum -1Dformat -inset /fenix/users/laros/UKB_resting_state/data_new_appled/stats/SR_results_${sex}_n${network}+tlrc.HEAD \
-idat ${stat} -ithr ${stat} -NN 1 -clust_nvox 34 -1sided RIGHT_TAIL p=0.002 -pref_map stringent_cluster_masks/${sex}_n${network}_stat_${stat}_002_mask.nii

#Big blobs
3dClusterize -nosum -1Dformat -inset /fenix/users/laros/UKB_resting_state/data_new_appled/stats/SR_results_${sex}_n${network}+tlrc.HEAD \
-idat ${stat} -ithr ${stat} -NN 1 -clust_nvox 150 -1sided RIGHT_TAIL p=0.02 -pref_map big_blobs_all/${sex}_n${network}_stat_${stat}_02_mask.nii
fi

if [ $sex == female ] ; then
#Small blobs
3dClusterize -nosum -1Dformat -inset /fenix/users/laros/UKB_resting_state/data_new_appled/stats/SR_results_${sex}_n${network}+tlrc.HEAD \
-idat ${stat} -ithr ${stat} -NN 1 -clust_nvox 34 -1sided RIGHT_TAIL p=0.002 -pref_map stringent_cluster_masks/${sex}_n${network}_stat_${stat}_002_mask.nii

#Big blobs
3dClusterize -nosum -1Dformat -inset /fenix/users/laros/UKB_resting_state/data_new_appled/stats/SR_results_${sex}_n${network}+tlrc.HEAD \
-idat ${stat} -ithr ${stat} -NN 1 -clust_nvox 149 -1sided RIGHT_TAIL p=0.02 -pref_map big_blobs_all/${sex}_n${network}_stat_${stat}_02_mask.nii
fi




done

done

done

