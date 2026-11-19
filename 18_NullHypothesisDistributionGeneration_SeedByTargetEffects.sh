#!/bin/tcsh

# computes overlap with each of seven IFC networks of a single
# blob volume randomly generated in accordance with group-
# specific smoothness parameters and cluster thresholds

# the voxel-level threshold is set based on the script find_crit.sh which
# identified the threshold that generated, on average, the same number of
# significant clusters that were identified across a single seed-based 
# connectivity analysis using actual data

# make network masks
if (! -f mask_1.nii ) then
	3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,1)' -prefix mask_1.nii
	3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,2)' -prefix mask_2.nii
	3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,3)' -prefix mask_3.nii
	3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,4)' -prefix mask_4.nii
	3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,5)' -prefix mask_5.nii
	3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,6)' -prefix mask_6.nii
	3dcalc -a 7networks_liberal_resam.nii.gz -expr 'equals(a,7)' -prefix mask_7.nii
endif

set m = 1
set clust_thresh = 149
set num_seed_nets = 1
set num_overlap_nets = 7
set iterations = 1000


foreach crit_val (1.836 1.752 1.700 1.661 1.629)
	set i = 1
	set k = 0

	while (${i} <= ${iterations})

		# generate fake blob volumes
		set j = 1
		while (${j} <= ${num_seed_nets})
			set volnum=`printf "%06d\n" ${k}`
			3dClusterize -quiet -nosum -no_1Dformat -outvol_if_no_clust -pref_map foo_${k}.nii -inset ./fem_vols/null_vols_${volnum}.nii -idat 0 -ithr 0 -NN 1 -clust_nvox ${clust_thresh} -bisided -${crit_val} ${crit_val}
			@ k = ${k} + 1
			@ j = ${j} + 1
		end

		# combine the volumes
		3dMean -sum -prefix sum_vol.nii foo_*.nii
		rm foo_*.nii

		# compute overlap of fake results with each IFC mask
		set l = 1
		while (${l} <= ${num_overlap_nets})
			set over${l}=`3dOverlap mask_${l}.nii sum_vol.nii`
			@ l = ${l} + 1
		end
		rm sum_vol.nii

		# now, write to file
		echo -n "${over1} ${over2} ${over3} ${over4} ${over5} ${over6} ${over7}" >> fem_${m}_blob_over_1_seed_null_overlap.txt
        	echo >> fem_${m}_blob_over_1_seed_null_overlap.txt
        	@ i = ${i} + 1
	end
	@ m = ${m} + 1
end

rm mask_?.nii
