# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="53114903cc7755e39ce0e8583cae15e8e22edf4b"

inherit cros-workon

DESCRIPTION="Chrome OS Factory Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND="x86? ( sys-boot/syslinux )"

RDEPEND="chromeos-base/chromeos-initramfs
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
	sed -i \
		"s/CHROMEOS_AUSERVER=.*$/CHROMEOS_AUSERVER=\
http:\/\/${FACTORY_SERVER}:8080\/update/" \
	${ROOT}/etc/lsb-release

	# sudo friendly append.
	cat <<EOF | sudo dd of="${ROOT}/etc/lsb-release" \
                oflag=append conv=notrunc
FACTORY_INSTALL=1
HTTP_SERVER_OVERRIDE=true
EOF

	# No devserver.
	sed -i '/CHROMEOS_DEVSERVER=/d' "${ROOT}/etc/lsb-release"

	# Remove ui.conf startup script, which will make sure chrome doesn't
	# run, since it tries to update on startup
	sed -i 's/start on stopping startup/start on never/' \
		"${ROOT}/etc/init/ui.conf"
	# Set network to start up another way
	sed -i 's/login-prompt-ready/stopping startup/' \
		"${ROOT}/etc/init/boot-complete.conf"
	# No autoupdate!
	sed -i 's/start on stopped boot-complete/start on never/' \
		"${ROOT}/etc/init/software-update.conf"
}

