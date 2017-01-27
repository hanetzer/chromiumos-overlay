# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils systemd udev

DESCRIPTION="Linux kernel laptop_mode user-space utilities"
HOMEPAGE="http://www.samwel.tk/laptop_mode/"
SRC_URI="http://samwel.tk/laptop_mode/tools/downloads/laptop-mode-tools_1.59.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="-acpi -apm bluetooth -hal -pmu -scsi systemd wifi_force_powersave"

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
          "0008-Export-PATH-to-which.patch" \
          "0009-only-log-VERBOSE-msgs-to-syslog-when-DEBUG.patch" \
          "0012-Skip-failed-globs-when-finding-module-scripts.patch" \
          "0013-wireless-power-can-not-find-iwconfig-but-tries-to-po.patch" \
          "0014-Disable-ethernet-control.patch" \
          "0015-Disable-file-system-remount.patch" \
          "0016-Wait-for-laptop_mode-using-shell-commands.patch" \
          "0017-usb-autosuspend-black-whitelist-in-quotes.patch" \
          "0018-hdparm-check-for-valid-drive.patch" \
          "0019-board-specific-configurations.patch" \
          "0020-hdparm-skips-SSDs-for-power-management.patch" \
          "0021-alternate-config-dir.patch" \
          "0022-interactive-governor-parameters.patch" \
          "0023-disable-cpufreq-frequency-control.patch" \
          "0024-check-for-existence-of-alarm-file.patch" \
          "0025-add-blacklists-for-runtime-pm.patch" \
          "0026-wait-lock-for-30-seconds.patch" \
          "0027-ac-supply-not-battery.patch" \
          "0028-usb-autosuspend-on-ac.patch" \
          "0029-Enable-SATA-min_power-on-AC-mode.patch" \
          "0030-Allow-WiFi-PowerSave-Override.patch" \
          "0031-interactive-goverener-parameters-for-hmp-cpus.patch" \
          "0032-lm-1.59-refactor-slow-listed-by-id.patch" \
          "0033-Add-udev-rule-for-WiFi-devices.patch" \
          "0034-wireless-power-disable-module.patch" \
          "0035-disable-usb-autosuspend-and-runtime-pm.patch" \
        )

src_prepare() {
	cd "${WORKDIR}"
	for p in "${PATCHES[@]}"; do
		epatch "${FILESDIR}/${p}"
	done
}

src_install() {
	local ignore="laptop-mode nmi-watchdog"

	dodir /etc/pm/sleep.d

	for module in ${ignore}; do
		rm usr/share/laptop-mode-tools/modules/${module}
	done

	DESTDIR="${D}" \
		MAN_D="/usr/share/man" \
		INIT_D="none" \
		APM="$(use apm && echo force || echo disabled)" \
		ACPI="$(use acpi && echo force || echo disabled)" \
		PMU="$(use pmu && echo force || echo disabled)" \
		./install.sh || die "Install failed."

	dodoc Documentation/laptop-mode.txt README

	udev_dorules etc/rules/99-laptop-mode.rules
	rm "${D}"/etc/udev/rules.d/99-laptop-mode.rules || die

	insinto /etc/laptop-mode/conf.d/board-specific
	if use wifi_force_powersave ; then
		doins "${FILESDIR}/wifi-force-powersave.conf"
	fi

	# Install init scripts.
	if use systemd; then
		systemd_dounit "${FILESDIR}"/*.service
		systemd_dotmpfilesd "${FILESDIR}"/laptop-mode-boot-directories.conf
		systemd_enable_service system-services.target laptop-mode-boot.service
		systemd_enable_service suspend.target laptop-mode-resume.service
	else
		insinto /etc/init
		doins "${FILESDIR}"/laptop-mode-boot.conf
		doins "${FILESDIR}"/laptop-mode-resume.conf
	fi
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
