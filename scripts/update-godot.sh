#!/bin/bash
#################################################################
# update-godot.sh
#
# Automates the changes needed when adding/updating the version
# of Godot
#################################################################

# Arguments
VERSION=$1

if [ -z "${VERSION}" ]; then
    echo "ERROR: Missing version in first argument"
    exit 1
fi

# Files to change
DOCKER_FILE=Dockerfile
README_FILE=README.md
ACTION_FILE=action.yml
VERSIONS_FILE=""

MAJOR_VERSION="${VERSION%%.*}"
if [ "${MAJOR_VERSION}" = "3" ]; then
    VERSIONS_FILE="godot3/versions.yml"
else
    VERSIONS_FILE="godot4/versions.yml"
fi

if [ ! -f "${DOCKER_FILE}" -o ! -f "${README_FILE}" -o ! -f "${ACTION_FILE}" -o ! -f "${VERSIONS_FILE}" ]; then
    echo "ERROR: Could not find files, perhaps in the wrong directory?"
    exit 1
fi

VERSION_PATTERN='[0-9]+\.[0-9]+(\.[0-9]+)?'

# =====================
# Versions file
# =====================

# Update `latest:`
sed --in-place --regexp-extended '/^latest:/'"s/${VERSION_PATTERN}/${VERSION}/" "${VERSIONS_FILE}"

# Ensure `versions:` contains the new version (prepend if missing)
if ! grep -qE "^[[:space:]]*-[[:space:]]*['\\\"]?${VERSION}['\\\"]?[[:space:]]*$" "${VERSIONS_FILE}"; then
    tmp_file="$(mktemp)"
    awk -v v="${VERSION}" '
        $0 ~ /^versions:/ { print; print "  - \x27" v "\x27"; next }
        { print }
    ' "${VERSIONS_FILE}" > "${tmp_file}"
    mv "${tmp_file}" "${VERSIONS_FILE}"
fi

# =====================
# Dockerfile
# =====================

sed --in-place --regexp-extended '/ARG GODOT_VERSION=/'"s/${VERSION_PATTERN}/${VERSION}/" "${DOCKER_FILE}"

# =====================
# README
# =====================

# Example github action
sed --in-place --regexp-extended '/godot-export-action/'"s/${VERSION_PATTERN}/${VERSION}/" "${README_FILE}"
# List of older versions supported
legacy_version_expression='/Supported versions/ { 
    n;
    s/(.*)/`v'"${VERSION}"'`, \1/
}'
sed --in-place --regexp-extended "${legacy_version_expression}" "${README_FILE}"

# =====================
# Action
# =====================

# Update `runs.image`
sed --in-place --regexp-extended '/godot-export-action/'"s/${VERSION_PATTERN}/${VERSION}/" "${ACTION_FILE}"
