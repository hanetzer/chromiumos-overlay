# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="385ff01b09d0f070924afea3e90fc6a3994547f4"
CROS_WORKON_TREE="1a2e5d54d84ac8da99690917e75f708592c9b850"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Upstart jobs that will be installed on embedded CrOS images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

DEPEND=""
RDEPEND="${DEPEND}
	sys-apps/rootdev
	sys-apps/upstart
"

src_install() {
	into /	# We want /sbin, not /usr/sbin, etc.

	# Install Upstart configuration files.
	dodir /etc/init
	insinto /etc/init
	doins startup.conf
	doins embedded-init/boot-services.conf
	doins embedded-init/udhcpc.conf

	# TODO(cmasone): Either use getty across the whole source tree, or
	# convince busybox that it can simulate agetty.  Or something.
	# http://crosbug.com/39188
	dosbin embedded-init/agetty

	doins cgroups.conf dbus.conf failsafe-delay.conf failsafe.conf
	doins install-completed.conf ip6tables.conf iptables.conf
	doins pre-shutdown.conf pstore.conf syslog.conf tty2.conf

	# udhcp support
	dosym /var/run/resolv.conf /etc

#	install --owner=root --group=root --mode=0644 \
#		"${S}"/*.conf "${D}/etc/init/"
#	install --owner=root --group=root --mode=0644 \
#		"${S}"/dev-init/*.conf "${D}/etc/init/"
#	install --owner=root --group=root --mode=0644 \
#		"${S}"/test-init/*.conf "${D}/etc/init/"
#	rm ${D}/etc/init/ui.conf
#	rm ${D}/etc/init/udev*.conf

	dodir /etc
	insinto /etc
	doins issue rsyslog.chromeos

	# Install startup/shutdown scripts.
	dosbin "${S}/embedded-init/chromeos_startup"
	dosbin "${S}/embedded-init/chromeos_shutdown"

	# Install log cleaning script and run it daily.
	into /usr
	dosbin chromeos-cleanup-logs
}
