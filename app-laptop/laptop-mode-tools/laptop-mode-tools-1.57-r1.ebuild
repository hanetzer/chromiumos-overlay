# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="02f8ebfc4915d6c5817818a61a49b98334fe3ec4"

#inherit cros-workon
inherit eutils

DESCRIPTION="Linux kernel laptop_mode user-space utilities"
HOMEPAGE="http://www.samwel.tk/laptop_mode/"
SRC_URI="http://samwel.tk/laptop_mode/tools/downloads/laptop-mode-tools_1.57.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm"

IUSE="-acpi -apm bluetooth -hal -scsi"

DEPEND=""

RDEPEND="sys-apps/ethtool
		acpi? ( sys-power/acpid )
		apm? ( sys-apps/apmd )
		bluetooth? (
			|| (
				net-wireless/bluez
				net-wireless/bluez-utils
			)
		)
		hal? ( sys-apps/hal )
		net-wireless/iw
		scsi? ( sys-apps/sdparm )
		sys-apps/hdparm"

PATCHES=( "0001-Enabled-laptop-mode-power-management-control-of.patch" \
          "0002-Add-config-knob-to-control-syslog-facility.patch" \
          "0003-Add-WiFi-power-management-support.patch" \
          "0005-switch-wifi-support-to-nl80211.patch" \
          "0006-Lower-hard-drive-idle-timeout-to-5-seconds.patch" \
          "0007-Find-ARM-file-system.patch" \
          "0008-Export-PATH-to-which.patch" \
          "0009-only-log-VERBOSE-msgs-to-syslog-when-DEBUG.patch" )

src_unpack() {
	unpack ${A}
      for PATCH in "${PATCHES[@]}"; do
        epatch "${FILESDIR}/$PATCH"
      done
}

src_install() {
	dodir /etc/pm/sleep.d
	cd laptop-mode-tools_1.57
	DESTDIR="${D}" \
		MAN_D="/usr/share/man" \
		INIT_D="none" \
		APM="$(use apm && echo force || echo disabled)" \
		ACPI="$(use acpi && echo force || echo disabled)" \
		PMU="$(use pmu && echo force || echo disabled)" \
		./install.sh || die "Install failed."

	dodoc Documentation/laptop-mode.txt README
	newinitd "${FILESDIR}"/laptop_mode.init-1.4 laptop_mode

	exeinto /etc/pm/power.d
	newexe "${FILESDIR}"/laptop_mode_tools.pmutils laptop_mode_tools

	insinto /etc/udev/rules.d
	doins etc/rules/99-laptop-mode.rules 
}

pkg_postinst() {
	if ! use acpi && ! use apm; then
		ewarn
		ewarn "Without USE=\"acpi\" or USE=\"apm\" ${PN} can not"
		ewarn "automatically disable laptop_mode on low battery."
		ewarn
		ewarn "This means you can lose up to 10 minutes of work if running"
		ewarn "out of battery while laptop_mode is enabled."
		ewarn
		ewarn "Please see /usr/share/doc/${PF}/laptop-mode.txt.gz for further"
		ewarn "information."
		ewarn
	fi
}
