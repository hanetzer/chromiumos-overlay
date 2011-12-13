# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="2b45f67d68d0d3908504ca762f97279e495f6381"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"

inherit cros-workon multilib python

DESCRIPTION="Development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host"

CROS_WORKON_LOCALNAME="dev"


RDEPEND="cros_host? ( app-emulation/qemu-kvm )
	app-portage/gentoolkit
	cros_host? ( app-shells/bash )
	!cros_host? ( !chromeos-base/gmerge )
	dev-lang/python
	dev-libs/shflags
	dev-util/shflags
	cros_host? ( dev-util/crosutils )
	"

# These are all either bash / python scripts.  No actual builds DEPS.
DEPEND=""

src_install() {
	exeinto /usr/bin
	insinto /usr/bin

	if ! use cros_host; then
		doexe gmerge || die "Could not find file to install."
		doexe stateful_update || die "Could not find file to install."
	else
		doexe host/cros_overlay_list || die "Could not find file to install."
		doexe host/cros_workon || die "Could not find file to install."
		doexe host/cros_chrome_make || die "Could not find file to install."
		doexe host/cros_workon_make || die "Could not find file to install."
		doexe host/cros_choose_profile || die "Could not find file to install."
		doexe host/cros_sign_bootstub || die "Could not find file to install."
		doexe host/cros_bundle_firmware || die "Could not find file to install."
		doexe host/cros_write_firmware || die "Could not find file to install."
		doexe host/dump_i2c || die "Could not find file to install."
		doexe host/dump_tpm || die "Could not find file to install."
		doexe host/gdb_x86_local || die "Could not find file to install."
		doexe host/gdb_remote || die "Could not find file to install."
		doexe host/willis || die "Could not find file to install."
		doexe host/ssh_no_update || die "Could not find file to install."

                doexe host/cros_start_vm || die "Could not find file to install."
                doexe host/cros_stop_vm || die "Could not find file to install."

                doexe host/image_to_live.sh || die "Could not find file to install."
                doexe host/gmergefs || die "Could not find file to install."

		# Devserver and friends:
		doexe host/start_devserver || die "Could not find file to install."
		doexe devserver.py || die "Could not find file to install."
		# TODO(zbehan): Used by image_to_live.sh, find out why, since the
		# target already has a copy.
		doexe stateful_update || die "Could not find file to install."
		# These need to live with devserver, but not +x.
		doins builder.py || die "Could not find file to install."
		doins autoupdate.py || die "Could not find file to install."
		doins buildutil.py || die "Could not find file to install."
		# Related to devserver
		dobin host/cros_generate_update_payload ||
			die "Could not find file to install."
		dobin host/cros_generate_stateful_update_payload ||
			die "Could not find file to install."
		# Data directory
		diropts -m0777 # Install cache as a+w.
		dodir /var/lib/devserver
		dodir /var/lib/devserver/static
		dodir /var/lib/devserver/static/cache ||
			die "Could not create cache directory."
		diropts -m0755
		dosym ../../../../build /var/lib/devserver/static/pkgroot
		# FIXME(zbehan): Remove compatibility symlink. Eventually.
		dosym ../../var/lib/devserver/static /usr/bin/static

		# Repo and git bash completion.
		insinto /usr/share/bash-completion
		newins host/repo_bash_completion repo || die "Could not find file to install."
		dosym /usr/share/bash-completion/git /etc/bash_completion.d/git
		dosym /usr/share/bash-completion/repo /etc/bash_completion.d/repo

		local python_lib="/usr/$(get_libdir)/python$(python_get_version)/site-packages"
		insinto "${python_lib}"
		doins host/lib/*.py || die "Could not install python files."
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
		if [ -e "/usr/bin/static" ] && ! [ -L "/usr/bin/static" ]; then
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
