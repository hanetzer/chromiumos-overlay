# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="O3D Plugin"
HOMEPAGE="http://code.google.com/p/o3d/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86"
IUSE=""
DEPEND="media-libs/glew
        media-libs/fontconfig
        net-misc/curl
        dev-libs/nss
        x11-libs/libsvg-cairo
        x11-libs/gtk+"
RDEPEND="${DEPEND}"
O3D_REVISION=48537

# Print the number of jobs from $MAKEOPTS.
print_num_jobs() {
	local JOBS=$(echo $MAKEOPTS | sed -nre 's/.*-j\s*([0-9]+).*/\1/p')
	echo ${JOBS:-1}
}


src_compile() {
        # How to build O3D
	elog "http://code.google.com/p/o3d/wiki/HowToBuild"

        export EGCLIENT="${EGCLIENT:-/home/$(whoami)/depot_tools/gclient}"

        # Use customized gclient config file
        mkdir -p O3D || die "Cannot create O3D folder"
        cd O3D
        cp -f "${FILESDIR}/plugin-only.gclient" .gclient

        # Config
        if tc-is-cross-compiler ; then
                tc-export AR AS LD NM RANLIB CC CXX

                export SYSROOT="${ROOT}"
                export CPPPATH="${ROOT}/usr/include/"
                export LIBPATH="${ROOT}/usr/lib/"
                export RPATH="${ROOT}/usr/lib/"
                export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
        fi

        # Make O3D plugin
        export GYP_GENERATORS=make
        # TODO zhurunz: support ARM and x64 later.
        export GYP_DEFINES="target_arch=ia32";
        ${EGCLIENT} sync --revision o3d@${O3D_REVISION}
        make BUILDTYPE=Release npo3dautoplugin -k -j $(print_num_jobs)

        mkdir -p "${WORKDIR}/opt/google/o3d" \
          || die "Cannot create ${WORKDIR}/opt/google/o3d"
        mkdir -p "${WORKDIR}/opt/google/o3d/lib" \
          || die "Cannot create ${WORKDIR}/opt/google/o3d/lib"
        cp -f out/Release/libCg.so \
          "${WORKDIR}/opt/google/o3d/lib/libCg.so" \
          || die "Cannot install file: $!"
        cp -f out/Release/libCgGL.so \
          "${WORKDIR}/opt/google/o3d/lib/libCgGL.so" \
          || die "Cannot install file: $!"
        cp -f out/Release/libnpo3dautoplugin.so \
          "${WORKDIR}/opt/google/o3d/libnpo3dautoplugin.so" \
          || die "Cannot install file: $!"
}


src_install() {
	local destdir=/opt/google/o3d
	local chromepluginsdir=/opt/google/chrome/plugins
	dodir $destdir
	exeinto $destdir
	doexe opt/google/o3d/libnpo3dautoplugin.so || die "Cannot not copy file: $!";
	dodir $chromepluginsdir
	dosym /opt/google/o3d/libnpo3dautoplugin.so $chromepluginsdir/ || die "Cannot symlink file: $!"
	exeinto $destdir/lib
	doexe opt/google/o3d/lib/libCgGL.so
	doexe opt/google/o3d/lib/libCg.so

}
