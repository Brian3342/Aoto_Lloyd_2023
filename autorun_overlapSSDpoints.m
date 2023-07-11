function autorun_overlapSSDpoints(filepath, nanocluster_T, cutoff)%% extract coord data by channel
    C = readmatrix(filepath);
    ss = strsplit(filepath,'\');
    cluster_name = [ss{end-1} '_' ss{end}];
    cluster_name = cluster_name(1:end-4);
    [savepath,NAME,EXT] = fileparts(filepath);
    
    ind1 = C(:,1) == 580;
    ind2 = C(:,1) == 670;
    A_full = C(ind1,:);
    A = A_full(:,[2:4]);
    B_full = C(ind2,:);
    B = B_full(:,[2:4]);
    
    
%%  SSD detection
    A_580_cluster_coor = nanocluster_coor_3d_xSD(A, nanocluster_T, cutoff, 0);
    B_670_cluster_coor = nanocluster_coor_3d_xSD(B, nanocluster_T, cutoff, 0);
    max580_Clusters = max(A_580_cluster_coor(:, 1));
    max670_Clusters = max(B_670_cluster_coor(:, 1));
%% generate alphaShapes of each SSD
    store580shps = cell(max580_Clusters,1);
    store670shps = cell(max670_Clusters,1);
    if max580_Clusters && max670_Clusters > 0
        for i_A580_SSD = 1:max580_Clusters
            X = A_580_cluster_coor(A_580_cluster_coor(:, 1) == i_A580_SSD, 3:5);
                    if size(X, 1) > 3
                        store580shps{i_A580_SSD} = X;
                    end
        end   
        for i_B670_SSD = 1:max670_Clusters
            X = B_670_cluster_coor(B_670_cluster_coor(:, 1) == i_B670_SSD, 3:5);
                    if size(X, 1) > 4
                        store670shps{i_B670_SSD} = X;
                    end
        end    
    else
        disp(['File ' filepath ' had none']);
        return;
    end 
%%    

[overlaptable_12,overlap_volume_total_12,ch1vols,ch1_volume_total] = calculateSSDOverlapPoints(store670shps,store580shps);
[overlaptable_21,overlap_volume_total_21,ch2vols,ch2_volume_total] = calculateSSDOverlapPoints(store580shps,store670shps);
overlap_summaryT = table(overlap_volume_total_12, ch1_volume_total, overlap_volume_total_21, ch2_volume_total);

writetable(overlaptable_12,fullfile(savepath,[cluster_name 'OverlapTable_12.xlsx']),'WriteRowNames',true); %write overlap table
writetable(overlaptable_21,fullfile(savepath,[cluster_name 'OverlapTable_21.xlsx']),'WriteRowNames',true); %write overlap table
writetable(overlap_summaryT,fullfile(savepath,[cluster_name 'testOverlapSummary.xlsx']),'WriteRowNames',true);%write overlap table
writematrix(ch1vols,fullfile(savepath,[cluster_name 'Ch1Volumes.xlsx']));
writematrix(ch2vols,fullfile(savepath,[cluster_name 'Ch2Volumes.xlsx']));

save(fullfile(savepath,[cluster_name 'Results']),'overlaptable_12','overlaptable_21','overlap_summaryT','ch1vols','ch2vols');

end

% loop over each SSD for Ch1 and calculate overlap with Ch2 (Ch1 is the alphashape)


