#!/bin/bash
# $1 is the name of the file in which our commit message is
# $2 is the name of the temporary svn commit message file (created by svn)

TMP=`mktemp`

# backup original text
tail -n+2 $2 > $TMP

# Build message template
echo > $2; echo >> $2
cat $1 >> $2
cat $TMP >> $2

# clean up
rm $TMP

vim $2 # TODO: Allow variable editor

# Check commit message
echo -n "[$CSVN] commit-msg... "
if test -f "$CSVNROOT/hooks/commit-msg"; then
    echo "yes"
    $CSVNROOT/hooks/commit-msg $2
    if ! test $? -eq 0; then exit 1; fi
else
    echo "no"
fi
