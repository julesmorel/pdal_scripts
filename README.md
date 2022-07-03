### Requirements
* Linux (tested on Ubuntu 20.04.4 LTS and 21.10)
* PDAL 2.4.2 

-----------------
## PDAL scripts
For comparison purposes, we provide 3 PDAL scripts to crop the input las,segment the ground points and then reconstruct the terrain surface.
To merge every scans of the plot, first use: 
```bash
pdal merge INPUT_FILE_1 ... INPUT_FILE_N OUTPUT_FILE
```
Then, use the 3 following scripts to reconstruct the terrain surface
```bash
pdal translate INPUT_LAS   CROPPED_LAS --json pdal_scripts/pipeline_crop.json
pdal translate CROPPED_LAS GROUND_LAS  --json pdal_scripts/pipeline_csf.json
pdal translate GROUND_LAS  SURFACE_PLY --json pdal_scripts/pipeline_poisson.json
```
**Note**: Every files are las/laz, except the surface one which is in the ply format
