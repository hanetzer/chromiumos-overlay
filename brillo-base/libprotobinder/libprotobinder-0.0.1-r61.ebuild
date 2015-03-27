# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="84ae26bb4835f2d0f8238719e643e068d9f5c8c9"
CROS_WORKON_TREE="5adb3696ee14315e3fad140e587d69dfa9604b66"
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
	chromeos-base/libchromeos
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

	if use test ; then
		dobin "${OUT}/ping-client"
		dobin "${OUT}/ping-daemon"
	fi

	insinto /usr/include/protobinder
	doins binder_daemon.h
	doins binder_host.h
	doins binder_manager.h
	doins binder_proxy_interface_base.h
	doins binder_proxy.h
	doins ibinder.h
	doins iinterface.h
	doins iservice_manager.h
	doins parcel.h
	doins protobinder.h
}
