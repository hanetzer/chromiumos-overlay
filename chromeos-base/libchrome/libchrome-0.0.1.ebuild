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
	mkdir -p "${D}/usr/lib" \
		"${D}/usr/include/base" \
		"${D}/usr/include/base/third_party/icu" \
		"${D}/usr/include/base/third_party/nspr" \
		"${D}/usr/include/build"

	cp "${S}/libbase.a" "${D}/usr/lib"
	cp "${S}/files/base/third_party/icu/icu_utf.h" "${D}/usr/include/base/third_party/icu"
	cp "${S}/files/base/third_party/nspr/prtime.h" "${D}/usr/include/base/third_party/nspr"
	cp "${S}/files/base/at_exit.h" \
		"${S}/files/base/atomicops_internals_x86_gcc.h" \
		"${S}/files/base/base_switches.h" \
		"${S}/files/base/basictypes.h" \
		"${S}/files/base/command_line.h" \
		"${S}/files/base/compiler_specific.h" \
		"${S}/files/base/debug_util.h" \
		"${S}/files/base/dynamic_annotations.h" \
		"${S}/files/base/file_descriptor_posix.h" \
		"${S}/files/base/file_path.h" \
		"${S}/files/base/file_util.h" \
		"${S}/files/base/hash_tables.h" \
		"${S}/files/base/logging.h" \
		"${S}/files/base/platform_file.h" \
		"${S}/files/base/port.h" \
		"${S}/files/base/safe_strerror_posix.h" \
		"${S}/files/base/scoped_ptr.h" \
		"${S}/files/base/setproctitle_linux.h" \
		"${S}/files/base/stl_util-inl.h" \
		"${S}/files/base/string16.h" \
		"${S}/files/base/string_piece.h" \
		"${S}/files/base/string_util.h" \
		"${S}/files/base/string_util_posix.h" \
		"${S}/files/base/time.h" \
		"${S}/files/base/utf_string_conversion_utils.h" \
		"${S}/files/base/utf_string_conversions.h" \
		"${D}/usr/include/base/"

	cp "${S}/files/build/build_config.h" "${D}/usr/include/build"
}

