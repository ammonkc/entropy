#!/usr/bin/env bash

entropyRoot=~/.entropy

mkdir -p "$entropyRoot"

cp -i src/stubs/Entropy.yaml "$entropyRoot/Entropy.yaml"
cp -i src/stubs/after.sh "$entropyRoot/after.sh"
cp -i src/stubs/aliases "$entropyRoot/aliases"

echo "Entropy initialized!"
