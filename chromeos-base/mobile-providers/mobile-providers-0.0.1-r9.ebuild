EAPI="2"
CROS_WORKON_COMMIT="71fb033b7af42c469b0f2cfbc19cbac4bc8610dd"
CROS_WORKON_PROJECT="chromiumos/third_party/mobile-broadband-provider-info"

inherit autotools cros-workon

DESCRIPTION="Database of mobile broadband service providers (with local modifications)"
HOMEPAGE="http://live.gnome.org/NetworkManager/MobileBroadband/ServiceProviders"

LICENSE="CC-PD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="!net-misc/mobile-broadband-provider-info"
DEPEND=""

CROS_WORKON_LOCALNAME="../third_party/mobile-broadband-provider-info"

src_compile() {
	eautoreconf || die "eautoreconf failed"
	econf || die "econf failed"
}

src_install() {
	xmllint --valid --noout serviceproviders.xml || \
		die "XML document is not well-formed or is not valid"
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc NEWS README || die "dodoc failed"
}

src_test() {
	make check || die "tests failed"
}
