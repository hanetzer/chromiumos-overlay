# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a5ef250977820d42aa75e7a41015c42d70759862"
CROS_WORKON_TREE="23b804158ca30ae0b481befd774c0b61b330a4fc"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon python cros-constants cros-factory

# External dependencies
LOCAL_MIRROR_URL=http://commondatastorage.googleapis.com/chromeos-localmirror/
WEBGL_AQUARIUM_URI=${LOCAL_MIRROR_URL}/distfiles/webgl-aquarium-20130524.tar.bz2

DESCRIPTION="Chrome OS Factory Software Platform"
HOMEPAGE="http://www.chromium.org/"
SRC_URI="${WEBGL_AQUARIUM_URI}"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="virtual/chromeos-interface
	virtual/chromeos-regions
	chromeos-base/chromeos-factory-board
	dev-python/jsonrpclib
	dev-python/pyyaml
	dev-libs/protobuf-python
"

BUILD_DIR="${WORKDIR}/build"

src_configure() {
	default
	cros-workon_src_configure

	# Export build settings
	export BOARD="${SYSROOT##*/}"
	export OUTOFTREE_BUILD="${CROS_WORKON_OUTOFTREE_BUILD}"
	export PYTHON="$(PYTHON)"
	export PYTHON_SITEDIR="${EROOT}$(python_get_sitedir)"
	export TARGET_DIR=/usr/local/factory
	export WEBGL_AQUARIUM_DIR="${WORKDIR}/webgl_aquarium_static"

	# Support out-of-tree build.
	export BUILD_DIR="${WORKDIR}/build"

	# The path of bundle is defined in chromite/cbuildbot/commands.py
	export BUNDLE_DIR="${ED}usr/local/factory/bundle"
}

src_install() {
	emake bundle

	# Create cutoff resource from $(TOOLKIT_TEMP_DIR) for
	# chromeos-base/factory_installer.
	factory_create_resource cutoff \
		"${BUILD_DIR}/tmp/toolkit/usr/local/factory/sh" "" "cutoff"
}
