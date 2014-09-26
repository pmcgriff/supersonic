#!/bin/bash

# Push a version update commit with this message
VERSION=$(git rev-parse HEAD)

TMP_DIR=tmp
ARTEFACTS_DIR=tmp/artefacts
TARGET_DIR=tmp/target

HEAD_VERSION=$(git rev-parse HEAD)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
SOURCE_REPO=https://$GITHUB_AUTHENTICATION@github.com/AppGyver/supersonic.git#$HEAD_VERSION
TARGET_REPO=https://$GITHUB_AUTHENTICATION@github.com/AppGyver/supersonic-bower.git

# Install supersonic from current revision to temp dir
echo Installing $SOURCE_REPO to $ARTEFACTS_DIR
mkdir -p $ARTEFACTS_DIR
(cd $ARTEFACTS_DIR ; bower install $SOURCE_REPO)

# Clone target repo
echo Cloning $TARGET_REPO to $TARGET_DIR
rm -rf $TARGET_DIR
git clone $TARGET_REPO $TARGET_DIR

# Copy bower-installed supersonic artefacts to target bower repo
cp -r $ARTEFACTS_DIR/bower_components/supersonic/* $TARGET_DIR

# Tag and push repo
(cd $TARGET_DIR ; git checkout $CURRENT_BRANCH ; git add -A ; git commit -m $VERSION ; git push origin $CURRENT_BRANCH)

# Clean up
rm -rf $TMP_DIR/*