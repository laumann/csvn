#!/bin/bash
# $1 is the name of the file in which our commit message is
# $2 is the name of the temporary svn commit message file (created by svn)

TMP=`mktemp`

echo "$@"

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
if test -f "$CSVNROOT/hooks/commit-msg"; then
    $CSVNROOT/hooks/commit-msg $2
    test ! $? -eq 0 || die
fi
