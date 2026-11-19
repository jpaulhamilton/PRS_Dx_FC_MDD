#!/bin/bash

#These commands calculate p-value/cluster-size threshold combinaitons needed to reach true Alpha of 0.05 (for FWE corrected results, use these threholds)

#Females
3dClustSim -acf 0.913178313287512 2.96434246849942 15.0554631214204 -mask 7networks_liberal_resam.nii.gz

#Males
3dClustSim -acf 0.89587061111111 2.93664296690307 13.4219367730496 -mask 7networks_liberal_resam.nii.gz