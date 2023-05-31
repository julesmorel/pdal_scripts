#Folder PDAL script
scriptsroot=$(dirname $0)
PDAL_FOLDER=$scriptsroot"/steps"

pdal pipeline $PDAL_FOLDER/slice.json