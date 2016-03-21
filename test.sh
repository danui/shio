#!/bin/bash

source libshio.sh
#source libshio.sh

function assert_equals { #expected, got
    local t=${FUNCNAME[1]}
    if [[ "$1" != "$2" ]]; then
	printf "\r"
	printf "FAIL    $t\n"
	echo "- expected '$1' got '$2'"
	exit 1
    fi
}

function test001_send_recv {
    local ch=$(mktemp -d /tmp/libshio-test-XXXXXXXX)
    local msg="Hello There"
    SHIO_send_message "$ch" "$msg"
    local rmsg=$(SHIO_recv_message "$ch")
    assert_equals "$msg" "$rmsg"
    rm -rf $ch
}

function test002_send2_recv2 {
    local ch=$(mktemp -d /tmp/libshio-test-XXXXXXXX)
    local rmsg
    SHIO_send_message "$ch" "Message 1"
    SHIO_send_message "$ch" "Message 2"
    assert_equals "Message 1" "$(SHIO_recv_message $ch)"
    assert_equals "Message 2" "$(SHIO_recv_message $ch)"
    rm -rf $ch
}

function test003_sendN_recvN {
    local ch=$(mktemp -d /tmp/libshio-test-XXXXXXXX)
    local rmsg
    for ((i=0; i<25; ++i)); do
	SHIO_send_message "$ch" "Message $i"
    done
    for ((i=0; i<25; ++i)); do
	assert_equals "Message $i" "$(SHIO_recv_message $ch)"
    done
    rm -rf $ch
}

function __cleanup {
    rm -rf /tmp/libshio-test-*
}

trap __cleanup EXIT

for t in $(declare -F | awk '{print $3}'| grep ^test | sort); do
    printf "TESTING $t"
    $t
    printf "\r"
    printf "PASS    $t\n"
done
