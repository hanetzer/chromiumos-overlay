# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
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
IUSE="opengl opengles"
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
	export GYP_DEFINES="$GYP_DEFINES chromeos=1 $BUILD_DEFINES"
	epatch ${FILESDIR}/${P}-pkgconfig.patch || die
	epatch ${FILESDIR}/${P}-disable-gconf.patch || die
	epatch ${FILESDIR}/${P}-linux3.patch || die
	${EGCLIENT} runhooks || die
}

src_compile() {
	if use arm; then
		append-cflags "-Wa,-mimplicit-it=always"
		append-cxxflags "-Wa,-mimplicit-it=always"
	fi

	append-cxxflags $(test-flags-CC -Wno-error=unused-but-set-variable)

	# Config
	if tc-is-cross-compiler ; then
		tc-export AR AS LD NM RANLIB CC CXX

		export SYSROOT="${ROOT}"
		export CPPPATH="${ROOT}/usr/include/"
		export LIBPATH="${ROOT}/usr/lib/"
		export RPATH="${ROOT}/usr/lib/"
	fi

	emake BUILDTYPE=Release npo3dautoplugin

	mkdir -p "${S}/opt/google/o3d" \
		|| die "Cannot create ${S}/opt/google/o3d"
	if use x86; then
		mkdir -p "${S}/opt/google/o3d/lib" \
			|| die "Cannot create ${S}/opt/google/o3d/lib"
		cp -f out/Release/libCg.so \
			"${S}/opt/google/o3d/lib/libCg.so" \
			|| die "Cannot install file: $!"
		cp -f out/Release/libCgGL.so \
			"${S}/opt/google/o3d/lib/libCgGL.so" \
			|| die "Cannot install file: $!"
	fi
	cp -f out/Release/libnpo3dautoplugin.so \
		"${S}/opt/google/o3d/libnpo3dautoplugin.so" \
		|| die "Cannot install file: $!"
}

src_install() {
	local destdir=/opt/google/o3d
	local chromepluginsdir=/opt/google/chrome/plugins
	dodir $destdir
	exeinto $destdir
	doexe opt/google/o3d/libnpo3dautoplugin.so \
		|| die "Cannot not copy file: $!";
	dodir $chromepluginsdir
	dosym /opt/google/o3d/libnpo3dautoplugin.so $chromepluginsdir/ \
		|| die "Cannot symlink file: $!"
	if use x86; then
		exeinto $destdir/lib
		doexe opt/google/o3d/lib/libCgGL.so
		doexe opt/google/o3d/lib/libCg.so
	fi

	# Only O2D currently works on ARM, so we include an envvars file
	# that forces O2D mode.
	if use arm; then
		insinto $destdir
		newins ${FILESDIR}/envvars.arm envvars
	fi
}
