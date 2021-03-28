#!/bin/bash

project_path=$1
export_name=$2
directory=$3
filname=$4

mkdir -p ${directory}

output_path=${directory%%/}${directory:+/}$filname

godot --path /workspace/${project_path} --export ${export_name} ${output_path}