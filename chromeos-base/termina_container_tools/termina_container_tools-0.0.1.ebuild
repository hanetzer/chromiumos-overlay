# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cros-constants libchrome

DESCRIPTION="Packages tools for termina VM containers"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}"

RDEPEND=""
DEPEND="
	chromeos-base/vm_guest_tools
	dev-libs/grpc
	dev-libs/protobuf:=
	x11-apps/xkbcomp
	x11-base/xwayland
"

src_install() {
	"${CHROMITE_BIN_DIR}"/lddtree --root="${SYSROOT}" --bindir=/bin \
			--libdir=/lib --generate-wrappers \
			--copy-to-tree="${WORKDIR}"/container_pkg/ \
			/usr/bin/garcon \
			/usr/bin/sommelier \
			/usr/bin/Xwayland \
			/usr/bin/xkbcomp
	insinto /opt/google/cros-containers
	insopts -m0755
	doins -r "${WORKDIR}"/container_pkg/*
}
