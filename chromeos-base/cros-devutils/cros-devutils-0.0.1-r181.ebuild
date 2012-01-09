# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4647ce6fc598fde8d855b36956eadf3e89bbfa5b"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="dev"

inherit cros-workon multilib python

DESCRIPTION="Development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host"

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
		doexe gmerge stateful_update
	else
		pushd host >/dev/null
		doexe \
			cros_overlay_list \
			cros_workon \
			cros_chrome_make \
			cros_workon_make \
			cros_choose_profile \
			cros_sign_bootstub \
			cros_bundle_firmware \
			cros_write_firmware \
			dump_i2c \
			dump_tpm \
			gdb_x86_local \
			gdb_remote \
			willis \
			ssh_no_update \
			cros_{start,stop}_vm \
			image_to_live.sh \
			gmergefs
		popd >/dev/null

		# Devserver and friends:
		doexe host/start_devserver devserver.py
		# TODO(zbehan): Used by image_to_live.sh, find out why, since the
		# target already has a copy.
		doexe stateful_update
		# These need to live with devserver, but not +x.
		doins \
			builder.py \
			autoupdate.py \
			buildutil.py \
			constants.py \
			devserver_util.py \
			downloader.py
		# Related to devserver
		dobin host/cros_generate_update_payload
		dobin host/cros_generate_stateful_update_payload
		# Data directory
		diropts -m0777 # Install cache as a+w.
		dodir /var/lib/devserver
		dodir /var/lib/devserver/static
		dodir /var/lib/devserver/static/cache
		diropts -m0755
		dosym ../../../../build /var/lib/devserver/static/pkgroot
		# FIXME(zbehan): Remove compatibility symlink. Eventually.
		dosym ../../var/lib/devserver/static /usr/bin/static

		# Repo and git bash completion.
		insinto /usr/share/bash-completion
		newins host/repo_bash_completion repo
		dosym /usr/share/bash-completion/git /etc/bash_completion.d/git
		dosym /usr/share/bash-completion/repo /etc/bash_completion.d/repo

		insinto "$(python_get_sitedir)"
		doins host/lib/*.py
	fi
}

src_test() {
	cd "${S}" # Let's just run unit tests from ${S} rather than install and run.

	local TESTS=()
	if ! use cros_host; then
		TESTS+=( gmerge_test.py )
		# FIXME(zbehan): import gmerge in gmerge_test.py won't work if we won't
		# have the .py.
		ln -sf gmerge gmerge.py
	else
		TESTS+=( autoupdate_unittest.py )
		TESTS+=( builder_test.py )
		TESTS+=( devserver_test.py )
		TESTS+=( devserver_util_test.py )
		#FIXME(zbehan): update_test.py doesn't seem to work right now.
	fi

	local test
	for test in ${TESTS[@]} ; do
		einfo "Running ${test}"
		./${test} || die "Failed in ${test}"
	done
}

pkg_preinst() {
	# Handle pre-existing possibly problematic configurations of static
	use cros_host || return 0
	if [[ -e ${ROOT}/usr/bin/static && ! -L ${ROOT}/usr/bin/static ]] ; then
		einfo "/usr/bin/static detected, and is not a symlink, performing cleanup"
		# Well, I don't know what else should be done about it. Moving the
		# files has several issues: handling of all kinds of links, special
		# files, permissions, etc. Autoremval is not a good idea, what if
		# this ended up with accidental destruction of the system?
		local newname="static-old-${RANDOM}" # In case this happens more than once.
		mv "${ROOT}"/usr/bin/static "${ROOT}"/usr/bin/${newname}
		ewarn "/usr/bin/${newname} has the previous contents of static."
		ewarn "It can be safely deleted (or kept around forever)."
	fi
}
