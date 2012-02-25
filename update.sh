#!/bin/bash
# Regenrate files and copy them to site
#
# Require:
# - ImageMagic: convert
# - R
# Delete files in:
# - csv/*
# - graphs/*/*.png
# - site/csv/*.csv
# - site/graphs/*.png



echo "# Remove all files in target directories"
rm -f graphs/*/*.png
rm -f site/csv/*.csv
rm -f site/graphs/*.png

echo "# Check csv files exist"
if [ -f ./csv/d.csv -a -f ./csv/dh.csv -a -f ./csv/dw.csv ];
then
echo "- found csv files - use it"
else
    echo "- missing csv files"
    rm -f site/csv/*.csv

    echo "# Check witl.db exists"
    if [ ! -f ./witl.db ];
    then
        echo "- need witl.db"
        exit 1
    fi

    echo "# Generate csv files: will take a long time"
    ./r/sqlite-to-csv.R
fi

echo "# Generate graphs"
./r/generate-graphs.R

echo "# Copy files into site"
cp ./csv/*.csv site/csv/
cp ./graphs/*/*.png site/graphs/

echo "# Generate thumbnails using ImageMagick"
cd site/graphs
for f in *.png; do
  name=`basename $f .png`
  echo "- $name"
  convert $name.png -resize 480\> $name.small.png
done
