#!/bin/bash

# SHIO - Shell IO library
if [[ -z $SHIO_LOADED ]]; then
    SHIO_LOADED=1

    [ -z $SHIO_WORKSPACE ] && SHIO_WORKSPACE="/tmp/shio-$$"
    [ -z $SHIO_VERBOSE ] && SHIO_VERBOSE=false

    function __shio_init {
	mkdir -p $SHIO_WORKSPACE
	mkdir $SHIO_WORKSPACE/tmpfile
	__shio_last_ts=0
	__shio_last_seq=0
    }
    
    function __shio_uninit {
	rm -rf $SHIO_WORKSPACE
    }
    
    function __shio_mktemp_file {
	mktemp $SHIO_WORKSPACE/tmpfile/file-XXXXXXXX
    }
    
    function __shio_get_ts {
	date +"%s"
    }

    function SHIO_send_message { # dir, msg
	local destdir="$1"
	local msg="$2"
	local ts=$(__shio_get_ts)
	local seq=0
	if [[ $ts == $__shio_last_ts ]]; then
	    seq=$[ $__shio_last_seq + 1 ];
	fi
	__shio_last_ts=$ts
	__shio_last_seq=$seq
	local srcfile=$(__shio_mktemp_file)
	local destfile=$(printf "%s/%016x-%08x.msg" "$destdir" $ts $seq)
	echo "$msg" > $srcfile
	rsync -rDz $srcfile $destfile
	local ret=$?
	rm -f $srcfile
	return $ret
    }

    function SHIO_recv_message { # dir
	local msgfile
	while [ 1 ]; do
	    for msgfile in $(find $1 -name "*.msg" | sort | head -1); do
		cat $msgfile
		rm -f $msgfile
		return 0
	    done
	    sleep 1
	done
    }

    __shio_init
    trap __shio_uninit SIGINT SIGTERM EXIT
fi
