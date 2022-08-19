# Digital terrain reconstruction from LiDAR scans using PDAL 

## Requirements
* Linux (tested on Ubuntu 20.04.4 LTS and 21.10)
* PDAL 2.4.2 
* plyfile (NumPy-based text/binary PLY file reader/writer for Python)

-----------------
## Install
```bash
conda install -c conda-forge pdal plyfile
```

-----------------
## PDAL scripts
The script crop the input las, segment the ground points and then reconstruct the terrain surface as an .obj surface:
```bash
./terrain_reconstruction_csf.sh INPUT_FILE_1 ... INPUT_FILE_N OUTPUT_FILE
```
where INPUT_FILE_1 ... INPUT_FILE_N are the .las/.laz files containing the scans of the plot and OUTPUT_FILE is the path to the .obj output surface 
**Note**: the extent of the ground reconstruction must be adjusted in the header of segment_terrain.sh

The pipeline is made of the following steps:
1. Every input las files are cropped on an user defined extent (they are also subsampled to the desired DTM resolution in order to speed up the processing)
2. The resulting cropped point clouds are merged 
3. The Cloth Simulation Filter (CSF) classifies the ground points.
4. The DTM raster is exported
5. A surface model (PLY format) is reconstructed from the ground points
6. The PLY surface model is converted into an OBJ

Additionnaly, we propose a second script, designed to reconstruct a terrain surface from Ground points already segmented. 
```bash
./terrain_reconstruction_from_ground_points.sh INPUT_FILE_ASCII INPUT_FILE_OFFSET OUTPUT_FILE
```
INPUT_FILE_ASCII is a point cloud stored in ASCII format where the first 3 columns are XYZ coordiantes separated by space characters.
INPUT_FILE_OFFSET is an ASCII file storing the X and Y values of the offset applied to the point cloud
OUTPUT_FILE is the path to the .obj output surface.

The pipeline is made of the following steps:
1. Filter the first 3 columns of the ASCII file
2. Transform the ASCII file into a LAS file and apply the transformation related to the offset
3. A surface model (PLY format) is reconstructed from the ground points
4. The PLY surface model is converted into an OBJ

-----------------
## Fixing .las files
If PDAL output the following error while reading the .las files
```bash
Global encoding WKT flag not set for point format 6 - 10
```
It means that the LAS file is missing a Spatial Reference System.
To fix it, run:
```bash
python fixLasFile.py INPUT_FILE
```



