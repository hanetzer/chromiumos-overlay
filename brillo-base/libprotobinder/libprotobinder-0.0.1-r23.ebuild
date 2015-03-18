# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="e8ff186a1c81b7b7a5fdb95be9af0370091cb7e9"
CROS_WORKON_TREE="48135507ba31eed11d8b6c965d2917165e47ca45"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="libprotobinder"

inherit cros-workon platform

DESCRIPTION="Library to provide Binder IPC."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	!brillo-base/libbrillobinder
"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	./preinstall.sh "${OUT}"
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/*.pc

	dolib.so "${OUT}/lib/libprotobinder.so"

	insinto /usr/include/protobinder
	doins binder_manager.h
	doins parcel.h
	doins binder_proxy.h
	doins binder_host.h
	doins ibinder.h
	doins iservice_manager.h
	doins binder_proxy_interface_base.h
	doins iinterface.h
}
