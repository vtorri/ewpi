#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

cd packages/$1
dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
make clean > ../make.log 2>&1
make -j $jobopt install prefix=$3 CC=$4-gcc AR=$4-ar RANLIB=$4-ranlib DLLTOOL=$4-dlltool >> ../make.log 2>&1
sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
