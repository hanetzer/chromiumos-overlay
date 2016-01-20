# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2f68a2da167f2389c0b4e0f4878532cfb1afb23b"
CROS_WORKON_TREE="168599bbfa8550b495f904d43235e15d2278fd8b"
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
