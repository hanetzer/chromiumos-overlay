# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome base library"
HOMEPAGE="http://src.chromium.org"
#SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
#IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	local third_party="${CHROMEOS_ROOT}/src/third_party/"
	elog "Using third_party: $third_party"
	mkdir -p "${S}"
	cp -a "${third_party}"/chrome/* "${S}" || die
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	scons || die "third_party/chrome compile failed."
}

src_install() {
	dodir "/usr/lib"
	dodir "/usr/include/base"
	dodir "/usr/include/base/third_party/icu"
	dodir "/usr/include/base/third_party/nspr"
	dodir "/usr/include/base/third_party/valgrind"
	dodir "/usr/include/build"

	insopts -m0644
	insinto "/usr/lib"
	doins "${S}/libbase.a"

	insinto "/usr/include/base/third_party/icu"
	doins "${S}/files/base/third_party/icu/icu_utf.h"

	insinto "/usr/include/base/third_party/nspr"
	doins "${S}/files/base/third_party/nspr/prtime.h"

	insinto "/usr/include/base/third_party/valgrind"
	doins "${S}/files/base/third_party/valgrind/valgrind.h"

	insinto "/usr/include/base/"
	doins "${S}/files/base/at_exit.h"
	doins "${S}/files/base/atomicops.h"
	doins "${S}/files/base/atomicops_internals_arm_gcc.h"
	doins "${S}/files/base/atomicops_internals_x86_gcc.h"
	doins "${S}/files/base/base_switches.h"
	doins "${S}/files/base/basictypes.h"
	doins "${S}/files/base/command_line.h"
	doins "${S}/files/base/compiler_specific.h"
	doins "${S}/files/base/debug_util.h"
	doins "${S}/files/base/dynamic_annotations.h"
	doins "${S}/files/base/eintr_wrapper.h"
	doins "${S}/files/base/file_descriptor_posix.h"
	doins "${S}/files/base/file_path.h"
	doins "${S}/files/base/file_util.h"
	doins "${S}/files/base/hash_tables.h"
	doins "${S}/files/base/lock.h"
	doins "${S}/files/base/lock_impl.h"
	doins "${S}/files/base/logging.h"
	doins "${S}/files/base/platform_file.h"
	doins "${S}/files/base/platform_thread.h"
	doins "${S}/files/base/port.h"
	doins "${S}/files/base/safe_strerror_posix.h"
	doins "${S}/files/base/scoped_ptr.h"
	doins "${S}/files/base/setproctitle_linux.h"
	doins "${S}/files/base/singleton.h"
	doins "${S}/files/base/stl_util-inl.h"
	doins "${S}/files/base/string16.h"
	doins "${S}/files/base/string_piece.h"
	doins "${S}/files/base/string_util.h"
	doins "${S}/files/base/string_util_posix.h"
	doins "${S}/files/base/time.h"
	doins "${S}/files/base/utf_string_conversion_utils.h"
	doins "${S}/files/base/utf_string_conversions.h"

	insinto "/usr/include/build"
	doins "${S}/files/build/build_config.h"
}

