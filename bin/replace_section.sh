#!/bin/sh

# usage replace_section.sh <input_file> <comment_tag> <tag_file>

file=$1
tag=$2
tag_file=$3

cat $file | sed "/{{$tag}}/ {
	r $tag_file
	d
}" > $file.tmp
cp $file.tmp $file
rm $file.tmp

