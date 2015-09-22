# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="bc80c40dcf52fc8b267c701ef60e839baa944a3d"
CROS_WORKON_TREE="4a7fd33f888e5411b092007436f49f23249e8f16"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="libbrillobinder"

inherit cros-workon platform

DESCRIPTION="Lib that provides binder IPC"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	./preinstall.sh "${OUT}"
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/*.pc

	dolib.so "${OUT}/lib/libbrillobinder.so"

	insinto /usr/include/brillobinder
	doins binder_manager.h
	doins parcel.h
	doins binder_proxy.h
	doins binder_host.h
	doins ibinder.h
	doins iservice_manager.h
	doins binder_proxy_interface_base.h
	doins iinterface.h
}
