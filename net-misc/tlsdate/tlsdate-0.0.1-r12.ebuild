# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="5db34d48f1cd9abdc5cbac106c42389b460e5a9d"
CROS_WORKON_TREE="ef46ad6656c31626ffd0fed6aa24c5b31c552dfa"
CROS_WORKON_PROJECT="chromiumos/third_party/tlsdate"

inherit autotools flag-o-matic toolchain-funcs cros-workon

DESCRIPTION="Update local time over HTTPS"
HOMEPAGE="https://github.com/ioerror/tlsdate"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="dev-libs/openssl"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_compile() {
	# Provide timestamp of when this was built, in number of seconds since
	# 01 Jan 1970 in UTC time.
	local DATE=$(($(date -u +%s) - 86400))
	# Set it back one day to avoid dealing with time zones.
	append-cppflags -DRECENT_COMPILE_DATE=${DATE}

	# Our unprivileged group is called "nobody"
	append-cppflags '-DUNPRIV_GROUP=\"nobody\"'
	tc-export CC
	emake CFLAGS="-Wall ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
}

src_install() {
	dosbin src/tlsdate{,-helper,d}
	doman man/tlsdate{,-helper}.1
	dodoc README
}
