#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt

cd packages/$1
dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cp Makefile $dir_name/win32
cd $dir_name
make -f win32/Makefile clean > /dev/null
make -j -f win32/Makefile install prefix=$3 PREFIX=$4 > ../make.log 2>&1
sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
