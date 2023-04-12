#!/bin/bash

preset=$1
export_path=$2
project_directory=$3
projectfile_directory=$4

if [ "${project_directory}" != "" ]; then
  project_full_path="${GITHUB_WORKSPACE%%/}${GITHUB_WORKSPACE:+/}${project_directory}"

  echo
  echo "-- Switching to project directory ${project_full_path}"
  cd ${project_full_path}
fi

export_directory=$(dirname ${export_path})
echo
echo "-- Making sure export directory exists ${export_directory}"
mkdir -p ${export_directory}

path_arg=""
if [ "${projectfile_directory}" != "" ]; then
  path_arg="--path ${projectfile_directory}"
fi

echo
echo "-- Exporting ${export_name} to ${export_path}"
echo "godot ${path_arg} --export-release ${preset} ${export_path}"
godot ${path_arg} --export-release ${preset} ${export_path}