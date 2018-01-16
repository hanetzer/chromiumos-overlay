# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="a7d7f5140c2ef4c71b4f4410b5ad5c7e048d0c63"
CROS_WORKON_TREE="e818cfe00773a1ed046433ded8d9561ce92b8e29"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="midis"

inherit cros-workon platform user git-r3

DESCRIPTION="MIDI Server for Chromium OS"
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+seccomp"

RDEPEND="
	chromeos-base/libbrillo
"

DEPEND="${RDEPEND}"

src_unpack() {
	platform_src_unpack

	EGIT_REPO_URI="${CROS_GIT_HOST_URL}/chromium/src/media/midi.git" \
	# Since there are a few headers that are included by other headers
	# in this directory, and these headers are referenced assuming the
	# "media" directory is stored in the base directory, we install
	# the Git checkout in platform2.
	EGIT_CHECKOUT_DIR="${S}/../media/midi" \
	EGIT_COMMIT="294d224ae7a8a695bb71337be8781b29abb5dafc" \
	git-r3_src_unpack
}

src_install() {
	dobin "${OUT}"/midis

	insinto /etc/init
	doins init/*.conf

	# Install midis DBUS configuration file
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.Midis.conf

	# Install seccomp policy file.
	insinto /usr/share/policy
	use seccomp && newins "seccomp/midis-seccomp-${ARCH}.policy" midis-seccomp.policy
}

pkg_preinst() {
	enewuser midis
	enewgroup midis
}

platform_pkg_test() {
	local tests=(
		"midis_testrunner"
	)

	local test
	for test in "${tests[@]}"; do
		platform_test "run" "${OUT}"/${test}
	done
}
