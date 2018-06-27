#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : taropt2

cd packages/$1
dir_name=`tar $3 $2 | head -1 | cut -f1 -d"/"`
rm -rf $dir_name
rm -f $2 *.log *~
