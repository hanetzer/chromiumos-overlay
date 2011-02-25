# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="48f24175298dffaa78432d0132d0425f803cb410"

inherit cros-workon

DESCRIPTION="Development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host"

CROS_WORKON_PROJECT="dev-util"
CROS_WORKON_LOCALNAME="dev"


RDEPEND="app-shells/bash
	app-portage/gentoolkit
	dev-lang/python
	dev-libs/shflags
	!cros_host? ( !chromeos-base/gmerge )
	"

DEPEND="${RDEPEND}
	cros_host? ( dev-util/crosutils )
	"

src_install() {
	exeinto /usr/bin
	insinto /usr/bin

	if ! use cros_host; then
		doexe gmerge
		doexe stateful_update
	else
		doexe host/write_tegra_bios
		doexe host/cros_overlay_list
		doexe host/cros_workon
		doexe host/cros_choose_profile
		doexe host/willis

		# Devserver and friends:
		doexe host/start_devserver
		doexe devserver.py
		# TODO(zbehan): Used by image_to_live.sh, find out why, since the
		# target already has a copy.
		doexe stateful_update
		# These need to live with devserver, but not +x.
		doins builder.py
		doins autoupdate.py
		doins buildutil.py
		# Related to devserver
		dobin host/cros_generate_update_payload
		dobin host/cros_generate_stateful_update_payload
		# FIXME(zbehan): This all should live in /var/, probably? Needs a
		# modification of devserver.
		dodir /usr/bin/static
		dosym /build /usr/bin/static/pkgroot
		diropts -m0777 # Install cache as a+w.
		dodir /var/devserver-cache
		dosym /var/devserver-cache /usr/bin/static/cache
		diropts -m0755
	fi
}

src_test() {
	cd ${S} # Let's just run unit tests from ${S} rather than install and run.

	local TESTS=""
	if ! use cros_host; then
		TESTS+="gmerge_test.py "
		# FIXME(zbehan): import gmerge in gmerge_test.py won't work if we won't
		# have the .py.
		ln -sf gmerge gmerge.py
	else
		TESTS+="autoupdate_unittest.py "
		TESTS+="builder_test.py "
		TESTS+="devserver_test.py "
		#FIXME(zbehan): update_test.py doesn't seem to work right now.
	fi

	for test in ${TESTS}; do
		einfo "Running ${test}"
		./${test} || die "Failed in ${test}"
	done
}
