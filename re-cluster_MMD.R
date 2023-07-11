library(tidyverse)
library(rgl)
library(RANN)
library(dbscan)

lm_df = read_csv(f_name)
lm_df = lm_df %>% select(wave_length, x_pixels, y_pixels, z_pixels)

with(lm_df ,
     plot3d(x = `x_pixels`, y = `y_pixels`, z = `z_pixels`,col = ifelse(wave_length == 580, 'red', 'blue'), type = 'p'))

# Limit ROI to remove additional synapses if necessary 

# lm_df = lm_df %>% filter(z_pixels > 39)
# lm_df = lm_df %>% filter(z_pixels < 29)
# lm_df = lm_df %>% filter(x_pixels > 697)
# lm_df = lm_df %>% filter(x_pixels < 305)
# lm_df = lm_df %>% filter(y_pixels > 735)
# lm_df = lm_df %>% filter(y_pixels < 646)

# dbscan variables
mmd_factor = 4
min_points = 10


d_lm_df = as.data.frame(nn2(lm_df %>% select(x_pixels, y_pixels, z_pixels)))
mmd_df = mean(d_lm_df$nn.dists.2)
eps = mmd_df * mmd_factor
res = dbscan(as.matrix(lm_df %>% select(x_pixels, y_pixels, z_pixels)), eps, min_points)
recluster_df = lm_df 
recluster_df['cluster'] = res$cluster
recluster_df = recluster_df %>% filter(cluster == !0)

with(recluster_df ,
     plot3d(x = `x_pixels`, y = `y_pixels`, z = `z_pixels`, col = ifelse(wave_length == 580, 'red', 'blue'), type = 'p'))

output_file = paste('re', f_name, sep = '')
recluster_df %>% write_csv(output_file)

