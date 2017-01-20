# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="264120496730522ef3e5cc60b80a3953af1ac2cc"
CROS_WORKON_TREE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
CROS_WORKON_PROJECT="chromium/src/third_party/hwcplus"
CROS_WORKON_LOCALNAME="../../chromium/src/third_party/hwcplus"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Interface to an Android-like graphics library"
HOMEPAGE="http://chromium.org"

LICENSE="Apache-2.0 BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_prepare() {
	cros-workon_src_prepare
}

src_compile() {
	$(tc-getCC) \
		${CPPFLAGS} \
		${CFLAGS} \
		${LDFLAGS} \
		-DHAL_LIBRARY_PATH2="\"/usr/$(get_libdir)/hwcplus\"" \
		-Iinclude \
		${S}/src/hardware.c \
		${S}/src/hwcplus_util.c \
		-shared \
		-fPIC \
		-o $(cros-workon_get_build_dir)/libhardware.so \
		-ldl \
		|| die

	sed -e "s/@LIBDIR@/$(get_libdir)/" \
		-e "s/@PV@/${PV}/" \
		"${FILESDIR}/hwcplus.pc.in" > $(cros-workon_get_build_dir)/hwcplus.pc
}

src_install() {
	local i
	for i in android cutils hardware log sync system vendor; do
		insinto "/usr/include/hwcplus/${i}"
		doins "${S}/include/${i}/"*.h
	done

	cd $(cros-workon_get_build_dir)

	dolib.so libhardware.so

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins hwcplus.pc
}
