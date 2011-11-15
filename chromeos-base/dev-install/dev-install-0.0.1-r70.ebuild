# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This ebuild file installs the developer installer package. It:
#  + Copies dev_install.
#  + Copies some config files for emerge: make.defaults and make.conf.
#  + Generates a list of packages installed (in base images).
# dev_install downloads and bootstraps emerge in base images without
# modifying the root filesystem.

EAPI=4
CROS_WORKON_COMMIT="d733cbe74c210a8c68a3a710d4aefed79815fcdd"
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
# base image. Also modify dev_install.
RDEPEND="app-arch/tar
	net-misc/curl
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
		| tr -d " " > "${S}/chromeos.packages"
	# No virtual packages in package.provided.
	grep -v "virtual/" "${S}/chromeos.packages" > "${S}/package.provided"

	# Get the list of the packages needed to bootstrap emerge.
	emerge-${BOARD} --pretend --emptytree --root-deps=rdeps portage \
                | grep -Eo " [[:alnum:]-]+/[^[:space:]/]+\b" \
                | tr -d " " > "${S}/portage.packages"
	# Get the list of dev and test pacakges
	emerge-${BOARD} --pretend --emptytree --root-deps=rdeps chromeos-dev \
                | grep -Eo " [[:alnum:]-]+/[^[:space:]/]+\b" \
                | tr -d " " > "${S}/chromeos-dev.packages"

	emerge-${BOARD} --pretend --emptytree --root-deps=rdeps chromeos-test \
                | grep -Eo " [[:alnum:]-]+/[^[:space:]/]+\b" \
                | tr -d " " > "${S}/chromeos-test.packages"

	# Filter out all the packages that are already in chromeos.
	while read line; do
		grep "$line" "${S}/chromeos.packages"
		if [ $? -ne 0 ]; then
			echo "${line}" >> "${S}/bootstrap.packages"
			# After bootstrapping the package will be assumed to be
			# installed by emerge.
			echo "${line}" | grep -v "virtual/" >> \
				"${S}/package.provided"
		fi
	done < "${S}/portage.packages"
	# Make a list of the packages that can be installed. Those packages are
	# in chromeos-dev or chromeos-test and not chromeos.
	while read line; do
                grep "$line" "${S}/chromeos.packages"
                if [ $? -ne 0 ]; then
                        echo "${line}" >> "${S}/package.installable"
                fi
        done < "${S}/chromeos-dev.packages"
	while read line; do
                grep "$line" "${S}/chromeos.packages"
                if [ $? -ne 0 ]; then
			grep "$line" "${S}/package.installable"
			if [ $? -ne 0 ]; then
	                        echo "${line}" >> "${S}/package.installable"
			fi
                fi
        done < "${S}/chromeos-test.packages"

	# Add the board specific binhost repository.
	sed -e "s|BOARD|${BOARD}|g" "${SRCDIR}/repository.conf" > "${S}/repository.conf"

	# Add dhcp to the list of packages installed since its installation will not
	# complete (can not add dhcp group since /etc is not writeable). Bootstrap it
	# instead.
	grep "net-misc/dhcp-" "${S}/chromeos-dev.packages" >> "${S}/package.provided"
	grep "net-misc/dhcp-" "${S}/chromeos-dev.packages" >> "${S}/bootstrap.packages"
}

src_install() {
	pushd "${SRCDIR}"
	exeinto /usr/bin
	doexe dev_install

	dodir /etc/portage
	insinto /etc/portage
	doins "${S}/repository.conf"
        doins "${S}/bootstrap.packages"

	dodir /etc/portage/make.profile
	insinto /etc/portage/make.profile
	doins "${S}/package.provided"
	doins "${S}/package.installable"
	doins make.defaults
	doins make.conf

	dodir /etc/env.d
	insinto /etc/env.d
	doins 99devinstall

	# Python will be installed in /usr/local after running dev_install.
	dosym "/usr/local/bin/python2.6" "/usr/bin/python"
	popd
}

