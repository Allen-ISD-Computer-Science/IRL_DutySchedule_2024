#!/bin/bash
pushd ../frontend
run
popd
makeSwift "$@"
