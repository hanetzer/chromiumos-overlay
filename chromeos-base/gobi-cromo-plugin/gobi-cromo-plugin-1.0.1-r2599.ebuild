# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4
CROS_WORKON_COMMIT="d23e6e4aa0a820b350abb3a77c6f17e28be68d3e"
CROS_WORKON_TREE="c22c8af6c852dc489924b2acf0a9d2533024c2fa"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_USE_VCSID="1"

inherit cros-debug cros-workon libchrome toolchain-funcs multilib

DESCRIPTION="Cromo plugin to control Qualcomm Gobi modems"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="install_tests"

RDEPEND="
	dev-cpp/glog
	dev-libs/dbus-c++
	chromeos-base/cromo
	chromeos-base/gobi3k-sdk
	chromeos-base/gobi3k-lib
	chromeos-base/libbrillo
	chromeos-base/metrics
	install_tests? ( dev-cpp/gmock dev-cpp/gtest )
"
# gtest is needed by non-test builds for gtest_prod.h.
DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	virtual/modemmanager
"

cr_make() {
	emake \
		LIBDIR=/usr/$(get_libdir) \
		$(use install_tests && echo INSTALL_TESTS=1) \
		"$@"
}

src_unpack() {
	cros-workon_src_unpack
	S+="/gobi-cromo-plugin"
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CXX LD CC
	cros-debug-add-NDEBUG
	cr_make plugin
	use test && cr_make tests
}

mkqcqmirules() {
	rule="ACTION==\"add|change\", SUBSYSTEM==\"QCQMI\", KERNEL==\"qcqmi[0-9]*\""
	rule="$rule, OWNER=\"cromo\""
	rule="$rule, GROUP=\"cromo\""
	echo "$rule"
}

src_install() {
	cr_make DESTDIR="${D}" install
	# The qualcomm makefile for gobi-cromo-plugin seems to stick its own
	# rules into this directory, which I don't think is right - I believe
	# /lib/udev/rules.d belongs to udev and /etc/udev/rules.d is for distro
	# stuff. Ah well.
	mkqcqmirules > "${D}/lib/udev/rules.d/76-cromo-gobi-permissions.rules"
}
