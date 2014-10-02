# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="550bb7e7722125d1d83c4a29c03a44b283523b64"
CROS_WORKON_TREE="edf6d9d6dbc269a07c644d376f616c8c80d345c0"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1

PLATFORM_SUBDIR="update_engine"

inherit toolchain-funcs cros-debug cros-workon platform

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_p2p -delta_generator -hwid_override +power_management"

COMMON_DEPEND="app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/libchromeos
	chromeos-base/metrics
	chromeos-base/vboot_reference
	cros_p2p? ( chromeos-base/p2p )
	>=dev-cpp/gflags-2.0
	dev-libs/dbus-glib
	dev-libs/expat
	dev-libs/glib
	dev-libs/libpcre
	dev-libs/openssl
	dev-libs/protobuf
	dev-util/bsdiff
	net-misc/curl
	sys-apps/rootdev"

DEPEND="chromeos-base/system_api
	dev-cpp/gmock
	dev-cpp/gtest
	sys-fs/e2fsprogs
	${COMMON_DEPEND}"

RDEPEND="
	chromeos-base/chromeos-installer
	${COMMON_DEPEND}
	power_management? ( chromeos-base/power_manager )
	delta_generator? ( sys-fs/e2fsprogs )
	virtual/update-policy
"

platform_pkg_test() {
	local unittests_binary="${OUT}"/update_engine_unittests

	# The unittests will try to exec `./helpers`, so make sure we're in
	# the right dir to execute things.
	cd "${OUT}"
	# The tests also want keys to be in the current dir.
	# .pub.pem files are generated on the "gen" directory.
	for f in unittest_key.pub.pem unittest_key2.pub.pem; do
		cp "${S}"/${f/.pub} ./ || die
		ln -fs gen/include/update_engine/$f $f  \
			|| die "Error creating the symlink for $f."
	done

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		# If GTEST_FILTER isn't provided, we run two subsets of tests
		# separately: the set of non-privileged  tests (run normally)
		# followed by the set of privileged tests (run as root).
		# Otherwise, we pass the GTEST_FILTER environment variable as
		# an argument and run all the tests as root; while this might
		# lead to tests running with excess privileges, it is necessary
		# in order to be able to run every test, including those that
		# need to be run with root privileges.
		if [[ -z ${GTEST_FILTER} ]]; then
			platform_test "run" "${unittests_binary}" 0 '-*.RunAsRoot*' \
			|| die "${unittests_binary} (unprivileged) failed, retval=$?"
			platform_test "run" "${unittests_binary}" 1 '*.RunAsRoot*' \
			|| die "${unittests_binary} (root) failed, retval=$?"
		else
			platform_test "run" "${unittests_binary}" 1 "${GTEST_FILTER}" \
			|| die "${unittests_binary} (root) failed, retval=$?"
		fi
	fi
}

src_install() {
	dosbin "${OUT}"/update_engine
	dobin "${OUT}"/update_engine_client

	use delta_generator && dobin "${OUT}"/delta_generator

	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	insinto /usr/include/chromeos/update_engine
	doins update_engine.dbusserver.h
	doins update_engine.dbusclient.h

	insinto /etc/init
	doins init/update-engine.conf
}
