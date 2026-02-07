#!/usr/bin/env bash

PROVIDED_PROJECT_COMPILER='/Users/ofer987/me/nand2Tetris_partTwo/nand2tetris/tools/JackCompiler.sh'

MY_PROJECT_COMPILER='/Users/ofer987/me/nand2Tetris_partTwo/jack_compiler/exe/compiler'

JACK_PATH=$1
VM_CODE_PATH=$(echo $JACK_PATH | sed s/\.jack/\.vm/)

$PROVIDED_PROJECT_COMPILER $JACK_PATH

diff --color $VM_CODE_PATH <($MY_PROJECT_COMPILER $JACK_PATH)
