# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit cros-workon

DESCRIPTION="The xkb-layouts engine IMEngine for IBus Framework"
HOMEPAGE="http://github.com/suzhe/ibus-xkb-layouts"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

RDEPEND=">=app-i18n/ibus-1.2"
DEPEND="${RDEPEND}
	chromeos-base/chromeos-assets
	dev-util/pkgconfig
	>=sys-devel/gettext-0.16.1
	x11-misc/xkeyboard-config"

CROS_WORKON_SUBDIR="files"

XKB_RULES="/usr/share/X11/xkb/rules/xorg.xml"

src_prepare() {
	NOCONFIGURE=1 ./autogen.sh
	# Build ibus-engine-xkb-layouts for the host platform.
	# Use xorg.xml in SYSROOT/usr rather than /usr here for code
	# generation (i.e. one in /usr can be different from the one in
	# SYSROOT/usr). See also comments in src_configure.
	(env -i ./configure $CONFIGURE_OPTIONS \
	 --with-xkb-rules-xml="${SYSROOT}/${XKB_RULES}" && env -i make) || die
	# Obtain the XML output by running the binary.
	src/ibus-engine-xkb-layouts --xml > output.xml || die
	# Make sure that at least one engine is present.
	grep -q '<engine>' output.xml || die
	# Clean up.
	make distclean || die
}

src_configure() {
	# Since X for Chrome OS does not use evdev, we use xorg.xml.
	# Use xorg.xml in /usr as the path will be embedded into
	# ibus-xkb-layouts production binary.
	econf --with-xkb-rules-xml="${XKB_RULES}" || die
}

src_compile() {
	emake || die
	# Rewrite xkb-layouts.xml using the XML output.
	LIST="${SYSROOT}"/usr/share/chromeos-assets/input_methods/whitelist.txt
	python "${FILESDIR}"/filter.py < output.xml \
	  --whitelist="${LIST}" \
	  --rewrite=src/xkb-layouts.xml || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README
}
