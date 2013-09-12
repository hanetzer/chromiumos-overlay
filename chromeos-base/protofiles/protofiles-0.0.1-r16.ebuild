# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This project checks out the proto files from the read only repository
# linked to the src/chrome/browser/policy/proto directory of the Chromium
# project. It is not cros-work-able if changes to the protobufs are needed
# these should be done in the Chromium repository.

EGIT_REPO_SERVER="http://git.chromium.org"
EGIT_REPO_URI="${EGIT_REPO_SERVER}/chromium/src/chrome/browser/policy/proto.git"
EGIT_PROJECT="proto"
EGIT_COMMIT="c2f336d4dc9af16cb65446e215c62b7515fa1375"

EAPI="4"
inherit git-2

DESCRIPTION="Protobuf installer for the device policy proto definitions."
HOMEPAGE="http://chromium.org"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_install() {
	insinto /usr/include/proto
	doins "${S}"/{chromeos,cloud}/*.proto
	insinto /usr/share/protofiles
	doins "${S}"/chromeos/chrome_device_policy.proto
	doins "${S}"/cloud/device_management_backend.proto
	dobin "${FILESDIR}"/policy_reader
}
