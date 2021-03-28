#!/bin/bash

export_name=$1
directory=$2
filename=$3
project_directory=$4
projectfile_directory=$5

if [ "${project_directory}" != "" ]; then
  project_full_path="${GITHUB_WORKSPACE%%/}${GITHUB_WORKSPACE:+/}${project_directory}"

  echo
  echo "-- Switching to project directory ${project_full_path}"
  cd ${project_full_path}
fi

echo
echo "-- Making sure export directory exists ${directory}"
mkdir -p ${directory}

path_arg=""
if [ "${projectfile_directory}" != "" ]; then
  path_arg="--path ${projectfile_directory}"
fi

output_path=${directory%%/}${directory:+/}$filename
echo
echo "-- Exporting ${export_name} to ${output_path}"
echo "godot ${path_arg} --export ${export_name} ${output_path}"
godot ${path_arg} --export ${export_name} ${output_path}