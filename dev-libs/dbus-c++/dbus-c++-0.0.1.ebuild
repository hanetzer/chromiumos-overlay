# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="~amd64 ~x86 ~arm"

if [[ ${PV} != "9999" ]] ; then
	inherit git

	KEYWORDS="amd64 x86 arm"

	EGIT_REPO_URI="git://anongit.freedesktop.org/git/dbus/dbus-c++/"
	EGIT_COMMIT="e508c71612549333553ac2b4d418284d91c4845e"
fi

inherit toolchain-funcs

DESCRIPTION="C++ D-Bus bindings"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/dbus-c%2B%2B"
SRC_URI=""
LICENSE="LGPL-2"
SLOT="1"
IUSE="debug doc +glib"

RDEPEND="
	glib? ( >=dev-libs/dbus-glib-0.76 )
	glib? ( >=dev-libs/glib-2.19:2 )
	>=sys-apps/dbus-1.0"
DEPEND="${DEPEND}
	doc? ( dev-libs/libxslt )
	doc? ( app-doc/doxygen )
	dev-util/pkgconfig"

src_unpack() {
	if [[ -n "${EGIT_REPO_URI}" ]] ; then
		git_src_unpack
	else
		# CHROMEOS_ROOT won't be set if the build
		# is being run from make_chroot.
		if [ -z "${CHROMEOS_ROOT}" ] ; then
			local CHROMEOS_ROOT=$(eval echo -n ~${SUDO_USER}/trunk)
		fi
		local dbus="${CHROMEOS_ROOT}/src/third_party/dbus-c++"

		elog "Using source: $dbus"
		cp -a "${dbus}" "${S}" || die
	fi
	ln -sf "${S}" "${S}/../dbus-c++"
}

src_prepare() {
	if [[ -n "${EGIT_REPO_URI}" ]] ; then
		# Until we can get this patch upstreamed, we need to fix
		# remove the usage of toString(errno)
		(cd ${S} && epatch "${FILESDIR}"/toString.patch) || \
			die "failed to apply patch"
	fi

	./bootstrap || die "failed to bootstrap autotools"
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable doc doxygen-docs) \
		$(use_enable glib glib) || die "failed to congfigure"
}

src_compile() {
	emake || die "failed to compile dbus-c++"
}

src_install() {
	emake DESTDIR="${D}" install || die "failed to make"
	dodoc AUTHORS ChangeLog NEWS README || die "failed to intall doc"
}
