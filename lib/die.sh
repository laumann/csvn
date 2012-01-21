#!/bin/bash

die() {
    echo -n "$@"
    exit 1
}

export -f die
