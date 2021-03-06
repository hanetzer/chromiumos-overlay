# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/apitrace/apitrace-4.0.ebuild,v 1.1 2014/04/03 18:23:13 vapier Exp $

EAPI="5"
PYTHON_COMPAT=( python2_7 )

inherit cmake-multilib eutils python-single-r1 vcs-snapshot

DESCRIPTION="A tool for tracing, analyzing, and debugging graphics APIs"
HOMEPAGE="https://github.com/apitrace/apitrace"
SRC_URI="https://github.com/${PN}/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="+cli opengl opengles qt4 X"

RDEPEND="${PYTHON_DEPS}
	app-arch/snappy[${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
	opengl? ( virtual/opengl )
	opengles? ( virtual/opengles )
	media-libs/libpng:0=
	sys-process/procps
	X? ( x11-libs/libX11 )
	qt4? (
		>=dev-qt/qtcore-4.7:4
		>=dev-qt/qtgui-4.7:4
		>=dev-qt/qtwebkit-4.7:4
		>=dev-libs/qjson-0.5
	)"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-system-libs.patch
	"${FILESDIR}"/${P}-glxtrace-only.patch
	"${FILESDIR}"/${P}-glext-texture-storage.patch
	"${FILESDIR}"/${P}-glxcopysubbuffermesa.patch
	"${FILESDIR}"/${P}-multilib.patch
	"${FILESDIR}"/${P}-disable-multiarch.patch
	"${FILESDIR}"/${P}-memcpy.patch
	"${FILESDIR}"/${P}-x11-toggle.patch
)

src_prepare() {
	enable_cmake-utils_src_prepare

	# The apitrace code grubs around in the internal zlib structures.
	# We have to extract this header and clean it up to keep that working.
	# Do not be surprised if a zlib upgrade breaks things ...
	sed -r \
		-e 's:OF[(]([^)]*)[)]:\1:' \
		thirdparty/zlib/gzguts.h > gzguts.h
	rm -rf "${S}"/thirdparty/{getopt,less,libpng,snappy,zlib}
}

src_configure() {
	my_configure() {
		mycmakeargs=(
			-DARCH_SUBDIR=
			$(cmake-utils_use_enable opengles EGL)
		)
		if multilib_build_binaries ; then
			mycmakeargs+=(
				$(cmake-utils_use_enable cli CLI)
				$(cmake-utils_use_enable qt4 GUI)
				$(cmake-utils_use_enable X X11)
			)
		else
			mycmakeargs+=(
				-DBUILD_LIB_ONLY=ON
				-DENABLE_CLI=OFF
				-DENABLE_GUI=OFF
			)
		fi
		mycmakeargs+=(
			"-DCMAKE_FIND_ROOT_PATH=${ROOT}"
			"-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER"
			"-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY"
			"-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY"
		)
		cmake-utils_src_configure
	}

	multilib_parallel_foreach_abi my_configure
}

src_install() {
	cmake-multilib_src_install

	dosym glxtrace.so /usr/$(get_libdir)/${PN}/wrappers/libGL.so
	dosym glxtrace.so /usr/$(get_libdir)/${PN}/wrappers/libGL.so.1
	dosym glxtrace.so /usr/$(get_libdir)/${PN}/wrappers/libGL.so.1.2

	dodoc {BUGS,DEVELOPMENT,NEWS,README,TODO}.markdown

	exeinto /usr/$(get_libdir)/${PN}/scripts
	doexe $(find scripts -type f -executable)
}
