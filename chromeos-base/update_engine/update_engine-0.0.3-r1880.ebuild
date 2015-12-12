# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("0801b39b9fbc09ad703644c6e9d5f38ef459704f" "5a4c5130390f7433aa725996ad95043a0554707c")
CROS_WORKON_TREE=("6b107680fe5a8d19b79ad0b2c13f5fca65f5fe01" "68f7d19a0d6a472cde9286feb5aa354cc1dfd575")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/update_engine")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/update_engine")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/update_engine")
CROS_WORKON_USE_VCSID=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="update_engine"

inherit toolchain-funcs cros-debug cros-workon platform systemd

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="cros_p2p -delta_generator -hwid_override mtd +power_management systemd"

COMMON_DEPEND="
	app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/vboot_reference
	cros_p2p? ( chromeos-base/p2p )
	dev-libs/expat
	dev-libs/openssl
	dev-libs/protobuf
	dev-libs/xz-embedded
	dev-util/bsdiff
	net-misc/curl
	sys-apps/rootdev"

DEPEND="
	app-arch/xz-utils
	chromeos-base/system_api
	chromeos-base/debugd-client
	chromeos-base/power_manager-client
	chromeos-base/session_manager-client
	chromeos-base/shill-client
	chromeos-base/update_engine-client
	dev-cpp/gmock
	dev-cpp/gtest
	mtd? ( dev-embedded/android_mtdutils )
	sys-fs/e2fsprogs
	${COMMON_DEPEND}"

RDEPEND="
	delta_generator? ( app-arch/xz-utils )
	chromeos-base/chromeos-installer
	${COMMON_DEPEND}
	power_management? ( chromeos-base/power_manager )
	delta_generator? ( sys-fs/e2fsprogs )
	virtual/update-policy
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/update_engine"
}

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

	# The unit tests check to make sure the minor version value in
	# update_engine.conf match the constants in update engine, so we need to be
	# able to access this file.
	cp "${S}/update_engine.conf" ./

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
		if [[ -z "${GTEST_FILTER}" ]]; then
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

	insinto /etc
	doins update_engine.conf

	if use systemd; then
		systemd_dounit "${FILESDIR}"/update-engine.service
		systemd_enable_service multi-user.target update-engine.service
	else
		# Install upstart script
		insinto /etc/init
		doins init/update-engine.conf
	fi

	# Install DBus configuration
	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf
}
