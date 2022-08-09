#!/usr/bin/env bash
set -euo pipefail

# This script is used to build the plugin docs with antisbull.
#
# REQUIREMENTS:
# - The current crowdstrike.falcon repo must be mounted to /usr/share/collections/ansible_collections/crowdstrike/falcon
# - use the following docker command:
#   --volume=/git/ansible_collection_falcon:/usr/share/ansible/collections/ansible_collections/crowdstrike/falcon

# Set destination directory for the docs
DEST_PATH=/usr/share/ansible/collections/ansible_collections/crowdstrike/falcon

# Ensure directory exists and is valid**
if [ ! -d ${DEST_PATH} ]; then
    echo "The current ansible_collection_falcon repo must be mounted to ${DEST_PATH}"
    echo """
Use the following docker command as an example:
$ docker run -it --rm --volume=/git/ansible_collection_falcon:${DEST_PATH} ...
    """
    exit 1
else
    if [ ! -d "${DEST_PATH}/plugins" ]; then
        echo "Could not find plugins directory in ${DEST_PATH}"
        echo "Ensure you have mounted the ansible_collection_falcon repo to ${DEST_PATH}"
        exit 1
    fi
fi

# Create a temporary directory to build the docs
TEMP_DIR=$(mktemp -d)

# Run antisbull to build the docs skeleton
antsibull-docs sphinx-init --squash-hierarchy --use-current --dest-dir ${TEMP_DIR} crowdstrike.falcon

pushd ${TEMP_DIR}

# Install the requirements
pip install -r requirements.txt

# Build the docs
./build.sh

# Copy the docs to the output directory
USER=$(stat -c '%u' ${DEST_PATH})
GROUP=$(stat -c '%g' ${DEST_PATH})
rsync -avz --chown=${USER}:${GROUP} --delete --exclude='.nojekyll' build/html ${DEST_PATH}/

popd

# Clean up the temporary directory
rm -rf ${TEMP_DIR}

# Add nojekyll file to the output directory
touch ${DEST_PATH}/html/.nojekyll

echo """

The docs have been built and copied to ${DEST_PATH}/html

Verify changes from your git repo.
"""
