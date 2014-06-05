# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="77f79e876a77796fc248d099b6574f05bd23c954"
CROS_WORKON_TREE="e2b92a5d3bcdfb401efb96148bcf181605b98a0a"
CROS_WORKON_PROJECT="chromiumos/platform/update_engine"

inherit toolchain-funcs cros-debug cros-workon flag-o-matic scons-utils

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang cros_host cros_p2p -delta_generator -hwid_override"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="271506"

COMMON_DEPEND="app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/platform2
	chromeos-base/vboot_reference
	chromeos-base/verity
	cros_p2p? ( chromeos-base/p2p )
	dev-cpp/gflags
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/libpcre
	dev-libs/libxml2
	dev-libs/openssl
	dev-libs/protobuf
	dev-util/bsdiff
	net-misc/curl
	sys-apps/rootdev
	sys-fs/e2fsprogs"

DEPEND="dev-cpp/gmock
	dev-cpp/gtest
	cros_host? ( dev-util/scons )
	${COMMON_DEPEND}"

RDEPEND="
	!<chromeos-base/chromeos-init-0.0.8
	chromeos-base/chromeos-installer
	${COMMON_DEPEND}
	virtual/update-policy
"


src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	clang-setup-env
	append-flags -DUSE_HWID_OVERRIDE=$(usex hwid_override 1 0)
	export CCFLAGS="$CFLAGS"
	export BASE_VER=${LIBCHROME_VERS}

	escons
}

src_test() {
	local unittests_binary=update_engine_unittests
	local targets=("${unittests_binary}" test_http_server delta_generator)
	escons "${targets[@]}"

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		# We need to set PATH so that the `openssl` in the target
		# sysroot gets executed instead of the host one (which is
		# compiled differently). http://crosbug.com/27683
		local testpath="${SYSROOT}/usr/bin:$PATH"

		# If neither GTEST_ARGS nor GTEST_FILTER is provided, we run
		# two subsets of tests separately: the set of non-privileged
		# tests (run normally) followed by the set of privileged tests
		# (run as root). Otherwise, we delegate GTEST_FILTER (as
		# environment variable) and pass GTEST_ARGS as argument to a
		# single, privileged invocation of the unit tests binary; while
		# this might lead to tests running with excess privileges, it
		# is necessary in order to be able to run every test, including
		# those that need to be run with root privileges.
		if [[ -z ${GTEST_ARGS} && -z ${GTEST_FILTER} ]]; then
			PATH="${testpath}" \
				"./${unittests_binary}" --gtest_filter='-*.RunAsRoot*' \
				&& einfo "./${unittests_binary} (unprivileged) succeeded" \
				|| die "./${unittests_binary} (unprivileged) failed, retval=$?"
			sudo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" PATH="${testpath}" \
				"./${unittests_binary}" --gtest_filter='*.RunAsRoot*' \
				&& einfo "./${unittests_binary} (root) succeeded" \
				|| die "./${unittests_binary} (root) failed, retval=$?"
		else
			sudo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" PATH="${testpath}" \
				GTEST_FILTER="${GTEST_FILTER}" \
				"./${unittests_binary}" ${GTEST_ARGS} \
				&& einfo "./${unittests_binary} succeeded" \
				|| die "./${unittests_binary} failed, retval=$?"
		fi
	fi
}

src_install() {
	dosbin update_engine
	dobin update_engine_client

	use delta_generator && dobin delta_generator

	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	insinto /usr/include/chromeos/update_engine
	doins update_engine.dbusserver.h
	doins update_engine.dbusclient.h

	insinto /etc/init
	doins init/update-engine.conf
}
