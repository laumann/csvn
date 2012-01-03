#!/bin/bash

# Expects to receive $@
docommit() {
    
    # Question 1: Do we have -m|--message OR -F|--file? If so, what to do?
    ARGS=("$@") # Get positional parameters as an array

    nargs=()
    m=false
    F=false

    i=0
    for (( ; i < $# ; i++)); do
	arg="${ARGS[$i]}"
	case "$arg" in
	    --targets|\
	    --force-log|\
	    --editor-cmd|\
	    --encoding|\
	    --with-revprop|\
	    --changelist|\
	    --username|\
	    --password|\
	    --config-dir|\
	    --config-option)
		((i++))
		;;
	    -F|--file)
		((i++))
		F=true
		;;
	    -m|--message)
		((i++))
		ARGS[$i]="\"${ARGS[$i]}\""
		;;
	    -*|--*)
	        # These we just skip
		;;
	    *)
		nargs[${#nargs[*]}]="$arg"
		;;
	esac
    done

    echo "Length: ${#nargs[*]}"
    echo "Result: ${nargs[*]}"
    echo "ARGS:   ${ARGS[*]}"

    if $m || $F; then
	eval "$SVN commit ${ARGS[*]}"
	exit $?
    fi

    if test -f "$CSVNROOT/hooks/prepare-commit-msg"; then
	$CSVNROOT/hooks/prepare-commit-msg "$TMP" "${nargs[*]}" || die "prepare-commit-msg failed"
    fi
    
    # Temporary to hold the commit message
    TMP=`mktemp`

    # -m nor -F is set - invoke editor
    # echo "$SVN ${ARGS[*]} --editor-cmd=\"$CSVNROOT/util/svn-editor.sh $TMP ${nargs[*]}\""
    eval "$SVN commit ${ARGS[*]} --editor-cmd=\"$CSVNROOT/util/svn-editor.sh $TMP ${nargs[*]}\""
}