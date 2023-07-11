function [overlaptable,overlap_volume_total,ch1_volume,ch1_volume_total] = calculateSSDOverlapPoints(ch1SSDlocs,ch2SSDlocs)
ch670sz = size(ch1SSDlocs,1);
 ch580sz = size(ch2SSDlocs,1);
 %% ---- loop over each SSD for Ch1 and calculate overlap with Ch2 (Ch1 is the alphashape)
   overlaptable = table();
   ch1_volume = zeros(ch670sz,1);

 results_table = zeros(ch580sz,ch670sz);
 for aa = 1: ch670sz
    ch1_shp = alphaShape(ch1SSDlocs{aa}(:,1),ch1SSDlocs{aa}(:,2),ch1SSDlocs{aa}(:,3));
    ch1_volume(aa) = volume(ch1_shp);
    for bb = 1: ch580sz
        ch2_pts = ch2SSDlocs{bb};
         inbool = inShape(ch1_shp,ch2_pts(:,1),ch2_pts(:,2),ch2_pts(:,3));
         if ~(sum(inbool) >3)
             continue;
         else
         inpoints = [ch2_pts(inbool,1),ch2_pts(inbool,2),ch2_pts(inbool,3)]; %get inside points
         overlap_shp = alphaShape(inpoints(:,1),inpoints(:,2),inpoints(:,3));
         results_table(bb,aa) = volume(overlap_shp);
         end
    end
 end
 overlap_volume_total = sum(results_table(:));
 % put into table format 
 for ii = 1:ch670sz
     newtab = table(results_table(:,ii));
     newtab.Properties.VariableNames = {['Ch1SSD_' num2str(ii)]};
     overlaptable = [overlaptable,newtab]; 
 end
 rownames= cell(ch580sz,1);
 for ch2 = 1:ch580sz
    rownames{ch2} = ['Ch2SSD_' num2str(ch2)]; 
 end   
overlaptable.Properties.RowNames = rownames;
ch1_volume_total = sum(ch1_volume(:));
end