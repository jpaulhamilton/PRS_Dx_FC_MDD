#!/bin/bash

#This command runs the 2x3 ANOVA for each gender and for each seed, with each subject's Z-score map as input

for gender in male female ; do
for node in {1..7} ; do

3dMVM -prefix SR_results_${gender}_n$node -jobs 15 -dataTable @SR_table_${gender}_n$node.txt -mask 7networks_liberal_resam.nii.gz -bsVars "PRS*MDDstatus"
sleep 5


done
done