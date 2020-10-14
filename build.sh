#!/bin/bash

set -e
set -u
set -o pipefail

version=`cat BackpackCurrenciesEnhanced.toc | grep Version | cut -f2 -d: | xargs`
directory="BackpackCurrenciesEnhanced-${version}"
mkdir -p ${directory}
cp BackpackCurrenciesEnhanced.toc BackpackCurrenciesEnhanced.lua "${directory}/"
zip -m -9 -r ${directory}.zip "${directory}/"
