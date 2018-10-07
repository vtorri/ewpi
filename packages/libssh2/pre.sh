#! /bin/sh

# $1 : name
# $2 : taropt
# $3 : tarname
# $4 : taropt2

cd packages/$1
tar $2 $3 > pre.log 2>&1
dir_name=`tar $4 $3 | head -1 | cut -f1 -d"/"`
cd $dir_name
