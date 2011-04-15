# Copyright (C) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=2

KEYWORDS="~arm ~amd64 ~x86"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Disk mounting daemon for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="splitdebug test"

RDEPEND="
	dev-cpp/gflags
	dev-libs/dbus-c++
	dev-libs/glib
"

DEPEND="${RDEPEND}
	chromeos-base/chromeos-chrome
	dev-cpp/gmock
	test? ( dev-cpp/gtest )"

CROS_WORKON_PROJECT="cros-disks"
CROS_WORKON_LOCALNAME="${CROS_WORKON_PROJECT}"

src_compile() {
	tc-export CXX CC OBJCOPY PKG_CONFIG STRIP
	cros-debug-add-NDEBUG
	emake disks || die "failed to make cros-disks"
}

src_install() {
	exeinto /opt/google/cros-disks
	doexe "${S}/build-opt/disks" || die

	# install upstart config file.
	dodir /etc/init
	install --owner=root --group=root --mode=0644 \
		"${S}"/cros-disks.conf "${D}"/etc/init

	# install D-Bus config file.
	dodir /etc/dbus-1/system.d
	install --owner=root --group=root --mode=0644 \
		"${S}"/org.chromium.CrosDisks.conf "${D}"/etc/dbus-1/system.d
}
