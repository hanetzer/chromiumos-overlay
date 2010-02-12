# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS window manager."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="dev-libs/libpcre
	dev-libs/protobuf
	dev-cpp/gflags
	dev-cpp/glog
	media-libs/clutter
	x11-libs/gtk+
	x11-libs/libXcomposite
	x11-libs/libX11"
DEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	dev-libs/vectormath
	${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform dir: $platform"
	mkdir -p "${S}/window_manager"

	cp -a "${platform}"/window_manager/* "${S}/window_manager" || die

	# TODO: This is a quick hack to remove the __arm__ define so that
	# we always build the window_manager using glx. This is so that the
	# generic arm build can go through for now.
	sed -i "s/__arm__/0/g" "${S}/window_manager"/*.cc
	sed -i "s/__arm__/0/g" "${S}/window_manager"/*.h
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

	# TODO: breakpad should have it's own ebuild and we should add to
	# hard-target-depends. Perhaps the same for src/third_party/chrome
	# and src/common
	pushd "window_manager"
	scons wm || die "window_manager compile failed"
	popd
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}/window_manager/wm" "${D}/usr/bin/chromeos-wm"
}
