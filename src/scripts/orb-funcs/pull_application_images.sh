#!/usr/bin/env bash
set -o nounset

isopod_files=$(find . -regextype sed -regex ".*isopod.*\.yml")

for file in $isopod_files; do
   image=$(isopod image -f $file)
   docker pull "$image"
done