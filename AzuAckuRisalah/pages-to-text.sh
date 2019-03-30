#!/bin/bash
# Use this script to covert images in folder ./Pages to text in ./Text
TESSERACT=/usr/local/bin/tesseract

for f in Pages/*
do
    g=${f##Pages/}
    h=${g%%.ppm}
    $TESSERACT --oem 1 --psm 3 -l fas $f Text/${h}_fas
done
