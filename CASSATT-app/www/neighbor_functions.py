import numpy as np
import pandas as pd
from scipy.spatial import Voronoi

n_data = pd.read_csv("www/neighborhood_data.csv")
coords = np.asarray(n_data[["Global_x","Global_y"]])
vor = Voronoi(coords)

def find_voronoi(input_cell):
  input_cell_array = np.asarray([input_cell.get("Global_x"), input_cell.get("Global_y")], dtype = float)
  
  input_cell_indx = np.where(vor.points == input_cell_array)[0][0]
  input_region = vor.regions[vor.point_region[input_cell_indx]] # list of vertices indexes

  # find regions that share a vertices with input_region
  neighbor_region_indx = []
  for vert in input_region:
    for region_indx, region in enumerate(vor.regions):
      if (vert in region) and (region_indx not in neighbor_region_indx):
        neighbor_region_indx.append(region_indx)

  # find cells at the center of neighbor regions
  neighbor_points = []
  for cell_indx, region_indx in enumerate(vor.point_region):
    if region_indx in neighbor_region_indx:
      neighbor_points.append(vor.points[cell_indx])

  return(neighbor_points)

