# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit toolchain-funcs

DESCRIPTION="GUID partition table maintenance utility"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="sys-libs/e2fsprogs-libs"


# Where is source directory?
SRCPATH=src/third_party/gpt

src_unpack() {
	# We need to build this from our checked out sources, for both host
	# and target. The host environment doesn't know where we are.
	if [ -z "${CHROMEOS_ROOT}" ] ; then
		local CHROMEOS_ROOT=$(eval echo -n ~${SUDO_USER}/trunk)
	fi
	cp -a "${CHROMEOS_ROOT}/${SRCPATH}" "${S}" || die
}

src_compile() {
	tc-getCC
	emake || die "${SRCPATH} compile failed."
}

src_install() {
	mkdir -p "${D}/usr/bin"
	install -m0755 "${S}/gpt" "${D}/usr/bin/"
}
