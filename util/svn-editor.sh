#!/bin/bash
# $1 is the name of the file in which 

TEMPLATE=svnci.tmp

# backup original text
tail -n+2 $2 > $TEMPLATE

# Build message template
echo > $2
echo >> $2
cat $1 >> $2
cat $TEMPLATE >> $2

# clean up
rm $TEMPLATE

vim $2
