# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/hostapd/hostapd-2.1-r1.ebuild,v 1.1 2014/04/16 09:10:54 gurligebis Exp $

EAPI="4"

inherit eutils toolchain-funcs qt3 qt4 user

DESCRIPTION="Linux WPA/WPA2/IEEE 802.1x Supplicant"
HOMEPAGE="http://w1.fi/wpa_supplicant"
SRC_URI="http://w1.fi/releases/${P}.tar.gz"

LICENSE="|| ( GPL-2 BSD )"
SLOT="0"
KEYWORDS="*"
IUSE="dbus debug gnutls eap-sim madwifi ps3 qt3 qt4 readline smartcard ssl +tdls wps kernel_linux kernel_FreeBSD"
REQUIRED_USE="smartcard? ( ssl )"

DEPEND="dev-libs/libnl:0
        chromeos-base/chromeos-minijail
        dbus? ( sys-apps/dbus )
        kernel_linux? (
                eap-sim? ( sys-apps/pcsc-lite )
                madwifi? ( ||
                        ( >net-wireless/madwifi-ng-tools-0.9.3
                        net-wireless/madwifi-old )
                )
        )
        !kernel_linux? ( net-libs/libpcap )
        qt4? ( x11-libs/qt-gui:4
                x11-libs/qt-svg:4 )
        !qt4? ( qt3? ( x11-libs/qt:3 ) )
        readline? ( sys-libs/ncurses sys-libs/readline )
        ssl? ( dev-libs/openssl )
        smartcard? ( dev-libs/engine_pkcs11 )
        !ssl? ( gnutls? ( net-libs/gnutls ) )
        !ssl? ( !gnutls? ( dev-libs/libtommath ) )"
RDEPEND="${DEPEND}"

S="${S}/${PN}"

src_prepare() {
        pushd .. >/dev/null
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-bgscan-Add-centrailized-signal_monitor.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-Accept-raw-PMK-in-new-DBus.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-add-support-for-tx-aborting-a-scan.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-do-not-expire-bss-entries-when-scan-is-aborted.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-bgscan_simple-mark-scans-so-that-tx-will-abort.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-make-bgscan_simple-scan-all-channels.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-improve-roaming-when-noise-floor-available.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-notify-bss-signal-changes.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_debug-add-syslog-support-for-wpa_hexdump_ascii.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-Dont-leak-scan-frequencies.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-disable-the-SessionTicket-extension-in-SSL.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-bgscan_simple-set-maximum-fast-scans.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-Disable-high-bitrates-after-association.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-dbus-new-Adds-roam_threshold-dbus-property.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-improve-BSS-selection.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-Add-support-for-user-configurable-HT40-setting.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-Ignore-driver-s-feature-flag-for-low-priority-scan.patch
        epatch ${FILESDIR}/patches/${P}-UPSTREAM-Invoke-connect-work-done-for-all-connection-failure-cases.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-configure-scheduled-scan-through-DBus.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-configure-scan-through-DBus.patch
        epatch ${FILESDIR}/patches/${P}-UPSTREAM-IBSS-Add-WPA_DRIVER_FLAG_HT_IBSS.patch
        epatch ${FILESDIR}/patches/${P}-UPSTREAM-Retry-scan-for-connect-if-driver-trigger-fails.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-use-critical-protocol.patch
        epatch ${FILESDIR}/patches/${P}-CHROMIUMOS-wpa_supplicant-dbus-signal-on-tdls-discover-response.patch
        epatch ${FILESDIR}/patches/${P}-UPSTREAM-P2P-Validate-SSID-element-length-before-copying-it-C.patch
        epatch ${FILESDIR}/patches/${P}-UPSTREAM-Update-pending-connect-radio-work-BSS-pointer-on-scan-update.patch
	epatch ${FILESDIR}/patches/${P}-UPSTREAM-EAP-pwd-peer-Fix-asymmetric-fragmentation-behavior.patch
	epatch ${FILESDIR}/patches/${P}-UPSTREAM-EAP-pwd-peer-Fix-payload-length-validation-for-Commi.patch
	epatch ${FILESDIR}/patches/${P}-UPSTREAM-EAP-pwd-peer-Fix-Total-Length-parsing-for-fragment-r.patch
	epatch ${FILESDIR}/patches/${P}-UPSTREAM-EAP-pwd-server-Fix-payload-length-validation-for-Com.patch
	epatch ${FILESDIR}/patches/${P}-UPSTREAM-EAP-pwd-server-Fix-Total-Length-parsing-for-fragment.patch
	epatch ${FILESDIR}/patches/${P}-UPSTREAM-AP-WMM-Fix-integer-underflow-in-WMM-Action-frame-par.patch
	epatch ${FILESDIR}/patches/${P}-UPSTREAM-WPS-Fix-HTTP-chunked-transfer-encoding-parser.patch
        popd >/dev/null
}

