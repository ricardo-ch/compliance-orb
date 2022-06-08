#!/bin/bash

isopod_files=$(find . -regextype sed -regex ".*isopod.*\.yml")

for file in files; do
   image=$(isopod image -f $file)
   docker pull $image
done