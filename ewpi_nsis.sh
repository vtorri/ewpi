#! /bin/bash

# $1 : prefix
# $2 : version
# $3 : host
# $4 : winver

path=`echo $1 | sed 's,/,\\\\\\\\,g'`
echo $path

cp -f ewpi.nsi.in ewpi.nsi

sed -i -e "s|@prefix@|${path}|g;s|@version@|$2|g;s|@arch@|$3|g;s|@winver@|$4|g" ewpi.nsi
makensis ewpi.nsi > ewpi_nsis.log 2>&1


#cp -f efl.nsi.in efl.nsi

#prefix=$(dirname "${path}")
#prefix="$prefix/efl_64"

#sed -i -e "s|@prefix@|${path}|g;s|@version@|$2|g;s|@arch@|$3|g;s|@winver@|$4|g" efl.nsi
#makensis efl.nsi > efl_nsis.log 2>&1
