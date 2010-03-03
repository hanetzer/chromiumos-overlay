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
IUSE="opengles"

RDEPEND="dev-libs/libpcre
	dev-libs/protobuf
	dev-cpp/gflags
	dev-cpp/glog
	x11-libs/gtk+
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libX11
	!opengles? ( virtual/opengl )
	opengles? ( x11-drivers/opengles )"
DEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	dev-cpp/gtkmm
	dev-libs/vectormath
	${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform dir: $platform"
	mkdir -p "${S}/window_manager"

	cp -a "${platform}"/window_manager/* "${S}/window_manager" || die
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

	local backend
	if use opengles ; then
		backend=OPENGLES
	else
		backend=OPENGL
	fi

	# TODO: breakpad should have its own ebuild and we should add to
	# hard-target-depends. Perhaps the same for src/third_party/chrome
	# and src/common
	pushd "window_manager"
	scons BACKEND="$backend" wm screenshot || die "window_manager compile failed"
	popd
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}/window_manager/wm" "${D}/usr/bin/chromeos-wm"
	cp "${S}/window_manager/screenshot" "${D}/usr/bin/screenshot"
}
