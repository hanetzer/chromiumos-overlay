# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b03ca79a16dbcb1e8226f5ef672a99eed09bff06"
CROS_WORKON_TREE="9501ccb07b01c8f997118e9d449f801789bd2f53"
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

src_unpack() {
	cros-workon_src_unpack
	default
}

src_install() {
	emake bundle

	# Create cutoff resource from $(TOOLKIT_TEMP_DIR) for
	# chromeos-base/factory_installer.
	local build_toolkit="${BUILD_DIR}/tmp/toolkit"
	local cutoff_base="${build_toolkit}/usr/local/factory/sh"
	local cutoff_json="/usr/local/facory/py/config/cutoff.json"

	if [ -f "${build_toolkit}/${cutoff_json}" ]; then
		local new_base="${BUILD_DIR}/tmp"
		cp -r "${cutoff_base}/cutoff" "${new_base}"
		cp -f "${build_toolkit}/${cutoff_json}" "${new_base}/cutoff"
		cutoff_base="${new_base}"
	fi

	factory_create_resource cutoff "${cutoff_base}" "" "cutoff"
}
