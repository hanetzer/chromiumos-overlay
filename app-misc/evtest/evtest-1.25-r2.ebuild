# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit base autotools

DESCRIPTION="Test program for capturing input device events"
HOMEPAGE="http://people.freedesktop.org/~whot/evtest/"
SRC_URI="http://cgit.freedesktop.org/~whot/evtest/snapshot/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"

DEPEND="dev-libs/libxml2
        dev-libs/libxslt
        app-text/xmlto
        app-text/asciidoc"

RDEPEND="dev-libs/libxml2"

UPSTREAMED_PATCHES=(
	"${FILESDIR}/0001-evtest-capture-0-is-a-valid-fd.patch"
	"${FILESDIR}/0002-evtest-capture-on-EINTR-just-continue.patch"
	"${FILESDIR}/0003-evtest-1.26.patch"
	"${FILESDIR}/0004-Add-ABS_MT_PRESSURE-and-ABS_MT_SLOT.patch"
	"${FILESDIR}/0005-Remove-trailing-whitespaces.patch"
	"${FILESDIR}/0006-Add-autogen.sh-for-one-less-buildstep.patch"
	"${FILESDIR}/0007-Print-bytes-received-and-expected-on-read-error.patch"
	"${FILESDIR}/0008-Add-syns-array-for-various-sync-messages.patch"
	"${FILESDIR}/0009-Move-event-time-printing-out-to-deduplicate.patch"
	"${FILESDIR}/0010-De-duplicate-event-code-value-printing.patch"
	"${FILESDIR}/0011-Print-MT-sync-events-differently-to-SYN_REPORT.patch"
	"${FILESDIR}/0012-Change-kernel-version-check-to-simple-ifdefs-for-MT-.patch"
	"${FILESDIR}/0013-Add-KEY_RFKILL-to-keys-database.patch"
	"${FILESDIR}/0014-Add-KEY_WPS_BUTTON-to-keys-database.patch"
	"${FILESDIR}/0015-Add-touchpad-toggle-keys-to-keys-database.patch"
	"${FILESDIR}/0016-Move-the-button-assignments-down-in-the-array-for-ea.patch"
	"${FILESDIR}/0017-Add-Trigger-Happy-buttons-to-key-database.patch"
)

PATCHES=(
	"${UPSTREAMED_PATCHES[@]}"
	"${FILESDIR}/0018-Add-support-for-EV_SW.patch"
)

src_prepare() {
        base_src_prepare
        eautoreconf || die "Autoreconf failed"
}

src_install() {
        emake DESTDIR="${D}" install || die "Install failed"
}
