#! /bin/bash

# $1 : prefix
# $2 : host

find $1/bin -name "*.dll" -exec $2-strip {} \; > strip.log 2>&1
find $1/lib -name "*.dll" -exec $2-strip {} \; >> strip.log 2>&1
