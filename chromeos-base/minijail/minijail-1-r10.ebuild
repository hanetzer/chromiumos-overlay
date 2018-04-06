# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="7e33301d2dd20f2db9c227f0fe89e4a3c82350d0"
CROS_WORKON_TREE="21c99a775a5e1649ee1c288132df8eb1e49841c5"
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME="aosp/external/minijail"
CROS_WORKON_PROJECT="platform/external/minijail"
CROS_WORKON_REPO="https://android.googlesource.com"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="helper binary and library for sandboxing & restricting privs of services"
HOMEPAGE="https://android.googlesource.com/platform/external/minijail"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+seccomp test"

RDEPEND="sys-libs/libcap
	!<chromeos-base/chromeos-minijail-1"
DEPEND="test? ( dev-cpp/gtest )
	test? ( dev-cpp/gmock )
	${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	# Only build the tools.
	emake LIBDIR=$(get_libdir) USE_seccomp=$(usex seccomp)
}

src_test() {
	# TODO(crbug.com/689060): Re-enable on ARM.
	if use x86 || use amd64 ; then
		emake USE_SYSTEM_GTEST=yes tests
	fi
}

src_install() {
	into /
	dosbin minijail0
	dolib.so libminijail.so
	dolib.so libminijailpreload.so

	doman minijail0.[15]

	local include_dir="/usr/include/chromeos"

	"${S}"/platform2_preinstall.sh "${PV}" "${include_dir}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libminijail.pc

	insinto "${include_dir}"
	doins libminijail.h
	doins scoped_minijail.h
}
