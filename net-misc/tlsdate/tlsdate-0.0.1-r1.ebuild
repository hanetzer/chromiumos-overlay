# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="0112e9a3a44aea1b0b6744370a463f23494dd8d0"
CROS_WORKON_TREE="c9addfdea173b7ceafa58737a52fe5f33dd30700"

EAPI="4"
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
	local DATE=$(expr $(date -u +%s) - 86400)
	# Set it back one day to avoid dealing with time zones.
	append-cppflags -DRECENT_COMPILE_DATE=${DATE}
	# Our unprivileged group is called "nobody"
	append-cppflags '-DUNPRIV_GROUP=\"nobody\"'
	tc-export CC
	emake CFLAGS="-Wall ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
}

src_install() {
	dosbin tlsdate{,-helper}
	doman tlsdate.1
	dodoc README
}