src_configure() {
        local CFGFILE=${S}/.config

        # Toolchain setup
        echo "CC = $(tc-getCC)" > ${CFGFILE}

        # Build w/ debug symbols
        echo "CFLAGS += -ggdb" >> ${CFGFILE}

        # Basic setup
        echo "CONFIG_CTRL_IFACE=y" >> ${CFGFILE}
        echo "CONFIG_BACKEND=file" >> ${CFGFILE}

        # Basic authentication methods
        # NOTE: These are the options set by the Chromium OS build
        echo "CONFIG_DYNAMIC_EAP_METHODS=y" >> ${CFGFILE}
        echo "CONFIG_IEEE8021X_EAPOL=y" >> ${CFGFILE}
        echo "CONFIG_EAP_MD5=y" >> ${CFGFILE}
        echo "CONFIG_EAP_MSCHAPV2=y" >> ${CFGFILE}
        echo "CONFIG_EAP_TLS=y" >> ${CFGFILE}
        echo "CONFIG_EAP_PEAP=y" >> ${CFGFILE}
        echo "CONFIG_EAP_TTLS=y" >> ${CFGFILE}
        echo "CONFIG_EAP_GTC=y" >> ${CFGFILE}
        echo "CONFIG_EAP_OTP=y" >> ${CFGFILE}
        echo "CONFIG_EAP_LEAP=y" >> ${CFGFILE}
        echo "CONFIG_PKCS12=y" >> ${CFGFILE}
        echo "CONFIG_PEERKEY=y" >> ${CFGFILE}
        echo "CONFIG_BGSCAN_SIMPLE=y" >> ${CFGFILE}
        echo "CONFIG_BGSCAN_LEARN=y" >> ${CFGFILE}
        echo "CONFIG_BGSCAN_DELTA=y" >> ${CFGFILE}
        echo "CONFIG_IEEE80211W=y" >> ${CFGFILE}

        # Allow VHT parameters to be overridden; required by ChromiumOS
        echo "CONFIG_VHT_OVERRIDES=1" >> ${CFGFILE}

        # Allow HT parameters to be overridden; required by ChromiumOS
        echo "CONFIG_HT_OVERRIDES=1" >> ${CFGFILE}

        if use dbus ; then
                echo "CONFIG_CTRL_IFACE_DBUS_NEW=y" >> ${CFGFILE}
                echo "CONFIG_CTRL_IFACE_DBUS_INTRO=y" >> ${CFGFILE}
        fi

        if use debug ; then
                echo "CONFIG_DEBUG_SYSLOG=y" >> ${CFGFILE}
                echo "CONFIG_DEBUG_SYSLOG_FACILITY=LOG_LOCAL6" >> ${CFGFILE}
        fi

        if use eap-sim ; then
                # Smart card authentication
                echo "CONFIG_EAP_SIM=y"       >> ${CFGFILE}
                echo "CONFIG_EAP_AKA=y"       >> ${CFGFILE}
                echo "CONFIG_EAP_AKA_PRIME=y" >> ${CFGFILE}
                echo "CONFIG_PCSC=y"          >> ${CFGFILE}
        fi

        if use readline ; then
                # readline/history support for wpa_cli
                echo "CONFIG_READLINE=y" >> ${CFGFILE}
        fi

        # SSL authentication methods
        if use ssl ; then
                echo "CONFIG_TLS=openssl"    >> ${CFGFILE}
        elif use gnutls ; then
                echo "CONFIG_TLS=gnutls"     >> ${CFGFILE}
                echo "CONFIG_GNUTLS_EXTRA=y" >> ${CFGFILE}
        else
                echo "CONFIG_TLS=internal"   >> ${CFGFILE}
        fi
        if use smartcard ; then
                # REQUIRED_USE ensures that ssl is set too.
                echo "CONFIG_SMARTCARD=y"    >> ${CFGFILE}
        fi
        if use kernel_linux ; then
                # Linux specific drivers
                #echo "CONFIG_DRIVER_ATMEL=y"       >> ${CFGFILE}
                #echo "CONFIG_DRIVER_BROADCOM=y"   >> ${CFGFILE}
                #echo "CONFIG_DRIVER_HERMES=y"     >> ${CFGFILE}
                #echo "CONFIG_DRIVER_HOSTAP=y"      >> ${CFGFILE}
                #echo "CONFIG_DRIVER_IPW=y"         >> ${CFGFILE}
                #echo "CONFIG_DRIVER_NDISWRAPPER=y" >> ${CFGFILE}
                echo "CONFIG_DRIVER_NL80211=y"     >> ${CFGFILE}
                #echo "CONFIG_DRIVER_PRISM54=y"    >> ${CFGFILE}
                #echo "CONFIG_DRIVER_RALINK=y"      >> ${CFGFILE}
                echo "CONFIG_DRIVER_WEXT=y"        >> ${CFGFILE}
                echo "CONFIG_DRIVER_WIRED=y"       >> ${CFGFILE}

                if use madwifi ; then
                        # Add include path for madwifi-driver headers
                        echo "CFLAGS += -I/usr/include/madwifi" >> ${CFGFILE}
                        echo "CONFIG_DRIVER_MADWIFI=y"          >> ${CFGFILE}
                fi

                if use ps3 ; then
                        echo "CONFIG_DRIVER_PS3=y" >> ${CFGFILE}
                fi

        elif use kernel_FreeBSD ; then
                # FreeBSD specific driver
                echo "CONFIG_DRIVER_BSD=y" >> ${CFGFILE}
        fi

        # Wi-Fi Protected Setup (WPS)
        if use wps ; then
                echo "CONFIG_WPS=y" >> ${CFGFILE}
        fi

        # Wi-Fi Tunneled Direct Link Setup (WPS)
        if use tdls ; then
                echo "CONFIG_TDLS=y" >> ${CFGFILE}
        fi

        # Enable mitigation against certain attacks against TKIP
        echo "CONFIG_DELAYED_MIC_ERROR_REPORT=y" >> ${CFGFILE}
}

