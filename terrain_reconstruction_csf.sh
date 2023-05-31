#!/bin/bash

#Resolution of the DTM
RESOLUTION_XYZ=0.1

#Extent
X_MIN=50
X_MAX=130
Y_MIN=-100
Y_MAX=-15

#CSF Parameters
CSF_RESOLUTION=0.25
CSF_RIGIDNESS=10

#Folder PDAL script
scriptsroot=$(dirname $0)
PDAL_FOLDER=$scriptsroot"/steps"

if [ "$#" -ge  2 ]; then
  outputOBJ=${@: -1}
  dir_out=$(dirname "$outputOBJ")
  root_out=$(basename "${outputOBJ%.*}")
  ply_out=$dir_out/${root_out}.ply
  #crop and subsample slightly every input file
  echo "Cropping input files"
  for file in ${@:1:$#-1}
  do
    dir=$(dirname "$file")
    root=$(basename "${file%.*}")
    croppedFile=$dir/${root}cropped.laz
    pdal pipeline $PDAL_FOLDER/crop.json --writers.las.filename=$croppedFile --readers.las.filename=$file --filters.crop.bounds="([$X_MIN,$X_MAX],[$Y_MIN,$Y_MAX])" --filters.sample.radius="$RESOLUTION_XYZ"
    listCroppedFiles+=( $croppedFile )
  done

  echo "Merging input files"
  pointsMerged=$dir/all.laz
  pdal merge ${listCroppedFiles[@]} $pointsMerged
  for fileCropped in ${listCroppedFiles[@]}
  do
    rm $fileCropped
  done

  echo "Estimating ground points"
  groundPoints=$dir/ground.laz
  pdal pipeline $PDAL_FOLDER/csf.json --writers.las.filename=$groundPoints --readers.las.filename=$pointsMerged --filters.csf.resolution=$CSF_RESOLUTION --filters.csf.rigidness=$CSF_RIGIDNESS 
  rm $pointsMerged

  echo "Exporting the DTM as GDAL raster"
  tif_out=$dir_out/${root_out}.tif
  pdal pipeline $PDAL_FOLDER/raster.json --writers.gdal.filename=$tif_out --readers.las.filename=$groundPoints

  echo "Reconstructing the surface from ground points"
  surfacePly=$ply_out
  pdal pipeline $PDAL_FOLDER/poisson.json --writers.ply.filename=$surfacePly --writers.ply.faces="true" --readers.las.filename=$groundPoints
  rm $groundPoints

  python $scriptsroot/ply2obj.py $ply_out
  rm $surfacePly

else
  echo "Please provide at least a file to process and an output .obj file"
fi
