#!/bin/tcsh

# cycles through a range of voxel thresholds in noise blob volumes
# rendered from 3dClust to determine correct voxel threshold level
# for generating the number of blobs corresponding to the effects
# observed in our factorial analysis of polygenic risk and disease
# status

# had to make a kludge for setting the range and critical value
# because the while command in csh does not support decimals

# did this separately for smoothness and cluster thresholds for
# male and female samples

set lower_range = 1600
set upper_range = 2100
set iterations = 1000
set i = 1

while (${i} <= ${iterations})
	echo ${i}
	set j = ${lower_range}
	set volnum=`printf "%06d\n" ${i}`
	while (${j} < ${upper_range})
		set crit_val = `echo "scale=4; $j/1000" | bc -l`
		3dClusterize -quiet -nosum -no_1Dformat -inset /Users/paulhamilton/Desktop/PRS_Dx_FC/appeled_results/for_paul/null_hyp/fem_vols/null_vols_${volnum}.nii -idat 0 -ithr 0 -NN 1 -clust_nvox 149 -bisided -${crit_val} ${crit_val} > foo.txt
		set k = `grep -coe '\([0-9]\)' foo.txt`
		rm foo.txt
		echo -n "${k} " >> fem_blobs.txt
		@ j = ${j} + 1
	end
	echo >> fem_blobs.txt
	@ i = ${i} + 1
end
