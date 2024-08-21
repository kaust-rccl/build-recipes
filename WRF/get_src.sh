#!/bin/bash
function usage() {
   echo "Usage: $0 version"
   echo "       version in format X.Y.Z"
   exit 0
}
if [[ $@ == "--help" ||  $@ == "-h" ]]; then
        usage
fi
if [ $# -ne 1 ] ; then
    usage
else
    version=v$1
fi
git clone --branch $version --recurse-submodule https://github.com/wrf-model/WRF.git
