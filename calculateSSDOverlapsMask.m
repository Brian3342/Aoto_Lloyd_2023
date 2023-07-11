function [overlap_voxels,total_ch1_voxels,total_ch2_voxels,percent_ch1_overlap,percent_ch2_overlap] = calculateSSDOverlapsMask(ch1SSDlocs,ch1_cluster_coor,ch2SSDlocs,ch2_cluster_coor)
ch1_sz = size(ch1SSDlocs,1);
ch2_sz = size(ch2SSDlocs,1);
 %% ---- loop over each SSD for Ch1 and calculate overlap with Ch2 (Ch1 is the alphashape)
%    overlaptable = table();
%    ch1_volume = zeros(ch1_sz,1);
%    store_ch1_Index = zeros(ch1_sz,1);
%    camera pixel size is 60nm

camera_pixel_size = 60; %in nm
voxel_pixel_size = 10; %in nm
voxel_mesh = voxel_pixel_size / camera_pixel_size;
   
% determine mix and max values for generating mesh 
   ind_ch1_SSD = ch1_cluster_coor(:,1) ~=(0);
   ch1_cluster_coor_only = ch1_cluster_coor(ind_ch1_SSD,[3:5]);
   ind_ch2_SSD = ch2_cluster_coor(:,1) ~=(0);
   ch2_cluster_coor_only = ch2_cluster_coor(ind_ch2_SSD,[3:5]);
   min_value1 = min(ch1_cluster_coor_only);
   min_value2 = min(ch2_cluster_coor_only);
   min_value12 = min(min_value1,min_value2);
   max_value1 = max(ch1_cluster_coor_only);
   max_value2 = max(ch2_cluster_coor_only);
   max_value12 = max(max_value1,max_value2);
   x = min_value12(:,1):voxel_mesh:max_value12(:,1);
   y = min_value12(:,2):voxel_mesh:max_value12(:,2);
   z = min_value12(:,3):voxel_mesh:max_value12(:,3);
   [Xm,Ym,Zm] = meshgrid(x,y,z);
   
%generate storage table for index of each SSD   
   mesh_size = size(Xm,1) * size(Xm,2) * size(Xm,3);
   store_ch1_Index = zeros(mesh_size,ch1_sz);
   store_ch2_Index = zeros(mesh_size,ch2_sz);
   

%loop SSDs and generate mask of dt 
 for aa = 1: ch1_sz
    ch1_shp = delaunayTriangulation(ch1SSDlocs{aa}(:,1),ch1SSDlocs{aa}(:,2),ch1SSDlocs{aa}(:,3));
 
    
    simplexIndex_ch1 = pointLocation(ch1_shp,Xm(:),Ym(:),Zm(:));
    simplexIndex_ch1(isnan(simplexIndex_ch1)) = 0;
    store_ch1_Index(:,aa) = simplexIndex_ch1;
 end
 for bb = 1: ch2_sz
    ch2_shp = delaunayTriangulation(ch2SSDlocs{bb}(:,1),ch2SSDlocs{bb}(:,2),ch2SSDlocs{bb}(:,3));
 
    
    simplexIndex_ch2 = pointLocation(ch2_shp,Xm(:),Ym(:),Zm(:));
    simplexIndex_ch2(isnan(simplexIndex_ch2)) = 0;
    store_ch2_Index(:,bb) = simplexIndex_ch2;
 end
 
complete_ch1_Index = sum(store_ch1_Index,2);
mask_ch1 = complete_ch1_Index ~= 0;
mask_ch1 = reshape(mask_ch1,size(Xm));
complete_ch2_Index = sum(store_ch2_Index,2);
mask_ch2 = complete_ch2_Index ~= 0;  
mask_ch2 = reshape(mask_ch2,size(Xm));

overlap_mask = mask_ch1 .* mask_ch2;

overlap_voxels = sum(overlap_mask, 'all');
total_ch1_voxels = sum(mask_ch1,'all');
total_ch2_voxels = sum(mask_ch2,'all');
percent_ch1_overlap = overlap_voxels / total_ch1_voxels *100;
percent_ch2_overlap = overlap_voxels / total_ch2_voxels *100;

%     mask_ch1 = reshape(mask,size(Xm));
end