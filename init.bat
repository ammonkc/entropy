@echo off

set entropyRoot=%HOMEDRIVE%%HOMEPATH%\.entropy

mkdir "%entropyRoot%"

copy /-y src\stubs\Entropy.yaml "%entropyRoot%\Entropy.yaml"
copy /-y src\stubs\after.sh "%entropyRoot%\after.sh"
copy /-y src\stubs\aliases "%entropyRoot%\aliases"

set entropyRoot=
echo Entropy initialized!
