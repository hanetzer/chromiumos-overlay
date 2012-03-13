# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="51d55aa18d4b8b3b137c69ea2aa7db1a82d52079"
CROS_WORKON_PROJECT="chromium/src/base"
CROS_WORKON_GIT_SUFFIX="-${PV}"

inherit cros-workon cros-debug toolchain-funcs scons-utils

DESCRIPTION="Chrome base/ library extracted for use on Chrome OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="${PV}"
KEYWORDS="amd64 arm x86"
IUSE="cros_host"

RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/nss"
DEPEND="${RDEPEND}
	dev-cpp/gtest
	cros_host? ( dev-util/scons )"

src_prepare() {
	ln -s "${S}" "${WORKDIR}/base" &> /dev/null

	mkdir -p "${WORKDIR}/build"
	cp -p "${FILESDIR}/build_config.h-${SLOT}" "${WORKDIR}/build/build_config.h" || die

	cp -p "${FILESDIR}/SConstruct-${SLOT}" "${S}/SConstruct" || die
	epatch "${FILESDIR}"/gtest_include_path_fixup.patch

	epatch "${FILESDIR}"/base-125070-DispatchToMethod-unused.patch
	epatch "${FILESDIR}"/base-125070-headers.patch
	epatch "${FILESDIR}"/base-85268-ThreadRestrictions-unused.patch
	epatch "${FILESDIR}"/base-125070-no-X.patch
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	BASE_VER=${SLOT} escons
}

src_install() {
	dolib.so libbase*-${SLOT}.so

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
		insinto /usr/include/base-${SLOT}/base/${d}
		doins ${d}/*.h
	done

	insinto /usr/include/base-${SLOT}/build
	doins "${WORKDIR}"/build/build_config.h

	insinto /usr/$(get_libdir)/pkgconfig
	doins libchrome-${SLOT}.pc
}
