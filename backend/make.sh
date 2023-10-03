#!/bin/bash

if [ ! -d "Public/static/" ]; then
    echo "Frontend not found... Creating in 3... 2... 1..."
    sleep 3
    pushd ../frontend
    run
    popd
fi

makeSwift "$@"
