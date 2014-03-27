# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez/bluez-4.99.ebuild,v 1.7 2012/04/15 16:53:41 maekke Exp $

EAPI="4"
PYTHON_DEPEND="test-programs? 2"

# Inherit from cros-board so that bluez is built for each board, rather than
# shared; this is because it uses overlay-defined CHROMEOS_BLUETOOTH_VENDORID,
# CHROMEOS_BLUETOOTH_PRODUCTID and CHROMEOS_BLUETOOTH_VERSION variables to
# define the exported Device ID.
inherit autotools multilib eutils systemd python cros-board

DESCRIPTION="Bluetooth Tools and System Daemons for Linux"
HOMEPAGE="http://www.bluez.org/"
SRC_URI="mirror://kernel/linux/bluetooth/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~*"
IUSE="cups debug test-programs usb readline"

CDEPEND="
	>=dev-libs/glib-2.14:2
	sys-apps/dbus
	>=sys-fs/udev-169
	cups? ( net-print/cups )
	usb? ( virtual/libusb:0 )
	readline? ( sys-libs/readline )
"
DEPEND="${CDEPEND}
	>=dev-util/pkgconfig-0.20
	sys-devel/flex
	test-programs? ( >=dev-libs/check-0.9.8 )
"
RDEPEND="${CDEPEND}
	!net-wireless/bluez-hcidump
	!net-wireless/bluez-libs
	!net-wireless/bluez-test
	!net-wireless/bluez-utils
	test-programs? (
		dev-python/dbus-python
		dev-python/pygobject:2
	)
"

DOCS=( AUTHORS ChangeLog README )

# Version of the Chrome OS Bluetooth stack when this ebuild is used;
# CHROMEOS_BLUETOOTH_VENDORID and CHROMEOS_BLUETOOTH_PRODUCTID must be
# defined elsewhere for this to be used instead of the BlueZ version.
: ${CHROMEOS_BLUETOOTH_VERSION:="0400"}

pkg_setup() {
	if use test-programs; then
		python_pkg_setup
	fi
}

src_prepare() {
	# Change the default D-Bus configuration; the daemon is run as
	# bluetooth, not root; we don't use the lp user, and we use the
	# chronos user instead of at_console
	epatch "${FILESDIR}/${P}-dbus.patch"

	# Change the default SDP Server socket path to a sub-directory
	# under /var/run, since /var/run is not writeable by the bluetooth
	# user.
	epatch "${FILESDIR}/${P}-sdp-path.patch"

	# Playstation3 Controller pairing plugin, retrieved from
	# linux-bluetooth mailing list (posted 2012-04-18).
	#epatch "${FILESDIR}/${P}-ps3-0001.patch"
	#epatch "${FILESDIR}/${P}-ps3-0002.patch"
	#epatch "${FILESDIR}/${P}-ps3-0003.patch"

	# Make the Powered property persistent across reboots, this
	# was removed from upstream BlueZ in favor of using a connection
	# manager to deal with powering up/down the adapter. We restore
	# the patch rather than deal with Shill ;)
	epatch "${FILESDIR}/${P}-persist-powered.patch"

	# Move the btmgmt tool out from behind the --enable-experimental
	# flag so that we can install it.
	epatch "${FILESDIR}/${P}-btmgmt.patch"

	eautoreconf

	if use cups; then
		sed -i \
			-e "s:cupsdir = \$(libdir)/cups:cupsdir = `cups-config --serverbin`:" \
			Makefile.tools Makefile.in || die
	fi
}

src_configure() {
	use readline || export ac_cv_header_readline_readline_h=no

	econf \
		--enable-tools \
		--localstatedir=/var \
		$(use_enable cups) \
		--enable-datafiles \
		$(use_enable debug) \
		$(use_enable test-programs test) \
		$(use_enable usb) \
		--enable-library \
		--disable-systemd \
		--disable-obex
}

src_install() {
	default

	if use test-programs ; then
		cd "${S}/test"
		dobin simple-agent simple-endpoint simple-player simple-service
		dobin monitor-bluetooth
		newbin list-devices list-bluetooth-devices
		local b
		for b in test-* ; do
			newbin "${b}" "bluez-${b}"
		done
		insinto /usr/share/doc/${PF}/test-services
		doins service-*

		python_convert_shebangs -r 2 "${ED}"
		cd "${S}"
	fi

	dobin attrib/gatttool tools/btmgmt

	# Change the Bluetooth Device ID of official products
	if [[ -n "${CHROMEOS_BLUETOOTH_VENDORID}" && -n "${CHROMEOS_BLUETOOTH_PRODUCTID}" ]]; then
		sed -i -e "/^#DeviceID/c\
			DeviceID = bluetooth:${CHROMEOS_BLUETOOTH_VENDORID}:${CHROMEOS_BLUETOOTH_PRODUCTID}:${CHROMEOS_BLUETOOTH_VERSION}" src/main.conf || die
	fi

	insinto /etc/bluetooth
	doins src/main.conf

	insinto /etc/init
	newins "${FILESDIR}/${P}-upstart.conf" bluetoothd.conf

	#insinto /lib/udev/rules.d
	#newins "${FILESDIR}/${PN}-ps3-gamepad.rules" "99-ps3-gamepad.rules"

	# We don't preserve /var/lib in images, so nuke anything we preseed.
	rm -rf "${D}"/var/lib/bluetooth

	rm "${D}/lib/udev/rules.d/97-bluetooth.rules"

	find "${D}" -name "*.la" -delete
}

pkg_postinst() {
	udevadm control --reload-rules && udevadm trigger --subsystem-match=bluetooth

	if ! has_version "net-dialup/ppp"; then
		elog "To use dial up networking you must install net-dialup/ppp."
	fi

	if [ "$(rc-config list default | grep bluetooth)" = "" ] ; then
		elog "You will need to add bluetooth service to default runlevel"
		elog "for getting your devices detected from startup without needing"
		elog "to reconnect them. For that please run:"
		elog "'rc-update add bluetooth default'"
	fi
}
