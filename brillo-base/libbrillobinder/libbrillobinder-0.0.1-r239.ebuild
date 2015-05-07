# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="4b62857145d682b4b1d01f602f42f890d9d09671"
CROS_WORKON_TREE="7a5965df3e05f2803e2ff777422ae84995028d08"
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
