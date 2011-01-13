# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#
# This file is a heavily edited version of the Gentoo original streamlined for
# ChromeOS base hardware.

PYTHON_DEPEND="python? *"
inherit autotools eutils distutils flag-o-matic

DESCRIPTION="GPS daemon and library to interface GPS devices and clients"
HOMEPAGE="http://gpsd.berlios.de/"
SRC_URI="mirror://berlios/gpsd/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm x86"

IUSE="dbus ntp usb"

RDEPEND="dbus? ( >=sys-apps/dbus-0.94
		>=dev-libs/glib-2.6
		dev-libs/dbus-glib )
	 ntp? ( net-misc/ntp )
	 usb? ( virtual/dev-manager )"

DEPEND="${RDEPEND}
	python? ( dev-lang/python )"

# TODO(vbendeb): the below statement is a hack required to circumvent the
# build system deficiency: the linker default library path is specified in
# /build/<target>/make.conf, which causes the system libraries to be examined
# first by the linker, not last, as they ought to be.
#
# Once the build system is fixed the below statement will be removed to allow
# legitimate linker flag additions.
LDFLAGS=''

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Drop extensions requiring Python.
	sed -i -e 's:^\s\+Extension("gps\.\(packet\|clienthelpers\)",.*$:#:' \
		setup.py || die "sed failed"
	eautoreconf
}

src_compile() {
	local max_clients="5"
	local max_devices="2"
	local my_conf="--enable-shared --with-pic --enable-static"

	use python && distutils_python_version

	if use ntp; then
		my_conf="${my_conf} --enable-ntpshm --enable-pps"
	else
		my_conf="${my_conf} --disable-ntpshm --disable-pps"
	fi

	my_conf+=" --enable-max-devices=${max_devices}\
		   --enable-max-clients=${max_clients}"

	WITH_XSLTPROC=no WITH_XMLTO=no econf ${my_conf} \
		$(use_enable dbus) $(use_enable ocean oceanserver) \
		$(use_enable tntc tnt) \
		$(use_enable garmin garmintxt) || die "econf failed"

	emake -j1 || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
        insinto /etc/init || die "insinto failed"
        doins "${FILESDIR}/gpsd.conf" || die "doins failed"

        # TODO(vbendeb): to reintroduce support of USB devices plug in
        # populate udev rules here.
}
