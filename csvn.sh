#!/bin/bash
# csvn - wrapper program to provide extra nifty features for client
#        side subversion usage.
#
# Copyright (C) 2011  Thomas Bracht Laumann Jespersen <laumann.thomas@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# To contact the author by e-mail: laumann.thomas@gmail.com
#
# To contact the author by paper mail:
#    Thomas Bracht Laumann Jespersen
#    Greisvej 40, 1. TH
#    DK-2300 Copenhagen S
#    Denmark
#

export SVN=${SVN:-/usr/bin/svn}
export CSVNROOT=$(dirname "$0")
export CSVN=$(basename "$0")

# External files
source $CSVNROOT/util/helper.sh

# User didn't supply any arguments? Help them!
if test $# -eq 0; then helper; exit; fi

# First, look for csvn options - these are few.
# When adding more options to csvn, make to that it sets csvn_opts_on
# to true, because this indicates whether or not we _need_ to match
# '--'
csvn_opts_on=false
while test "${1+isset}"; do
    case "$1" in
	--svn)
	    test ! "${2+isset}" -o "$2" = "--" && {
		echo "--svn requires a path argument"
		exit 1
	    }
	    # TODO: Test that $2 is executable
	    SVN="$2"
	    shift
	    shift
	    csvn_opts_on=true
	    ;;
	--)
	    shift
	    break
	    ;;
	--help|-h|help)
	    helper
	    exit 1
	    ;;
	*)
	    if $csvn_opts_on; then
		echo "$1 not recognised as a csvn option. Perhaps you forgot the"
		echo "double dash (--) to separate csvn and svn options?"
		echo
		exit 1
	    fi
	    break
	    ;;
    esac
done

# Look at svn arguments
dosvn() {
    case "$1" in
	commit|ci)
	    shift 		# Get rid of 'commit'

	    # Pre-commit
	    if test -f "$CSVNROOT/hooks/pre-commit"; then
		$CSVNROOT/hooks/pre-commit || exit 1
	    fi

	    TMP=`mktemp`

	    # Prepare commit message
	    if test -f "$CSVNROOT/hooks/prepare-commit-msg"; then
		$CSVNROOT/hooks/prepare-commit-msg $TMP $@ || exit 1
	    fi

	    # Commit
	    # echo "$SVN" commit $ARGS --editor-cmd="$CSVNROOT"/util/svn-editor.sh "$TMP" "$@"
	    $SVN commit "$@" --editor-cmd="$CSVNROOT/util/svn-editor.sh $TMP $@"

	    # Post commit
	    if test $? -eq 0 -a -f "$CSVNROOT/hooks/post-commit"; then
		$CSVNROOT/hooks/post-commit
	    fi

	    rm $TMP
	    ;;
	*)
	    $SVN "$@"
	    ;;
    esac
}

dosvn "$@"

unset SVN
unset CSVNROOT
unset CSVN