# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This project checks out the proto files from the read only repositories
# linked to the following directories of the Chromium project:

#   - src/components/policy/proto
#   - src/chrome/browser/chromeos/policy/proto

# This project is not cros-work-able: if changes to the protobufs are needed
# then they should be done in the Chromium repository, and the commits below
# should be updated.

EAPI="5"

inherit cros-constants git-2

# Every 3 strings in this array indicates a repository to checkout:
#   - A unique name (to avoid checkout conflits)
#   - The repository URL
#   - The commit to checkout
EGIT_REPO_URIS=(
	"cloud/policy"
	"${CROS_GIT_HOST_URL}/chromium/src/components/policy.git"
	"c7d963321cb91af21cfa124799016b9c131d0ba3"

	# If you uprev these repos, please also:
	# - Update files/VERSION to the corresponding revision of
	#   chromium/src/chrome/VERSION in the Chromium code base.
	#   Only the MAJOR version matters, really. This is necessary so policy
	#   code builders have the right set of policies.
	# - Keep the revisions of policy.git and proto.git in sync.
	#   A failure to do so might result in broken unit tests.
	# - Update authpolicy/policy/device_policy_encoder[_unittest].cc to
	#   include new device policies. The unit test tells you missing ones:
	#     cros_run_unit_tests --board=$BOARD --packages authpolicy
	#   User policy is generated and doesn't have to be updated manually.
	# - Bump the package version:
	#     git mv protofiles-0.0.N.ebuild protofiles-0.0.N+1.ebuild

	"chromeos/policy/proto"
	"${CROS_GIT_HOST_URL}/chromium/src/chrome/browser/chromeos/policy/proto.git"
	"605533d3439f0477ed94200b1d18e9e2b83668eb"
)

DESCRIPTION="Protobuf installer for the device policy proto definitions."
HOMEPAGE="http://chromium.org"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0/${PV}"
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
	doins "${S}"/{chromeos,cloud}/policy/proto/*.proto
	insinto /usr/share/protofiles
	doins "${S}"/chromeos/policy/proto/chrome_device_policy.proto
	doins "${S}"/cloud/policy/proto/device_management_backend.proto
	doins "${S}"/cloud/policy/proto/chrome_extension_policy.proto
	dobin "${FILESDIR}"/policy_reader
	insinto /usr/share/policy_resources
	doins "${S}"/cloud/policy/resources/policy_templates.json
	doins "${FILESDIR}"/VERSION
	insinto /usr/share/policy_tools
	doins "${S}"/cloud/policy/tools/generate_policy_source.py
}
