#!/bin/bash

export SVN=/usr/bin/svn
export CSVNROOT=$(dirname "$0")
CSVN=$(basename "$0")

# Help function
helper() {
    echo "$CSVN - wrapper program to provide extra nifty features for client side"
    echo "          subversion usage."
    echo
    echo "Usage:  $CSVN [normal svn options]"
    echo "        $CSVN [--svn /path/to/svn] [normal svn options]"
    echo "        $CSVN [-h|--help]"
    echo "        $CSVN [-v|--version]"
    echo
    echo " Client side Subversion sucks - there is very little customisability, which"
    echo " completely ruins the experience for a lot of users. This bundle of scripts wraps"
    echo " around the svn command line tool to provide the extra functionality that YOU want."
    echo 
    echo " Common commands:"
    echo "  -h, --help     Display this help information and exit."
    echo "  -v, --version  Print the version number and exit."
}

# User didn't supply any arguments? Help them!
if test $# -eq 0; then helper; exit; fi

# Look at svn arguments
dosvn() {
    case "$1" in
	commit|ci)
	    shift 		# Get rid of 'commit'

	    # Pre-commit
	    echo -n "[$CSVN] pre-commit... "
	    if test -f "$CSVNROOT/hooks/pre-commit"; then
		echo "yes"
		$CSVNROOT/hooks/pre-commit
		if test ! $? -eq 0; then exit $?; fi
	    else
		echo "no"
	    fi

	    TMP=`mktemp`

	    # Prepare commit message
	    echo -n "[$CSVN] prepare-commit-msg... "
	    if test -f "$CSVNROOT/hooks/prepare-commit-msg"; then
		echo "yes"
		$CSVNROOT/hooks/prepare-commit-msg $TMP $@
	    else
		echo "no"
	    fi

	    # Check commit message
	    echo -n "[$CSVN] commit-msg... "
	    if test -f "$CSVROOT/hooks/commit-msg"; then
		echo "yes"
		$CSVNROOT/hooks/commit-msg $TMP
	    else
		echo "no"
	    fi

	    # Commit
	    $SVN commit $@ --editor-cmd="$CSVNROOT/util/svn-editor.sh $TMP"
	    rm $TMP
	    ;;
	--svn)
	    SVN=$2             # Get path to svn
	    shift
	    shift
	    dosvn $@           # Call recursively
	    ;;
	-h|--help|help)
    	    helper
	    exit
	    ;;
	-v|--version)
    	    echo "csvn.sh 0.1.0"
	    exit
	    ;;
	*)
	    $SVN $@
	    ;;
    esac
}

dosvn $@

unset SVN
unset CSVNROOT