# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="1b98196cb788cc9dce2122596c7a1a226c9a02bc"
CROS_WORKON_TREE="27b1d615dd6498d09096be733bb6ebe70933f0bf"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="psyche"

inherit cros-workon platform

DESCRIPTION="Client library for service registration and lookup"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	brillo-base/libprotobinder
	chromeos-base/libchrome
	dev-libs/protobuf
"
DEPEND="${RDEPEND}"

# Daemons that use libpsyche need psyched to be running, but we can't use
# RDEPEND since it'll cause a circular dependency. See
# http://devmanual.gentoo.org/general-concepts/dependencies/.
PDEPEND="brillo-base/psyche"

src_compile() {
	platform compile libpsyche
}

src_install() {
	./preinstall.sh "${OUT}"
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/*.pc

	dolib.so "${OUT}"/lib/libpsyche.so

	insinto /usr/include/psyche
	doins libpsyche/psyche_connection.h
}
