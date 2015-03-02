#!/usr/bin/env bash

mkdir -p ~/.entropy

entropyRoot=~/.entropy

cp -i src/stubs/Entropy.yaml $entropyRoot/Entropy.yaml
cp -i src/stubs/after.sh $entropyRoot/after.sh
cp -i src/stubs/aliases $entropyRoot/aliases

echo "Entropy initialized!"
