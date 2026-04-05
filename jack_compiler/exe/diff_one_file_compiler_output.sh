#!/usr/bin/env bash

provided_project_compiler='/Users/ofer987/me/nand2Tetris_partTwo/nand2tetris/tools/JackCompiler.sh'

my_project_compiler='/Users/ofer987/me/nand2Tetris_partTwo/jack_compiler/exe/file_compiler'

jack_path=$1
expected_vm_code_path="${jack_path%.*}.vm"

$provided_project_compiler $jack_path

actual_vm_code_path="${jack_path%.*}.actual.vm"
$my_project_compiler $jack_path > $actual_vm_code_path

diff --color <(cat $expected_vm_code_path) <(cat $actual_vm_code_path)
