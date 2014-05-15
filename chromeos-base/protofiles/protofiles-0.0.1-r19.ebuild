# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This project checks out the proto files from the read only repositories
# linked to the following directories of the Chromium project:

#   - src/components/policy/proto
#   - src/chrome/browser/chromeos/policy/proto

# This project is not cros-work-able: if changes to the protobufs are needed
# then they should be done in the Chromium repository, and the commits below
# should be updated.

EAPI="4"

inherit cros-constants git-2

# Every 3 strings in this array indicates a repository to checkout:
#   - A unique name (to avoid checkout conflits)
#   - The repository URL
#   - The commit to checkout
EGIT_REPO_URIS=(
	"cloud"
	"${CROS_GIT_HOST_URL}/chromium/src/components/policy/proto.git"
	"2a78b9679f04bc67c4274cc18ae5ae33c9659b48"

	"chromeos"
	"${CROS_GIT_HOST_URL}/chromium/src/chrome/browser/chromeos/policy/proto.git"
	"57e0fc6de99544437428fd450b190fb273bb0053"

	"feedback"
	"${CROS_GIT_HOST_URL}/chromium/src/components/feedback.git"
	"816eae2847ab38581db5a457eeb42db995b98b35"
)

DESCRIPTION="Protobuf installer for the device policy proto definitions."
HOMEPAGE="http://chromium.org"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_unpack() {
	set -- "${EGIT_REPO_URIS[@]}"
	while [[ $# -gt 0 ]]; do
		EGIT_PROJECT=$1 \
		EGIT_SOURCEDIR="${S}/$1" \
		EGIT_REPO_URI=$2 \
		EGIT_COMMIT=$3 \
		git-2_src_unpack
		shift 3
	done
}

src_install() {
	insinto /usr/include/proto
	doins "${S}"/{chromeos,cloud,feedback/proto}/*.proto
	insinto /usr/share/protofiles
	doins "${S}"/chromeos/chrome_device_policy.proto
	doins "${S}"/cloud/device_management_backend.proto
	dobin "${FILESDIR}"/policy_reader
}
