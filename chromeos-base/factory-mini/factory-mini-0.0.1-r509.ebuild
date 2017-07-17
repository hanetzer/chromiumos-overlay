# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# factory-mini is a subset of the factory software that can
# be used to run utilities like gooftool, hwid, and regcode, which may
# be useful in the CrOS test environment.  For instance, this would
# allow "gooftool probe" to be used to probe hardware components in
# Moblab.
#
# We don't want to install the entire chromeos-factory package in the
# test image, since it is quite large, so this package comprises a
# small ".par" file (/usr/local/factory-mini/factory-mini.par)
# containing the necessary subset of factory Python code, and symlinks
# from /usr/local/bin to that file.

EAPI=5
CROS_WORKON_COMMIT="62cb3b05331554c798840aca9b4a3d5e5cdd844c"
CROS_WORKON_TREE="bf74a0b869e5fb6762fb0a585ef51bed96929af6"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
CROS_WORKON_DESTDIR="${S}"
PYTHON_COMPAT=( python2_7 )

inherit cros-workon python-r1

DESCRIPTION="Subset of factory software to be installed in test images"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-python/jsonrpclib
	dev-python/pyyaml
	dev-python/protobuf-python
	virtual/chromeos-bsp-factory
	virtual/chromeos-regions
"
RDEPEND="!chromeos-base/chromeos-factory-mini"

src_configure() {
	default
	cros-workon_src_configure

	# Export build settings
	export SRCROOT="${CROS_WORKON_SRCROOT}"
}

src_compile() {
	emake par MAKE_PAR_ARGS=--mini PAR_NAME=factory-mini.par
}

src_install() {
	exeinto /usr/local/factory-mini
	doexe build/par/factory-mini.par

	# Sanity check: make sure we can run gooftool --help with only
	# the -mini.par file.
	build/par/factory-mini.par gooftool --help |
		grep -q "^usage: gooftool" || die

	# Install only symlinks for binaries usable with factory-mini.par.
	"${S}/bin/install_symlinks" \
		--mode mini --target ../factory-mini/factory-mini.par \
		"${D}"/usr/local/bin || die
}
