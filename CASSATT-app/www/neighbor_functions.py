import numpy as np
import pandas as pd
from scipy.spatial import Voronoi
from grispy import GriSPy

neighborhood_data = pd.read_csv("www/neighborhood_data.csv")
coords = neighborhood_data[["Global_x", "Global_y"]]
coords_array = np.asarray(coords)
coords_gsp = GriSPy(coords_array)
vor = Voronoi(np.asarray(coords))

pop_colors = {
  "Tumor.A" : "#3d3456",
  "Tumor.B" : "#75647a",
  "CD4T.A" : "#971a00",
  "CD4T.B" : "#702512",
  "CD4T.C" : "#4b220a",
  "CD8T.A" : "#41657c",
  "CD8T.B" : "#223d63",
  "DNT.A" : "#e6c170",
  "DNT.B" : "#c28200",
  "Microglia.A" : "#354953",
  "Microglia.B" : "#1d2b22",
  "Macrophage.A" : "#d06a24",
  "Macrophage.B" : "#9e4200"
}

viridis_colors = {
  "Tumor.A" : "#481F70FF",
  "Tumor.B" : "#8FD744FF",
  "CD4T.A" : "#35B779FF",
  "CD4T.B" : "#C7E02EFF",
  "CD4T.C" : "#5EC863FF",
  "CD8T.A" : "#31688EFF",
  "CD8T.B" : "#287C8EFF",
  "DNT.A" : "#433A83FF",
  "DNT.B" : "#21908CFF",
  "Microglia.A" : "#FDE732FF",
  "Microglia.B" : "#3B528BFF",
  "Macrophage.A" : "#440054FF",
  "Macrophage.B" : "#20A486FF"
}

def find_voronoi(input_cell):
  input_x = np.asarray(input_cell["Global_x"])
  input_cell_indx = np.intersect1d(vor.points[:, 0], input_x, return_indices = True)[1]
  input_region = vor.regions[int(vor.point_region[input_cell_indx])] # list of vertices indexes

  # find regions that share a vertices with input_region
  neighbor_region_indx = []
  for vert in input_region:
    for region_indx, region in enumerate(vor.regions):
      if (vert in region) and (region_indx not in neighbor_region_indx):
        neighbor_region_indx.append(region_indx)

  # find cells at the center of neighbor regions
  neighbor_indexes = []
  for cell_indx, region_indx in enumerate(vor.point_region):
    if region_indx in neighbor_region_indx:
      neighbor_indexes.append(cell_indx)

  neighbor_data = neighborhood_data.iloc[neighbor_indexes]
  return(neighbor_data)
  
def run_shell(distance):
  upper_radii = float(distance)
  lower_radii = 0.01
  shell_dist, shell_ind = coords_gsp.shell_neighbors(
       coords_array,
       distance_lower_bound = lower_radii,
       distance_upper_bound = upper_radii
  )
  
  # create dict with each list of neighbors as set
  shell_neighbors = {}
  for index, v in enumerate(shell_ind):
      shell_neighbors[index] = list(v)

  return(shell_neighbors)
      
def find_shell(s_neighbors, input_cell):

  # match input cell x and y to coords
  input_x = np.asarray(input_cell["Global_x"])
  input_cell_indx = np.intersect1d(np.asarray(coords)[:, 0], input_x, return_indices = True)[1]

  # take indx from coords, use it to find shell dict item
  s_list = list(s_neighbors.values())
  neighbor_indexes = s_list[int(input_cell_indx)]
  neighbor_indexes = [int(x) for x in neighbor_indexes]
  neighbor_data = neighborhood_data.iloc[neighbor_indexes]
  return(neighbor_data)
  
def run_knn(n_neighbors):
  knn_dist, knn_ind = coords_gsp.nearest_neighbors(
      coords_array,
      n = int(n_neighbors)
  )
  knn_neighbors = {}
  count = 0
  for index, v in enumerate(knn_ind):
      knn_neighbors[index] = set(v)
      count += len(v)
      
  return(knn_neighbors)

def find_knn(knn_neighbors, input_cell):

  # match input cell x and y to coords
  input_x = np.asarray(input_cell["Global_x"])
  input_cell_indx = np.intersect1d(np.asarray(coords)[:, 0], input_x, return_indices = True)[1]

  # take indx from coords, use it to find shell dict item
  knn_list = list(knn_neighbors.values())
  neighbor_indexes = knn_list[int(input_cell_indx)]
  neighbor_indexes = [int(x) for x in neighbor_indexes]
  neighbor_data = neighborhood_data.iloc[neighbor_indexes]
  return(neighbor_data)
  
def deca_colors(neighbor_data, colormode): 
  rounded = neighbor_data.iloc[:, 0:14].mean()
  rounded = pd.DataFrame(rounded[1:])
  rounded['dec'] = rounded.apply(lambda x: np.floor(x*10))
  rounded['rem'] = rounded[0].apply(lambda x: (x*10)-int(x*10))
  tot = 10 - int(rounded['dec'].sum())
  rounded.nlargest(tot, ['rem'])['dec'].apply(lambda x : x + 1)
  rounded.update(pd.DataFrame(rounded.nlargest(tot, ['rem'])['dec'].apply(lambda x : x + 1)))
  rounded['dec'] = rounded['dec'].apply(np.int64)
  rounded = rounded.sort_values(by = ['dec'], ascending = False)
  for_dec = rounded[rounded.dec != 0].reset_index()

  if colormode == "custom":
    color_dict = pop_colors
  elif colormode == "viridis":
    color_dict = viridis_colors

  d_dec = {}
  for index, row in for_dec.iterrows():
      d_dec[row['index']] = row['dec']
  d_turtle = {}
  count2 = 0
  for key, val in d_dec.items():
      count = val
      while count > 0:
          d_turtle[count2] = color_dict[key]
          count -= 1
          count2 +=1
      else:
          count = 0
  
  return(d_turtle)
  
  
  
  
  
  
  
