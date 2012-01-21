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

# From: http://svnbook.red-bean.com/en/1.7/svn.advanced.externaleditors.html
# ----
# Subversion [allows] you to specify an external text editor that it
# will launch as necessary to give you a more powerful input mechanism
# for this textual metadata. [...] Subversion checks the following
# things, in the order specified, when it wants to launch such an editor.
#
# 1) --editor-cmd command-line option
# 2) SVN_EDITOR environment variable
# 3) editor-cmd runtime configuration option
# 4) VISUAL environment variable
# 5) EDITOR environment variable
# 6) Possibly, a fallback value built into the Subversion libraries
#    (not present in the official builds)
# ----
# Of course, we're using (1), so that leaves us with (2), (3), (4) and
# (5). We're not using (6). For (3) we need to look inside
# ~/.subversion/config and determine if editor-cmd is set (not commented)

ED=vim # fallback

# This if block relies on the order in which the variables are tested...
if test -n "${SVN_EDITOR:+x}"; then
    ED="$SVN_EDITOR"
elif grep -e "^[[:space:]]*editor-cmd[[:space:]]*=" ~/.subversion/config &> /dev/null; then
    # Get the editor-cmd from ~/.subversion/config
    ED=$(grep -e "^[[:space:]]*editor-cmd[[:space:]]*=.*$" ~/.subversion/config | sed -n 's/^.*=[[:space:]]*\([^#]*\).*/\1/p')
elif test -n "${VISUAL:+x}"; then
    ED="$VISUAL"
elif test -n "${EDITOR:+x}"; then
    ED="$EDITOR"
fi

$ED $2 # TODO: Allow variable editor

# Check commit message
if test -x "$CSVNROOT/hooks/commit-msg"; then
    $CSVNROOT/hooks/commit-msg $2
    test $? -eq 0 || die "commit-msg hook failed"
fi
