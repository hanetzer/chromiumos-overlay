# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.18.0.ebuild,v 1.10 2009/08/19 16:30:10 jer Exp $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
GNOME_TARBALL_SUFFIX="bz2"
PYTHON_COMPAT=( python2_7 )

inherit autotools gnome2 python-r1 virtualx

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="*"
IUSE="doc examples libffi test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND=">=dev-libs/glib-2.24.0:2
	libffi? ( virtual/libffi )
	${PYTHON_DEPS}"
DEPEND="${COMMON_DEPEND}
	doc? (
		dev-libs/libxslt
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
	test? (
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc )
	>=dev-util/pkgconfig-0.12"
RDEPEND="${COMMON_DEPEND}
	!<dev-python/pygtk-2.13"

src_prepare() {
	gnome2_src_prepare

	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${PN}-2.15.4-fix-codegen-location.patch"

	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}"/${P}-make_check.patch

	# Do not install files twice, bug #279813
	epatch "${FILESDIR}/${P}-automake111.patch"

	# For cross-compilation we need to compile the constant
	# generation for the HOST architecture while using the
	# target headers.
	if tc-is-cross-compiler ; then
		epatch "${FILESDIR}/${P}-cross-generate-constants.patch"
	fi

	# Workaround upstream Gentoo bug #232820
	find "${S}" -name .elibtoolized -delete
	eautoreconf

	python_copy_sources
}

src_configure() {
	python_foreach_impl run_in_build_dir \
		gnome2_src_configure \
			$(use_enable cairo) \
			$(use_enable threads thread)
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome2_src_compile
}

src_install() {
	DOCS="AUTHORS ChangeLog* NEWS README"

	python_foreach_impl run_in_build_dir gnome2_src_install

	sed "s:/usr/bin/python:/usr/bin/python2:" \
		-i "${ED}"/usr/bin/pygobject-codegen-2.0 \
		|| die "Fix usage of python interpreter"

	if use examples; then
		insinto /usr/share/doc/${P}
		doins -r examples
	fi
}
