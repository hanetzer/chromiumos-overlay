# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Utility that generates C bindings for D-Bus objects."
HOMEPAGE="http://upstart.ubuntu.com/"
SRC_URI="http://upstart.ubuntu.com/download/0.6/upstart-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="nls"

DEPEND=">=dev-libs/expat-2.0.0
	>=sys-apps/dbus-1.2.16
	nls? ( sys-devel/gettext )"

RDEPEND=">=sys-apps/dbus-1.2.16"

# We get the nih-dbus-tool out of the upstart sources. It sounds
# like they are planning to split this into a separate project,
# so at that time this ebuild should become cleaner.
S="${WORKDIR}/upstart-${PV}"

src_compile() {
	econf $(use_enable nls)
	emake SUBDIRS="nih nih-dbus nih-dbus-tool" \
		|| die "emake failed"
}

src_install() {
	# We need to "install" nih-dbus-tool manually since the upstart
	# build does not install nih-dbus-tool; it just uses it to build.
	mkdir "${D}/bin"
	cp "${S}/nih-dbus-tool/nih-dbus-tool" "${D}/bin"
}
