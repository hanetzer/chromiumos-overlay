# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a41a2e70fea956b97e4e2327b424be0708c49420"
CROS_WORKON_PROJECT="chromium/src/base"

inherit cros-workon cros-debug toolchain-funcs scons-utils

DESCRIPTION="Chrome base/ library extracted for use on Chrome OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host"

RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/nss
	x11-libs/gtk+"
DEPEND="${RDEPEND}
	dev-cpp/gtest
	cros_host? ( dev-util/scons )"

src_prepare() {
	ln -s "${S}" "${WORKDIR}/base" &> /dev/null

	mkdir -p "${WORKDIR}/build"
	cp -p "${FILESDIR}/build_config.h" "${WORKDIR}/build/." || die

	cp -p "${FILESDIR}/SConstruct" "${S}" || die
	epatch "${FILESDIR}"/gtest_include_path_fixup.patch

	epatch "${FILESDIR}"/base-85268-DispatchToMethod-unused.patch
	epatch "${FILESDIR}"/base-85268-ThreadRestrictions-unused.patch
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	escons
}

src_install() {
	dolib.a libbase.a

	local d header_dirs=(
		third_party/icu
		third_party/nspr
		third_party/valgrind
		third_party/dynamic_annotations
		.
		debug
		json
		memory
		synchronization
		threading
	)
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/base/${d}
		doins ${d}/*.h
	done

	insinto /usr/include/build
	doins "${WORKDIR}"/build/build_config.h

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${FILESDIR}"/libchrome.pc
}
