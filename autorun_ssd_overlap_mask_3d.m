function autorun_ssd_overlap_mask_3d(filepath, nanocluster_T, cutoff)%% extract coord data by channel
    C = readmatrix(filepath);
    ss = strsplit(filepath,'\');
    cluster_name = [ss{end-1} '_' ss{end}];
    cluster_name = cluster_name(1:end-4);
    [savepath,NAME,EXT] = fileparts(filepath);
    
    % ch1 is 580 ch2 is 670
    ind1 = C(:,1) == 580;
    ind2 = C(:,1) == 670;
    A_full = C(ind1,:);
    A = A_full(:,[2:4]);
    B_full = C(ind2,:);
    B = B_full(:,[2:4]);
    
    
%%  SSD detection
    ch1_cluster_coor = nanocluster_coor_3d_xSD(A, nanocluster_T, cutoff, 0);
    ch2_cluster_coor = nanocluster_coor_3d_xSD(B, nanocluster_T, cutoff, 0);
    max580_Clusters = max(ch1_cluster_coor(:, 1));
    max670_Clusters = max(ch2_cluster_coor(:, 1));
%% generate alphaShapes of each SSD
    store580shps = cell(max580_Clusters,1);
    store670shps = cell(max670_Clusters,1);
    if max580_Clusters && max670_Clusters > 0
        for i_A580_SSD = 1:max580_Clusters
            X = ch1_cluster_coor(ch1_cluster_coor(:, 1) == i_A580_SSD, 3:5);
                    if size(X, 1) > 3
                        store580shps{i_A580_SSD} = X;
                    end
        end   
        for i_B670_SSD = 1:max670_Clusters
            X = ch2_cluster_coor(ch2_cluster_coor(:, 1) == i_B670_SSD, 3:5);
                    if size(X, 1) > 4
                        store670shps{i_B670_SSD} = X;
                    end
        end    
    else
        disp(['File ' filepath ' had none']);
        return;
    end 
%% Calculate overlap and save data   
if max580_Clusters && max670_Clusters > 0
    [overlap_voxels,total_ch1_voxels,total_ch2_voxels,percent_ch1_overlap,percent_ch2_overlap] = calculateSSDOverlapsMask(store580shps,ch1_cluster_coor,store670shps,ch2_cluster_coor);
    overlap_summaryT = table(overlap_voxels,total_ch1_voxels,total_ch2_voxels,percent_ch1_overlap,percent_ch2_overlap);

    writetable(overlap_summaryT,fullfile(savepath,[cluster_name 'MaskOverlapSummary.xlsx']),'WriteRowNames',true);%write overlap table


    save(fullfile(savepath,[cluster_name 'MaskResults']),'overlap_summaryT');
end
end



