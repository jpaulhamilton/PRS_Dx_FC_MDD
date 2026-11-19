#!/bin/bash

# cycles through seed-based connectivity results to calculate target-wise
# voxel counts in each of seven IFC networks for effects of PRS, Dx, and
# their interaction
# Output:  voxelcount/sex_${gender}_stat_${effect}_node${seed}_clustnum_$i.txt
# Example:output file sex_female_stat_1_node_1_clusternum_1.txt
# Content:
#Target1,Target2,Target3,Target4,Target5,Target6,Target7
#0,0,40,12,0,159,0
# Meaning: results from females, using seed 1, looking at clusters from main effect 1 (PRS), resulting significant cluster #1
# Cluster #1 has 40 voxels in network 3, 12 voxels in network 4 and 159 voxels in network 6

gender=male
blob_type=big_blobs_keep

# make network masks
if [ ! -f voxelcount/networkmasks/mask_1.nii ] ; then
3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,1)' -prefix voxelcount/networkmasks/mask_1.nii
3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,2)' -prefix voxelcount/networkmasks/mask_2.nii
3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,3)' -prefix voxelcount/networkmasks/mask_3.nii
3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,4)' -prefix voxelcount/networkmasks/mask_4.nii
3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,5)' -prefix voxelcount/networkmasks/mask_5.nii
3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,6)' -prefix voxelcount/networkmasks/mask_6.nii
3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,7)' -prefix voxelcount/networkmasks/mask_7.nii
fi

for effect in {3..3} ; do


	echo "effect break"
	for seed in {1..7} ; do


		echo "net break"
		net1count=0
		net2count=0
		net3count=0
		net4count=0
		net5count=0
		net6count=0
		net7count=0
		if [ -f $blob_type/${gender}_n${seed}_stat_${effect}_con_lib_intersect.nii ] ; then
			# get blob count for 3dclusterized volumes
			blobcount=`3dBrickStat -max $blob_type/${gender}_n${seed}_stat_${effect}_con_lib_intersect.nii`
			# cycle through blobs and get and sum network voxel count
			i=0
			while [ ${i} -lt ${blobcount} ] ; do
				i=$(expr $i + 1)

				if [ ! -f voxelcount/sex_${gender}_stat_${effect}_node${seed}_clustnum_$i.txt ] ; then
				echo "Target1,Target2,Target3,Target4,Target5,Target6,Target7" >> voxelcount/sex_${gender}_stat_${effect}_node${seed}_clustnum_$i.txt
				fi


				3dcalc -a $blob_type/${gender}_n${seed}_stat_${effect}_con_lib_intersect.nii -expr "equals(a,${i})" -prefix temp_${i}.nii

				intercount1=`3dOverlap voxelcount/networkmasks/mask_1.nii temp_${i}.nii`
				intercount2=`3dOverlap voxelcount/networkmasks/mask_2.nii temp_${i}.nii`
				intercount3=`3dOverlap voxelcount/networkmasks/mask_3.nii temp_${i}.nii`
				intercount4=`3dOverlap voxelcount/networkmasks/mask_4.nii temp_${i}.nii`
				intercount5=`3dOverlap voxelcount/networkmasks/mask_5.nii temp_${i}.nii`
				intercount6=`3dOverlap voxelcount/networkmasks/mask_6.nii temp_${i}.nii`
				intercount7=`3dOverlap voxelcount/networkmasks/mask_7.nii temp_${i}.nii`
				rm temp_${i}.nii
				echo "$intercount1,$intercount2,$intercount3,$intercount4,$intercount5,$intercount6,$intercount7" >> voxelcount/sex_${gender}_stat_${effect}_node${seed}_clustnum_$i.txt
				#net1count=$(expr ${net1count} + ${intercount1})
				#net2count=$(expr ${net2count} + ${intercount2})
				#net3count=$(expr ${net3count} + ${intercount3})
				#net4count=$(expr ${net4count} + ${intercount4})
				#net5count=$(expr ${net5count} + ${intercount5})
				#net6count=$(expr ${net6count} + ${intercount6})
				#net7count=$(expr ${net7count} + ${intercount7})
			done
		fi
		#echo "$seed,$net1count,$net2count,$net3count,$net4count,$net5count,$net6count,$net7count" >> voxelcount/Stat_${effect}_${gender}.txt
		echo "Stat: $effect, node $seed"
		echo ${net1count}
		echo ${net2count}
		echo ${net3count}
		echo ${net4count}
		echo ${net5count}
		echo ${net6count}
		echo ${net7count}
	done
done