src_compile() {
        emake V=1

        if use qt4 ; then
                cd "${S}"/wpa_gui-qt4
                eqmake4 wpa_gui.pro
                emake || die "Qt4 wpa_gui compilation failed"
        elif use qt3 ; then
                cd "${S}"/wpa_gui
                eqmake3 wpa_gui.pro
                emake || die "Qt3 wpa_gui compilation failed"
        fi
}

src_install() {
        cd ${S}
        dosbin wpa_supplicant || die
        dobin wpa_cli wpa_passphrase || die

        # baselayout-1 compat
        if has_version "<sys-apps/baselayout-2.0.0"; then
                dodir /sbin
                dosym /usr/sbin/wpa_supplicant /sbin/wpa_supplicant || die
                dodir /bin
                dosym /usr/bin/wpa_cli /bin/wpa_cli || die
        fi

        exeinto /etc/wpa_supplicant/

        if use qt4 ; then
                into /usr
                dobin wpa_gui-qt4/wpa_gui || die
        elif use qt3 ; then
                into /usr
                dobin wpa_gui/wpa_gui || die
        fi

        if use qt3 || use qt4 ; then
                doicon wpa_gui-qt4/icons/wpa_gui.svg || die "Icon not found"
                make_desktop_entry wpa_gui "WPA Supplicant Administration GUI" "wpa_gui" "Qt;Network;"
        fi

        if use dbus ; then
                # DBus introspection XML file.
                insinto /usr/share/dbus-1/interfaces
                doins ${FILESDIR}/dbus_bindings/fi.w1.wpa_supplicant1.xml || die
                insinto /etc/dbus-1/system.d
                doins ${FILESDIR}/dbus_permissions/fi.w1.wpa_supplicant1.conf || die
                keepdir /var/run/wpa_supplicant
        fi

        # install wpa_supplicant's init script
        insinto /etc/init
        doins ${FILESDIR}/init/wpasupplicant.conf
}

pkg_preinst() {
        enewuser "wpa"
        enewgroup "wpa"
}

pkg_postinst() {
        einfo "If this is a clean installation of wpa_supplicant, you"
        einfo "have to create a configuration file named"
        einfo "/etc/wpa_supplicant/wpa_supplicant.conf"
        einfo
        einfo "An example configuration file is available for reference in"
        einfo "/usr/share/doc/${PF}/"

        if [[ -e ${ROOT}etc/wpa_supplicant.conf ]] ; then
                echo
                ewarn "WARNING: your old configuration file ${ROOT}etc/wpa_supplicant.conf"
                ewarn "needs to be moved to ${ROOT}etc/wpa_supplicant/wpa_supplicant.conf"
        fi

        if use madwifi ; then
                echo
                einfo "This package compiles against the headers installed by"
                einfo "madwifi-old, madwifi-ng or madwifi-ng-tools."
                einfo "You should re-emerge ${PN} after upgrading these packages."
        fi
}
