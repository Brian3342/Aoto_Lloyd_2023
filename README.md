# Aoto_Lloyd_2023
Code used for manuscript.
re-cluster_MMD.R can be run on Synapse_1 to recluster the synapse to remove extra-synaptic localizations. 
This file can then be used with the autorun_overlapSSDpoints.m or autorun_ssd_overlap_mask_3d.m to calculate overlap. Please note that you will need to place the calculateSSDOverlapPoints.m and calculateSSDOverlapsMask.m in the path. The scripts from Chen et al. Methods 2020 are required dependencies for this code with the following parameters: pixel size = 60nm, T=2, curoff = 100nm, and stadard deviation threshold of 1.5. 
