#! /bin/bash

# $1 : prefix
# $2 : version

cp -f ewpi.nsi.in ewpi.nsi
path=`echo $1 | sed 's,/,\\\\\\\\,g'`
echo $path

sed -i -e "s|@prefix@|${path}|g;s|@version@|$2|g" ewpi.nsi
makensis ewpi.nsi > ewpi_nsis.log 2>&1
