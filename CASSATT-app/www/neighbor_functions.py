import numpy as np
import pandas as pd
from scipy.spatial import Voronoi
from grispy import GriSPy

def run_voronoi(neighbor_coords):
  vor = Voronoi(np.asarray(neighbor_coords))
  return(vor)

def find_voronoi(vor, input_cell):
  print(type(input_cell))
  # print(input_cell["Global_x"])
  
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
  neighbor_points = []
  indxes = []
  for cell_indx, region_indx in enumerate(vor.point_region):
    if region_indx in neighbor_region_indx:
      # neighbor_points.append(vor.points[cell_indx])
      indxes.append(cell_indx)

  # return(neighbor_points)
  
  # find indexes of cells 
  return(indxes)
  

def run_shell(neighbor_coords, distance):
  n_coords_array = np.asarray(neighbor_coords)
  gsp = GriSPy(n_coords_array)
  upper_radii = float(distance)
  lower_radii = 0.01
  shell_dist, shell_ind = gsp.shell_neighbors(
       n_coords_array,
       distance_lower_bound = lower_radii,
       distance_upper_bound = upper_radii
  )
  
  # create dict with each list of neighbors as set
  shell_neighbors = {}
  for index, v in enumerate(shell_ind):
      shell_neighbors[index] = list(v)

  return(shell_neighbors)
      
def find_shell(neighbor_coords, s_neighbors, input_cell):

  # match input cell x and y to coords
  input_x = np.asarray(input_cell.get("X1"))
  input_cell_indx = np.intersect1d(np.asarray(neighbor_coords)[:, 0], input_x, return_indices = True)[1]

  # take indx from coords, use it to find shell dict item
  s_list = list(s_neighbors.values())
  neighbors = s_list[int(input_cell_indx)]

  if len(neighbors) > 0:
    
    # return neighbors as coordinate pairs
    neighbor_points = []
    for cell_indx in neighbors:
      neighbor_points.append(neighbor_coords.iloc[int(cell_indx)])

    return(neighbor_points)
  
def run_knn(neighbor_coords, n_neighbors):
  n_coords_array = np.asarray(neighbor_coords)
  gsp = GriSPy(n_coords_array)
  knn_dist, knn_ind = gsp.nearest_neighbors(
      n_coords_array,
      n = int(n_neighbors)
  )
  knn_neighbors = {}
  count = 0
  for index, v in enumerate(knn_ind):
      knn_neighbors[index] = set(v)
      count += len(v)
      
  return(knn_neighbors)

def find_knn(neighbor_coords, knn_neighbors, input_cell):

  # match input cell x and y to coords
  input_x = np.asarray(input_cell.get("X1"))
  input_cell_indx = np.intersect1d(np.asarray(neighbor_coords)[:, 0], input_x, return_indices = True)[1]

  # take indx from coords, use it to find shell dict item
  knn_list = list(knn_neighbors.values())
  neighbors = knn_list[int(input_cell_indx)]

  if len(neighbors) > 0:
    
    # return neighbors as coordinate pairs
    neighbor_points = []
    for cell_indx in neighbors:
      neighbor_points.append(neighbor_coords.iloc[int(cell_indx)])

    return(neighbor_points)
