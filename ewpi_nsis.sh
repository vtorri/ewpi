#! /bin/bash

# $1 : prefix
# $2 : version
# $3 : arch
# $4 : winver

cp -f ewpi.nsi.in ewpi.nsi
path=`echo $1 | sed 's,/,\\\\\\\\,g'`
echo $path

sed -i -e "s|@prefix@|${path}|g;s|@version@|$2|g;s|@arch@|$3|g;s|@winver@|$4|g" ewpi.nsi
makensis ewpi.nsi > ewpi_nsis.log 2>&1
