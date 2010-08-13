# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

# added eutils to patch
inherit toolchain-funcs eutils

DESCRIPTION="O3D Plugin"
HOMEPAGE="http://code.google.com/p/o3d/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-svn-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~arm"
IUSE="opengl opengles"
DEPEND="dev-libs/nss
	media-libs/fontconfig
	opengl? ( media-libs/glew )
	net-misc/curl
	opengles? ( virtual/opengles )
	x11-libs/cairo
	x11-libs/gtk+"
RDEPEND="${DEPEND}"
O3D_REVISION=53574

set_build_defines() {
	# Prevents gclient from updating self.
	export DEPOT_TOOLS_UPDATE=0
	export EGCLIENT="${EGCLIENT:-/home/$(whoami)/depot_tools/gclient}"
}

src_prepare() {
	set_build_defines

	# Patch sent upstream - http://codereview.chromium.org/2943013/show
	# TODO(piman): Remove when committed.
	pushd native_client
	epatch "${FILESDIR}"/nacl_arm.patch
	popd

	export GYP_GENERATORS=make
	# TODO zhurunz: support x64 later.
	if use x86; then
		# TODO(piman): switch to GL backend
		GYP_DEFINES="target_arch=ia32";
	else
		GYP_DEFINES="target_arch=arm renderer=gles2"
		if use opengles; then
			GYP_DEFINES="$GYP_DEFINES gles2_backend=native_gles2"
		else
			GYP_DEFINES="$GYP_DEFINES gles2_backend=desktop_gl"
		fi
	fi
	export GYP_DEFINES="$GYP_DEFINES chromeos=1 $BUILD_DEFINES"

	${EGCLIENT} runhooks
}

src_compile() {
	# Config
	if tc-is-cross-compiler ; then
		tc-export AR AS LD NM RANLIB CC CXX

		export SYSROOT="${ROOT}"
		export CPPPATH="${ROOT}/usr/include/"
		export LIBPATH="${ROOT}/usr/lib/"
		export RPATH="${ROOT}/usr/lib/"
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
	fi

	emake BUILDTYPE=Release npo3dautoplugin -k

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
}
