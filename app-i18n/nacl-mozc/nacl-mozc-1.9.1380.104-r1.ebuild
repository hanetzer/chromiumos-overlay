# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
DESCRIPTION="The Mozc engine for IME extension API"
HOMEPAGE="http://code.google.com/p/mozc"
SRC_URI="gs://chromeos-localmirror-private/distfiles/nacl-mozc-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
RESTRICT="mirror"

src_prepare() {
	# Removes unused NaCl binaries.
	if ! use arm ; then
		rm nacl_session_handler_arm.nexe || die
	fi
	if ! use x86 ; then
		rm nacl_session_handler_x86_32.nexe || die
	fi
	if ! use amd64 ; then
		rm nacl_session_handler_x86_64.nexe || die
	fi
}

src_install() {
	insinto /usr/share/chromeos-assets/input_methods/nacl_mozc
	doins -r *
}
