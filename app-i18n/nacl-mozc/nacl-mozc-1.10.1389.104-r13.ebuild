# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
inherit eutils

DESCRIPTION="The Mozc engine for IME extension API"
HOMEPAGE="http://code.google.com/p/mozc"
S="${WORKDIR}"
SRC_URI="!internal? ( http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/nacl-mozc-${PV}.tgz )
internal? ( gs://chromeos-localmirror-private/distfiles/nacl-mozc-1.12.1577.4.tgz )"

LICENSE="BSD-google"
IUSE="internal"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
RESTRICT="mirror"

src_prepare() {
	cd ${PN}-*/ || die

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

	# Inserts the public key to manifest.json.
	# The key is used to execute NaCl Mozc as a component extension.
	if use internal; then
		# NaCl Mozc is handled as id:fpfbhcjppmaeaijcidgiibchfbnhbelj.
		epatch "${FILESDIR}"/nacl-mozc-1.12.1577.4-insert-internal-public-key.patch
		epatch "${FILESDIR}"/nacl-mozc-1.12.1577.4-call-startIme.patch
	else
		# NaCl Mozc is handled as id:bbaiamgfapehflhememkfglaehiobjnk.
		epatch "${FILESDIR}"/${P}-insert-oss-public-key.patch
	fi
}

src_install() {
	cd ${PN}-*/ || die

	insinto /usr/share/chromeos-assets/input_methods/nacl_mozc
	doins -r *
}
