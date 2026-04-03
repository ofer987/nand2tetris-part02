#!/usr/bin/env bash

PROVIDED_PROJECT_COMPILER='/Users/ofer987/me/nand2Tetris_partTwo/nand2tetris/tools/JackCompiler.sh'

MY_PROJECT_COMPILER='/Users/ofer987/me/nand2Tetris_partTwo/jack_compiler/exe/file_compiler'

JACK_PATH=$1
VM_CODE_PATH="${1}/*.vm"

$PROVIDED_PROJECT_COMPILER $JACK_PATH
diff --color <(cat $VM_CODE_PATH) <($MY_PROJECT_COMPILER $JACK_PATH)
