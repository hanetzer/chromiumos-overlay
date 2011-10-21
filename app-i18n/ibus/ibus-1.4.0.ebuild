# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# How to run the test manually:
#   (chroot)$ ./cros_run_unit_tests --packages ibus
# or
#   (chroot)$ env FEATURES="test" emerge-$BOARD -a ibus

EAPI="2"
inherit eutils flag-o-matic toolchain-funcs multilib python

DESCRIPTION="Intelligent Input Bus for Linux / Unix OS"
HOMEPAGE="http://code.google.com/p/ibus/"

SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="doc nls python"
#RESTRICT="mirror"

RDEPEND="python? ( >=dev-lang/python-2.5 )
	>=dev-libs/glib-2.26
	python? ( >=dev-python/pygobject-2.14 )
	nls? ( virtual/libintl )
	>=x11-libs/gtk+-2
	x11-libs/libX11"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.9 )
	dev-util/pkgconfig
	nls? ( >=sys-devel/gettext-0.16.1 )"
RDEPEND="${RDEPEND}
	python? ( >=dev-python/dbus-python-0.83 )
	python? ( dev-python/pygtk )
	python? ( dev-python/pyxdg )"

pkg_setup() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="/etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR=${GTK2_CONFDIR:=/etc/gtk-2.0/}
}

src_prepare() {
	# Since these two patches are for Python files, we don't have to apply
	# them.
	#epatch "${FILESDIR}"/0001-Merge-xkb-related-changes.patch
	#epatch "${FILESDIR}"/0002-Support-changing-the-global-input-method-engine-with.patch

        epatch "${FILESDIR}"/0003-Add-api-to-ibus-for-retreiving-unused-config-values.patch
	epatch "${FILESDIR}"/0004-Remove-bus_input_context_register_properties-props_e.patch
	epatch "${FILESDIR}"/0005-Port-the-following-ibus-1.3-patches-to-1.4.patch
        epatch "${FILESDIR}"/0006-Change-default-values-of-some-config.patch

        # TODO(yusukes): Remove the patch to use upstream releases as-is.
        epatch "${FILESDIR}"/${P}-revert-adcf71e6-for-crosbug-19605.patch
}

src_configure() {
	# When cross-compiled, we build the gtk im module. Otherwise we don't
	# since the module is not necessary for host environment.
	if tc-is-cross-compiler ; then
	       GTK2_IM_MODULE_FLAG=--enable-gtk2
	else
	       GTK2_IM_MODULE_FLAG=--disable-gtk2
	fi

	append-cflags -Wall -Werror
	# TODO(petkov): Ideally, configure should support --disable-isocodes but it
	# seems that the current version doesn't, so use the environment variables
	# instead to remove the dependence on iso-codes.
	econf \
		${GTK2_IM_MODULE_FLAG} \
		--enable-gtk2 \
		--disable-gtk3 \
		--disable-dconf \
		--disable-gconf \
		--disable-xim \
		--disable-key-snooper \
		--enable-memconf \
		--disable-vala \
		--enable-introspection=no \
		$(use_enable doc gtk-doc) \
		$(use_enable nls) \
		$(use_enable python) \
		CPPFLAGS='-DOS_CHROMEOS=1' \
		ISOCODES_CFLAGS=' ' ISOCODES_LIBS=' ' \
		|| die
}

test_fail() {
	kill $IBUS_DAEMON_PID
	rm -rf "${T}"/.ibus-test-socket-*
	die
}

src_test() {
	# Start ibus-daemon background.
	export IBUS_ADDRESS_FILE="`mktemp -d ${T}/.ibus-test-socket-XXXXXXXXXX`/ibus-socket-file"
	./bus/ibus-daemon --replace --panel=disable &
	IBUS_DAEMON_PID=$!

	# Wait for the daemon to start.
	if [ ! -f ${IBUS_ADDRESS_FILE} ] ; then
	   sleep .5
	fi

	# Run tests.
	./src/tests/ibus-bus || test_fail
	./src/tests/ibus-inputcontext || test_fail
	./src/tests/ibus-inputcontext-create || test_fail
	./src/tests/ibus-configservice || test_fail
	./src/tests/ibus-factory || test_fail
	./src/tests/ibus-keynames || test_fail
	./src/tests/ibus-serializable || test_fail

	# Cleanup.
	kill $IBUS_DAEMON_PID
	rm -rf "${T}"/.ibus-test-socket-*
}

src_install() {
	emake DESTDIR="${D}" install || die
	if [ -f "${D}/usr/share/ibus/component/gtkpanel.xml" ] ; then
		rm "${D}/usr/share/ibus/component/gtkpanel.xml" || die
	fi

	# Remove unnecessary files
	rm -rf "${D}/usr/share/icons" || die
	rm "${D}/usr/share/applications/ibus.desktop" || die

	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	elog "To use ibus, you should:"
	elog "1. Get input engines from sunrise overlay."
	elog "   Run \"emerge -s ibus-\" in your favorite terminal"
	elog "   for a list of packages we already have."
	elog
	elog "2. Setup ibus:"
	elog
	elog "   $ ibus-setup"
	elog
	elog "3. Set the following in your user startup scripts"
	elog "   such as .xinitrc, .xsession or .xprofile:"
	elog
	elog "   export XMODIFIERS=\"@im=ibus\""
	elog "   export GTK_IM_MODULE=\"ibus\""
	elog "   export QT_IM_MODULE=\"xim\""
	elog "   ibus-daemon -d -x"

	# Do not create gtk.immodules here. chromeos-base/chromeos will do that
	# later.

	if use python; then
		python_mod_optimize /usr/share/${PN}
	fi
}

pkg_postrm() {
	[ "${ROOT}" = "/" -a -x /usr/bin/gtk-query-immodules-2.0 ] && \
		gtk-query-immodules-2.0 > "${ROOT}/${GTK2_CONFDIR}/gtk.immodules"

	if use python; then
		python_mod_cleanup /usr/share/${PN}
	fi
}
