# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit multilib-minimal

DESCRIPTION="Ebuild for per-sysroot arc-build components."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="android-container-nyc android-container-master-arc-dev"
REQUIRED_USE="^^ ( android-container-nyc android-container-master-arc-dev )"

# The RDEPEND setting reflects what is installed into the SYSROOT.
RDEPEND="!!chromeos-base/arc-build-master
	!!chromeos-base/arc-build-nyc
	!!chromeos-base/arc-build"
DEPEND=""

S=${WORKDIR}
INSTALL_DIR="/opt/google/containers/android"
BIN_DIR="${INSTALL_DIR}/build/bin"
PREBUILT_DIR="${INSTALL_DIR}/usr"
PREBUILT_SRC="${ARC_BASE}/${ARCH}/usr"

multilib_src_compile() {
	cat > pkg-config <<EOF
#!/bin/bash
case \${ABI} in
aarch64|amd64)
	libdir=lib64
	;;
arm|x86)
	libdir=lib
	;;
*)
	echo "Unsupported ABI: \${ABI}" >&2
	exit 1
	;;
esac

PKG_CONFIG_LIBDIR="${SYSROOT}${INSTALL_DIR}/vendor/\${libdir}/pkgconfig"
export PKG_CONFIG_LIBDIR

export PKG_CONFIG_SYSROOT_DIR="${SYSROOT}"

# Portage will get confused and try to "help" us by exporting this.
# Undo that logic.
unset PKG_CONFIG_PATH

exec pkg-config "\$@"
EOF
}

install_pc_file() {
	sed "/^libdir=/s:/lib:/$(get_libdir):" "${PC_SRC_DIR}"/"$1" > "$1" || die
	doins "$1"
}

multilib_src_install() {
	if use android-container-nyc; then
		PC_SRC_DIR="${FILESDIR}/nyc"
	elif use android-container-master-arc-dev; then
		PC_SRC_DIR="${FILESDIR}/master"
	fi

	insinto "${INSTALL_DIR}/vendor/$(get_libdir)/pkgconfig"
	install_pc_file cutils.pc
	install_pc_file expat.pc
	install_pc_file hardware.pc
	install_pc_file pthread-stubs.pc
	install_pc_file sync.pc
	install_pc_file zlib.pc

	exeinto "${BIN_DIR}"
	doexe pkg-config

	dosym "${PREBUILT_SRC}" "${PREBUILT_DIR}"
}
