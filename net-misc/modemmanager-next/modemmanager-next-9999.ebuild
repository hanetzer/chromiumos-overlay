# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Based on gentoo's modemmanager ebuild

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/modemmanager-next"

inherit eutils autotools cros-workon flag-o-matic udev user

# ModemManager likes itself with capital letters
MY_P=${P/modemmanager/ModemManager}

DESCRIPTION="Modem and mobile broadband management libraries"
HOMEPAGE="http://mail.gnome.org/archives/networkmanager-list/2008-July/msg00274.html"
#SRC_URI not defined because we get our source locally

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~*"
IUSE="-asan -clang doc gobi mbim qmi"
REQUIRED_USE="asan? ( clang )"

RDEPEND=">=dev-libs/glib-2.32
	>=sys-apps/dbus-1.2
	dev-libs/dbus-glib
	net-dialup/ppp
	mbim? ( net-libs/libmbim )
	qmi? ( net-libs/libqmi )
	!net-misc/modemmanager"

DEPEND="${RDEPEND}
	>=sys-fs/udev-147[gudev]
	dev-util/pkgconfig
	dev-util/intltool
	>=dev-util/gtk-doc-1.13
	!net-misc/modemmanager-next-interfaces
	!net-misc/modemmanager"

DOCS="AUTHORS ChangeLog NEWS README"

src_prepare() {
	gtkdocize
	eautopoint
	eautoreconf
	intltoolize --force
}

src_configure() {
	clang-setup-env
	append-flags -Xclang-only=-Wno-unneeded-internal-declaration
	cros-workon_src_configure \
		--with-html-dir="\${datadir}/doc/${PF}/html" \
		$(use_enable {,gtk-}doc) \
		$(use_with mbim) \
		$(use_with qmi)
}

src_test() {
	# TODO(benchan): Run unit tests for non-x86 platforms via qemu.
	[[ "${ARCH}" == "x86" || "${ARCH}" == "amd64" ]] && emake check
}

src_install() {
	default
	# Remove useless .la files
	find "${D}" -name '*.la' -delete

	# Remove the DBus service file generated by Makefile. This file directs DBus
	# to launch the ModemManager process when a DBus call for the ModemManager
	# service is received. We do not want this behaviour.
	find "${D}" -name 'org.freedesktop.ModemManager1.service' -delete

	# Only install plugins for supported modems to conserve space on the
	# root filesystem.
	find "${D}" -name 'libmm-plugin-*.so' ! \( \
		-name 'libmm-plugin-altair-lte.so' -o \
		-name 'libmm-plugin-generic.so' -o \
		-name 'libmm-plugin-gobi.so' -o \
		-name 'libmm-plugin-huawei.so' -o \
		-name 'libmm-plugin-longcheer.so' -o \
		-name 'libmm-plugin-novatel-lte.so' -o \
		-name 'libmm-plugin-samsung.so' -o \
		-name 'libmm-plugin-telit' -o \
		-name 'libmm-plugin-zte.so' \
		\) -delete

	insinto /etc/init
	doins "${FILESDIR}/modemmanager.conf"

	# Override the ModemManager DBus configuration file to constrain how
	# ModemManager exposes its DBus service on Chrome OS.
	insinto /etc/dbus-1/system.d
	doins "${FILESDIR}/org.freedesktop.ModemManager1.conf"

	# Install Chrome OS specific udev rules.
	udev_dorules "${FILESDIR}/52-mm-modem-permissions.rules"
	udev_dorules "${FILESDIR}/77-mm-huawei-configuration.rules"
	exeinto "$(udev_get_udevdir)"
	doexe "${FILESDIR}/mm-huawei-configuration-switch.sh"

	# When built with USE=gobi, override 80-mm-candidate.rules provided by
	# ModemManager with files/80-mm-candidate.rules to work around a race
	# condition between cromo and ModemManager. See
	# files/80-mm_candidate.rules for details.
	#
	# TODO(benchan): Revert it when cromo is deprecated (crbug.com/316744).
	use gobi && udev_dorules "${FILESDIR}/80-mm-candidate.rules"
}

pkg_preinst() {
	# ModemManager is run under the 'modem' user and group on Chrome OS.
	enewuser "modem"
	enewgroup "modem"
}
