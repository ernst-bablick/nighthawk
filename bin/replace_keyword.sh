#!/bin/sh

# usage replace_keyword.sh <input_file> <comment_tag> <text>

file=$1
tag=$2
text=$3

cat $file | sed "s/{{$tag}}/$text/g" > $file.tmp
cp $file.tmp $file
rm $file.tmp

