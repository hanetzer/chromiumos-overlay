# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="f47f79ac35da89691d727b61cca32ad5f8661fed"

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
		doexe host/cros_sign_bootstub
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
		# Data directory
		diropts -m0777 # Install cache as a+w.
		dodir /var/lib/devserver
		dodir /var/lib/devserver/static
		dodir /var/lib/devserver/static/cache
		diropts -m0755
		dosym /build /var/lib/devserver/static/pkgroot
		# FIXME(zbehan): Remove compatibility symlink. Eventually.
		dosym /var/lib/devserver/static /usr/bin/static
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

pkg_preinst() {
	# Handle pre-existing possibly problematic configurations of static
	if use cros_host; then
		if ! [ -L "/usr/bin/static" ]; then
			einfo "/usr/bin/static detected, and is not a symlink, performing cleanup"
			# Well, I don't know what else should be done about it. Moving the
			# files has several issues: handling of all kinds of links, special
			# files, permissions, etc. Autoremval is not a good idea, what if
			# this ended up with accidental destruction of the system?
			local newname="static-old-${RANDOM}" # In case this happens more than once.
			mv /usr/bin/static /usr/bin/${newname}
			ewarn "/usr/bin/${newname} has the previous contents of static."
			ewarn "It can be safely deleted (or kept around forever)."
		fi
	fi
}
