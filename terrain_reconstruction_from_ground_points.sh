#Folder PDAL script
PDAL_FOLDER="steps"

if [ "$#" -eq  3 ]; then
    inputAsciiFile=$1
    offsetFile=$2
    outputOBJ=$3

    dir=$(dirname "$inputAsciiFile")
    root=$(basename "${inputAsciiFile%.*}")
    lasFile=$dir/${root}.laz

    echo "Filter the columns of the input ASCII file"
    inputFiltered=$dir/${root}_filtered.xyz
    cat $inputAsciiFile | awk '{ print $1 " " $2 " " $3}' > $inputFiltered

    echo "Converting the minimum points ascii file in the las format"
    pdal pipeline $PDAL_FOLDER/txt2las.json --writers.las.filename=$lasFile --readers.text.filename=$inputFiltered --readers.text.header="X Y Z" --readers.text.separator=" "
    
    echo "Reading the offset"
    line=$(head -n 1 $offsetFile)
    offset_x=$(echo $line | cut -f1 -d" ")
    offset_y=$(echo $line | cut -f2 -d" ")
    echo "   x: "$offset_x" y: "$offset_y

    echo "Translating the points by the given offset"
    translatedLasFile=$dir/${root}_translated.laz
    pdal pipeline $PDAL_FOLDER/translate.json --writers.las.filename=$translatedLasFile --readers.las.filename=$lasFile --filters.transformation.matrix="1  0  0  $offset_x  0  1  0  $offset_y  0  0  1  0  0  0  0  1"

    echo "Reconstructing the surface from the translated ground points"
    dir_out=$(dirname "$outputOBJ")
    root_out=$(basename "${outputOBJ%.*}")
    ply_out=$dir_out/${root_out}.ply
    pdal pipeline $PDAL_FOLDER/poisson.json --writers.ply.filename=$ply_out --writers.ply.faces="true" --readers.las.filename=$translatedLasFile

    python ply2obj.py $ply_out

    echo "Cleaning the temporary files"
    rm $inputFiltered
    rm $lasFile
    rm $translatedLasFile
    rm $ply_out
else
  echo "Please provide a ascii file containing the ground points, the corresponding offset and an output .obj file"
fi