# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Ebuild for per-sysroot arc-build components."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="!!chromeos-base/arc-build"
RDEPEND=""

S=${WORKDIR}
INSTALL_DIR="/opt/google/containers/android"
BIN_DIR="${INSTALL_DIR}/build/bin"
PC_DIR="${INSTALL_DIR}/vendor/lib/pkgconfig"
PREBUILT_DIR="${INSTALL_DIR}/usr"
PREBUILT_SRC="/opt/android-n/${ARCH}/usr"

src_compile() {
	cat > pkg-config <<EOF
#!/bin/bash

PKG_CONFIG_LIBDIR="${SYSROOT}${PC_DIR}"
export PKG_CONFIG_LIBDIR

export PKG_CONFIG_SYSROOT_DIR="${SYSROOT}"

# Portage will get confused and try to "help" us by exporting this.
# Undo that logic.
unset PKG_CONFIG_PATH

exec pkg-config "\$@"
EOF
}

src_install() {
	insinto "${PC_DIR}"
	doins "${FILESDIR}"/cutils.pc
	doins "${FILESDIR}"/expat.pc
	doins "${FILESDIR}"/hardware.pc
	doins "${FILESDIR}"/pthread-stubs.pc
	doins "${FILESDIR}"/sync.pc
	doins "${FILESDIR}"/zlib.pc

	exeinto "${BIN_DIR}"
	doexe pkg-config

	dosym "${PREBUILT_SRC}" "${PREBUILT_DIR}"
}
