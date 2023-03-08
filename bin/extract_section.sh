#!/bin/sh

# usage extract_section.sh <out_file> <comment_tag> <input_file>

ofile=$1
tag=$2
ifile=$3

# cat $file | sed -n "/$tag/,/$tag/ { /$tag/d ; /$tag/d ; p}"
cat $ifile | sed -n "/$tag/,/$tag/ {
    /$tag/d
    /$tag/d
    p
}" >$ofile
