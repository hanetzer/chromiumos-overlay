# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="4adc583655b47e302db5c845481f620050bd0b83"

inherit cros-workon

DESCRIPTION="Chrome OS Factory Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND="x86? ( sys-boot/syslinux )"

# TODO(nsanders): chromeos-initramfs doesn't compile on arm
RDEPEND="x86? ( chromeos-base/chromeos-initramfs )
         chromeos-base/chromeos-installer
         chromeos-base/chromeos-init
         chromeos-base/memento_softwareupdate"

CROS_WORKON_LOCALNAME="factory_installer"
CROS_WORKON_PROJECT="factory_installer"

FACTORY_SERVER="${FACTORY_SERVER:-meatball.mtv.corp.google.com}"

src_install() {
	insinto /etc/init
	doins factory_install.conf
	doins factory_ui.conf

	exeinto /usr/sbin
	doexe factory_install.sh
	doexe factory_reset.sh

	insinto /root
	newins $FILESDIR/dot.factory_installer .factory_installer
	newins $FILESDIR/dot.gpt_layout .gpt_layout
	# install PMBR code
	case "$(tc-arch)" in
		"x86")
		einfo "using x86 PMBR code from syslinux"
		PMBR_SOURCE="${ROOT}/usr/share/syslinux/gptmbr.bin"
		;;
		*)
		einfo "using default PMBR code"
		PMBR_SOURCE=$FILESDIR/dot.pmbr_code
		;;
	esac
	newins $PMBR_SOURCE .pmbr_code
}

pkg_postinst() {
	STATEFUL="${ROOT}/usr/local"
	STATEFUL_LSB="${STATEFUL}/etc/lsb-factory"

	mkdir -p "${STATEFUL}/etc"

	# sudo friendly append.
	cat <<EOF | sudo dd of="${STATEFUL_LSB}" \
                oflag=append conv=notrunc
CHROMEOS_AUSERVER=http://${FACTORY_SERVER}:8080/update
CHROMEOS_DEVSERVER=http://${FACTORY_SERVER}:8080/update
FACTORY_INSTALL=1
HTTP_SERVER_OVERRIDE=true
EOF

	# TODO(nsanders): Add runtime switches in init.git
	# Remove ui.conf startup script, which will make sure chrome doesn't
	# run, since it tries to update on startup
	sed -i 's/start on stopping startup/start on never/' \
		"${ROOT}/etc/init/ui.conf"
	# Set network to start up another way
	sed -i 's/login-prompt-visible/started udev/' \
		"${ROOT}/etc/init/boot-complete.conf"
	# No autoupdate!
	sed -i 's/start on stopped boot-complete/start on never/' \
		"${ROOT}/etc/init/software-update.conf"
	# No TPM locking.
	sed -i 's/start tcsd//' \
		"${ROOT}/etc/init/tpm-probe.conf"
}

