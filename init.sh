#!/usr/bin/env bash

mkdir -p ~/.entropy

cp src/stubs/Entropy.yaml ~/.entropy/Entropy.yaml
cp src/stubs/after.sh ~/.entropy/after.sh
cp src/stubs/aliases ~/.entropy/aliases

echo "Entropy initialized!"
