# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS Factory Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND=""

RDEPEND="chromeos-base/chromeos-installer
         chromeos-base/chromeos-init
         chromeos-base/memento_softwareupdate"

FACTORY_SERVER="${FACTORY_SERVER:-meatball.mtv.corp.google.com}"


src_unpack() {
	local factory_installer="${CHROMEOS_ROOT}/src/platform/factory_installer"
	elog "Using factory_installer: $factory_installer"
	mkdir "${S}"
	cp -a "${factory_installer}"/* "${S}" || die
}

src_install() {
	insinto /etc/init
	doins factory_install.conf
	doins factory_ui.conf
	
	exeinto /usr/sbin
	doexe factory_install.sh
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
		"${ROOT}/etc/init/dump-boot-stats.conf"
	# Allow text progress for now.
	sed -i 's/\[ \-x \/usr\/bin\/ply\-image \]/false/' \
		"${ROOT}/sbin/chromeos_startup"
}

