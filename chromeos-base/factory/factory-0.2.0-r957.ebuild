# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d56802a46ea89e2cacfeed0df427756db5619cfe"
CROS_WORKON_TREE="b35075035ce706a64b02343bf94879afb0145359"
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

DEPEND="virtual/chromeos-bsp-factory
	virtual/chromeos-regions
	dev-python/enum34
	dev-python/jsonrpclib
	dev-python/pyyaml
	dev-python/protobuf-python
"

BUILD_DIR="${WORKDIR}/build"

src_prepare() {
	# Need the lddtree from the chromite dir.
	export PATH="${CHROMITE_BIN_DIR}:${PATH}"
}

src_configure() {
	default
	cros-workon_src_configure

	# Export build settings
	export BOARD="${SYSROOT##*/}"
	export OUTOFTREE_BUILD="${CROS_WORKON_OUTOFTREE_BUILD}"
	export PYTHON="$(PYTHON)"
	export PYTHON_SITEDIR="${EROOT}$(python_get_sitedir)"
	export SRCROOT="${CROS_WORKON_SRCROOT}"
	export TARGET_DIR=/usr/local/factory
	export WEBGL_AQUARIUM_DIR="${WORKDIR}/webgl_aquarium_static"

	# Support out-of-tree build.
	export BUILD_DIR="${WORKDIR}/build"

	# The path of bundle is defined in chromite/cbuildbot/commands.py
	export BUNDLE_DIR="${ED}usr/local/factory/bundle"
}

src_unpack() {
	cros-workon_src_unpack
	default
}

src_install() {
	emake bundle
	insinto "${CROS_FACTORY_BOARD_RESOURCES_DIR}"
	doins "${BUILD_DIR}/resource/installer.tar"
}
