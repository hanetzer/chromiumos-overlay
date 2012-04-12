# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
CROS_WORKON_COMMIT="20119160e2397a2c75c7e01158e9ca7d4d0d3eb0"
CROS_WORKON_TREE="22e2316f32c0136c75409b6e697f63a5b21280b5"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/glmark2"

inherit toolchain-funcs waf-utils cros-workon

DESCRIPTION="Opengl test suite"
HOMEPAGE="https://launchpad.net/glmark2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="gles2 drm"

RDEPEND="media-libs/libpng
	media-libs/mesa[gles2?]
	x11-libs/libX11"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	rm -rf src/libpng
	sed -i -e 's:libpng12:libpng:g' wscript src/wscript_build || die
}

src_configure() {
	: ${WAF_BINARY:="${S}/waf"}

	local myconf

	if use gles2; then
		myconf+="--enable-glesv2"
	fi

	if use drm; then
		myconf+=" --enable-gl-drm"
		if use gles2; then
			myconf+=" --enable-glesv2-drm"
		fi
	fi

	tc-export CC CXX PKG_CONFIG
	export PKGCONFIG=${PKG_CONFIG}

	# it does not know --libdir specification, dandy huh
	CCFLAGS="${CFLAGS}" LINKFLAGS="${LDFLAGS}" "${WAF_BINARY}" \
		--prefix=/usr \
		--enable-gl \
		${myconf} \
		configure || die "configure failed"
}
