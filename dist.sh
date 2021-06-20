#!/bin/bash

DIST_OP=dist_output
VERSION=18.1
DEVICE=2e
VARIANT=user

# Source envsetup
source build/envsetup.sh

# Lunch targets
lunch lineage_${DEVICE}-${VARIANT}

function distpkg() {
	# Make updatepackage
	make dist DIST_DIR=$DIST_OP -j32
}

function tgtpkgsign() {
# Sign target files
echo "Signing target files"
sign_target_files_apks \
	-o \
	-d ~/.android-certs $DIST_OP/lineage*-target_files-*.zip \
	lineage-signed-target_files.zip
}

function otapkgsign() {
# Sign package
echo "Signing package - OTA"
ota_from_target_files \
	--package_key  ~/.android-certs/releasekey \
	lineage-signed-target_files.zip \
	lineage-$VERSION-$DEVICE-$(shell date -u +%Y%m%d_%H%M%S).zip
}

function imgpkgsign() {
# Sign package - updatepkg
echo "Signing package - updatepkg"
img_from_target_files lineage-signed-target_files.zip lineage-$VERSION-$DEVICE-$(shell date -u +%Y%m%d_%H%M%S)-signed-img.zip
}

distpkg
tgtpkgsign
otapkgsign
imgpkgsign
