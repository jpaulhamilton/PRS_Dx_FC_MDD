#!/bin/tcsh

# for determining if a particular seed region in a functional connectivity
# analysis generates proportionatewly more significant effects than other
# seeds; it generates and provides a suprathershold voxel count of null-effect 
# volumes that, on average, have the same number of significant blobs as 
# obtained in an empirical study

# the voxel-level threshold is set based on the script find_crit.sh which
# identified the threshold that generated, on average, the same number of
# significant clusters that were identified across seven seed-based connectivity
# analyses using actual data

set m = 1
set clust_thresh = 150
set iterations = 1000

foreach crit_val (1.831 1.748 1.698 1.660 1.631 1.604)

	set i = 1
	set k = 0

	while (${i} <= ${iterations})
		# generate fake blob volumes and count the number of voxels in each one
		set volnum=`printf "%06d\n" ${k}`
		3dClusterize -quiet -nosum -no_1Dformat -outvol_if_no_clust -pref_map foo_${k}.nii -inset ./man_vols/null_vols_${volnum}.nii -idat 0 -ithr 0 -NN 1 -clust_nvox ${clust_thresh} -bisided -${crit_val} ${crit_val}
		set count=`3dBrickStat -count -non-zero foo_${k}.nii`
		echo -n "${count}" >> man_${m}_blob_over_1_seed_null_count.txt 
		echo >> man_${m}_blob_over_1_seed_null_count.txt
		rm foo_*.nii
		@ k = ${k} + 1
        	@ i = ${i} + 1
	end
	@ m = ${m} + 1
end
