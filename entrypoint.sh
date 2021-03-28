#!/bin/bash

project_path=$1
export_name=$2
directory=$3
filname=$4

echo "mkdir -p ${project_path}/${directory}"
mkdir -p ${project_path}/${directory}

output_path=${directory%%/}${directory:+/}$filname

ls -la ${project_path}

echo "godot --path /workspace/${project_path} --export ${export_name} ${output_path}"
godot --path /workspace/${project_path} --export ${export_name} ${output_path}