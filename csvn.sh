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
# To contact the author by e-mail:
#    laumann.thomas@gmail.com
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

MAJOR=0
MINOR=2
REV=0

# Source lib directory
for f in $(ls $CSVNROOT/lib/*.sh); do source "$f" \
    || { die "Error sourcing $f"; }; done

# User didn't supply any arguments? Help them!
test ! $# -eq 0 || usage

# First, look for csvn options - these are few.
# When adding more options to csvn, make to that it sets csvn_opts_on
# to true, because this indicates whether or not we _need_ to match
# '--'
csvn_opts_on=false
while test "${1+isset}"; do
    case "$1" in
	--svn=*)
	    SVN=$(echo "$1" | sed -n 's/^--svn=\(..*\)$/\1/p')

	    test ! -z "$SVN" || die -e "--svn requires a path argument\n"
	    
	    csvn_opts_on=true
	    shift
	    ;;
	--)
	    shift
	    break
	    ;;
	--help|-h|help)
	    usage
	    ;;
	-v|--version)
	    echo "$CSVN version $MAJOR.$MINOR.$REV"
	    exit 0
	    ;;
	*)
	    if $csvn_opts_on; then die -e \
		"$1 not recognised as a csvn option. Perhaps you forgot the"\
		"\ndouble dash (--) to separate csvn and svn options?\n"
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
	    if test -x "$CSVNROOT/hooks/pre-commit"; then
		$CSVNROOT/hooks/pre-commit || die
	    fi

	    docommit "$@"

	    # Post commit
	    if test $? -eq 0 -a -x "$CSVNROOT/hooks/post-commit"; then
		$CSVNROOT/hooks/post-commit
	    fi

	    rm $TMP
	    ;;
	diff|di)
	    $SVN "$@" |less -FX
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