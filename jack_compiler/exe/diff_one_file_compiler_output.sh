#!/usr/bin/env bash

provided_project_compiler='/Users/ofer987/me/nand2Tetris_partTwo/nand2tetris/tools/JackCompiler.sh'

my_project_compiler='/Users/ofer987/me/nand2Tetris_partTwo/jack_compiler/exe/file_compiler'

jack_path=$1
vm_code_path="${jack_path%.*}.vm"

$provided_project_compiler $jack_path
diff --color <(cat $vm_code_path) <($my_project_compiler $jack_path)
