# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This ebuild file installs the developer installer package. It:
#  + Copies dev_install.sh.
#  + Copies some config files for emerge: make.conf.user and make.conf.
#  + Generates a list of packages installed (in base images).
# dev_install.sh downloads and bootstraps emerge in base images without
# modifying the root filesystem.

EAPI=4
CROS_WORKON_COMMIT="89b86b8d079e530c11631bb066f266aedcf4dcdb"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"

inherit cros-workon

DESCRIPTION="Chromium OS Developer Packages installer"
HOMEPAGE="http://www.chromium.org/chromium-os"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="app-arch/tar
	sys-apps/coreutils
	sys-apps/grep
	sys-apps/portage
	sys-apps/sed"
# TODO(arkaitzr): remove dependency on tar if it's gonna be removed from the
# base image. Also modify dev_install.sh.
RDEPEND="app-arch/tar
	net-misc/wget
	sys-apps/coreutils"

CROS_WORKON_LOCALNAME="dev"
SRCDIR="${CROS_WORKON_SRCROOT}/src/platform/${CROS_WORKON_LOCALNAME}/dev-install"

src_unpack() {
	mkdir -p "${S}"

	# Generate a list of packages that go into the base image. These
	# packages will be assumed to be installed by emerge in the target.
	local BOARD="${BOARD:-${SYSROOT##/build/}}"
	emerge-${BOARD} --pretend --emptytree --root-deps=rdeps chromeos \
		| grep -Eo " [[:alnum:]-]+/[^[:space:]/]+\b" \
		| tr -d " " > "${S}/package.provided"

	# Add the board specific binhost repository.
	sed -e "s|BOARD|${BOARD}|g" "${SRCDIR}/repository.conf" > "${S}/repository.conf"

	# /etc/make.conf contains architecture specific information. Right now
	# we just grab make.globals from emerging portage.
	# TODO(arkaitzr): we may want to ignore complex emerge configurations
	# and only allow binary packages to be installed, at least for a start.
	local portage_file="${S}/../../../../../../packages/sys-apps/portage*.tbz2"
	tar -C "${S}" -xjvf "${portage_file}" --wildcards \
		"./usr/share/portage/config/make.globals"
}

src_install() {
	pushd "${SRCDIR}"

	exeinto /usr/bin
	doexe dev_install

	insinto /etc
	doins make.defaults

	dodir /etc/portage
	insinto /etc/portage
	newins "${S}/usr/share/portage/config/make.globals make.globals.user"
        doins "${S}/repository.conf"

	dodir /etc/portage/make.profile
	insinto /etc/portage/make.profile
	doins "${S}/package.provided"

	popd
}
