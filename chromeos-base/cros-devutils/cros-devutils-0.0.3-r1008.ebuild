# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d17f5565166e9751e85a29b6b121dc0bb5e480c9"
CROS_WORKON_TREE="1190d8c299040d9596168fe3930f5728d00a4993"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="dev"
# Avoid copying any devserver data created outside the chroot.
CROS_WORKON_SUBDIR_BLACKLIST=( "static" )

inherit cros-workon multilib python

DESCRIPTION="Development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host test"

RDEPEND="cros_host? ( app-emulation/qemu )
	app-portage/gentoolkit
	cros_host? ( app-shells/bash )
	>=chromeos-base/devserver-0.0.2
	!cros_host? ( !chromeos-base/gmerge )
	dev-lang/python
	dev-util/shflags
	cros_host? ( dev-util/crosutils )
	"
# These are all either bash / python scripts.  No actual builds DEPS.
DEPEND=""

src_install() {
	dosym /build /var/lib/devserver/static/pkgroot
	dosym /var/lib/devserver/static /usr/lib/devserver/static

	if ! use cros_host; then
		dobin gmerge stateful_update
	else
		local host_tools
		host_tools=(
			cros_choose_profile
			cros_chrome_make
			cros_sign_bootstub
			cros_workon_make
			dump_i2c
			dump_tpm
			gdb_remote
			gdb_x86_local
			gmergefs
			image_to_live.sh
			paycheck.py
			blockdiff.py
			strip_package
			ssh_no_update
			willis
		)

		dobin "${host_tools[@]/#/host/}"

		# Payload generation scripts.
		dobin host/cros_generate_update_payload
		dobin host/cros_generate_stateful_update_payload

		# Repo and git bash completion.
		insinto /usr/share/bash-completion
		newins host/repo_bash_completion repo
		local f
		for f in git{,-prompt} repo; do
			dosym /usr/share/bash-completion/${f} /etc/bash_completion.d/${f}
		done

		insinto "$(python_get_sitedir)"
		# Copy the python files in this directory except __init__.py
		doins $(find host/lib/ -name '*.py' | grep -v __init__)
	fi
}

src_test() {
	cd "${S}" # Let's just run unit tests from ${S} rather than install and run.

	# Setup FDT test file
	pushd host/tests >/dev/null
	./make-test.sh || die
	popd >/dev/null

	# Run host/lib tests
	pushd host/lib >/dev/null
	local libfile
	local test_flag
	for libfile in *.py; do
		test_flag=""
		if [[ ${libfile} != *_unittest.py ]]; then
			test_flag="--test"
		fi
		einfo Running tests in ${libfile}
		python ${libfile} ${test_flag} || \
			die "Unit tests failed at ${libfile}!"
	done
	popd >/dev/null

	pushd host/tests >/dev/null
	for ut_file in *.py; do
		echo Running tests in ${ut_file}
		PYTHONPATH=../lib python ${ut_file} ||
		die "Unit tests failed at ${ut_file}!"
	done
	popd >/dev/null

	# Run all the unittests from the "host" directory.
	local TESTS=( $(find host -name '*_unittest.py' -type f) )

	if ! use cros_host; then
		TESTS+=( gmerge_test.py )
		# FIXME(zbehan): import gmerge in gmerge_test.py won't work if we won't
		# have the .py.
		ln -sf gmerge gmerge.py
	else
		TESTS+=( autoupdate_unittest.py )
		TESTS+=( builder_test.py )
		TESTS+=( common_util_unittest.py )
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
