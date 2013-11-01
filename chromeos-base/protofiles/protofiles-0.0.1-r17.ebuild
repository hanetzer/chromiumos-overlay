# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This project checks out the proto files from the read only repository
# linked to the src/chrome/browser/policy/proto directory of the Chromium
# project. It is not cros-work-able if changes to the protobufs are needed
# these should be done in the Chromium repository.

EAPI="4"

inherit cros-constants git-2

EGIT_REPO_URI="${CROS_GIT_HOST_URL}/chromium/src/chrome/browser/policy/proto.git"
EGIT_PROJECT="proto"
EGIT_COMMIT="0a56adea5511d8cf2b679add73fc682ee8e95aaf"

DESCRIPTION="Protobuf installer for the device policy proto definitions."
HOMEPAGE="http://chromium.org"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_install() {
	insinto /usr/include/proto
	doins "${S}"/{chromeos,cloud}/*.proto
	insinto /usr/share/protofiles
	doins "${S}"/chromeos/chrome_device_policy.proto
	doins "${S}"/cloud/device_management_backend.proto
	dobin "${FILESDIR}"/policy_reader
}
