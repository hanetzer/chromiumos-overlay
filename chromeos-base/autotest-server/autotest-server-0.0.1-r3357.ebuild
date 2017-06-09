# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="69de2fa6a83330b47b681615214af6f690ca2a07"
CROS_WORKON_TREE="7bba9422a778ccc6647fdebaa879f0b13f84ee21"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files
CROS_WORKON_SUBDIR_BLACKLIST=( "Documentation" "ExternalSource" "logs" "manifest-versions" "packages" "results" "site-packages" "frontend/client/www" "containers")

inherit cros-workon cros-constants

DESCRIPTION="Autotest scripts and tools"
HOMEPAGE="http://dev.chromium.org/chromium-os/testing"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/autotest-server-deps
	chromeos-base/autotest-web-frontend
"

DEPEND=""

AUTOTEST_WORK="${WORKDIR}/autotest-work"
AUTOTEST_BASE="/autotest"

src_prepare() {
	mkdir -p "${AUTOTEST_WORK}"
	cp -fpru "${S}"/* "${AUTOTEST_WORK}/" &>/dev/null
	find "${AUTOTEST_WORK}" -name '*.pyc' -delete

	# Remove the shadow_config.ini file.
	rm "${AUTOTEST_WORK}"/shadow_config.ini
}

src_compile() {
	protoc --proto_path "${S}" --python_out="${AUTOTEST_WORK}" "${S}/tko/tko.proto"
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	insinto "${AUTOTEST_BASE}"
	doins -r "${AUTOTEST_WORK}"/*
	chmod a+x "${D}/${AUTOTEST_BASE}"/tko/*.cgi

	dosym /var/log/autotest "${AUTOTEST_BASE}"/logs

	insinto /etc/init
	doins "${FILESDIR}"/*.conf
}

src_test() {
	# Run the autotest unit tests.
	./utils/unittest_suite.py --debug || die "Autotest unit tests failed."
}

