# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

# added eutils to patch
inherit toolchain-funcs eutils flag-o-matic

DESCRIPTION="O3D Plugin"
HOMEPAGE="http://code.google.com/p/o3d/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-svn-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="aura opengl opengles"
DEPEND="dev-libs/nss
	media-libs/fontconfig
	opengl? ( media-libs/glew )
	net-misc/curl
	opengles? ( virtual/opengles )
	x11-libs/cairo
	x11-libs/gtk+"
RDEPEND="${DEPEND}"

set_build_defines() {
	# Prevents gclient from updating self.
	export DEPOT_TOOLS_UPDATE=0
	export EGCLIENT="${EGCLIENT:-/home/$(whoami)/depot_tools/gclient}"
}

src_prepare() {
	set_build_defines

	if use x86; then
		# TODO(piman): switch to GLES backend
		GYP_DEFINES="target_arch=ia32";
	elif use arm; then
		GYP_DEFINES="target_arch=arm renderer=gles2"
		if use opengles; then
			GYP_DEFINES="$GYP_DEFINES gles2_backend=native_gles2"
		else
			GYP_DEFINES="$GYP_DEFINES gles2_backend=desktop_gl"
		fi
	elif use amd64; then
		GYP_DEFINES="target_arch=x64"
	else
		die "unsupported arch: ${ARCH}"
	fi
	if [[ -n "${ROOT}" && "${ROOT}" != "/" ]]; then
		GYP_DEFINES="$GYP_DEFINES sysroot=$ROOT"
	fi
	if use aura; then
		GYP_DEFINES="$GYP_DEFINES plugin_interface=ppapi p2p_apis=0 os_posix=1"
	fi
	export GYP_DEFINES="$GYP_DEFINES chromeos=1 $BUILD_DEFINES"

	epatch "${FILESDIR}"/${P}-disable-gconf.patch
	epatch "${FILESDIR}"/${P}-linux3.patch
	epatch "${FILESDIR}"/${P}-glibc.patch
	pushd breakpad
	epatch "${FILESDIR}"/0001-Remove-curl-types.h-include-since-this-header-has-be.patch
	popd

	${EGCLIENT} runhooks || die
}

src_compile() {
	use arm && append-flags -Wa,-mimplicit-it=always
	append-cxxflags $(test-flags-CC -Wno-error=unused-but-set-variable)
	tc-export AR AS LD NM RANLIB CC CXX STRIP

	if use aura; then
		emake BUILDTYPE=Release ppo3dautoplugin || die
	else
		emake BUILDTYPE=Release npo3dautoplugin || die
	fi
}

src_install() {
	local destdir=/opt/google/o3d
	local chromepluginsdir=/opt/google/chrome/plugins
	local chromepepperdir=/opt/google/chrome/pepper

	dodir ${destdir}
	exeinto ${destdir}
	if use aura; then
		doexe out/Release/libppo3dautoplugin.so || die
		dodir ${chromepepperdir}
		dosym ${destdir}/libppo3dautoplugin.so ${chromepepperdir}/ || die
	else
		doexe out/Release/libnpo3dautoplugin.so || die
		dodir ${chromepluginsdir}
		dosym ${destdir}/libnpo3dautoplugin.so ${chromepluginsdir}/ || die
		if use amd64 || use x86; then
			dodir ${destdir}/lib
			exeinto ${destdir}/lib
			doexe out/Release/libCg{,GL}.so || die
		elif use arm; then
			# Only O2D currently works on ARM, so we include an envvars
			# file that forces O2D mode.
			insinto ${destdir}
			newins "${FILESDIR}"/envvars.arm envvars || die
		fi
	fi

}
