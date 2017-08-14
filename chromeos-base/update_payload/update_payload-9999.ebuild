# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python2_7 python3_{3,4,5,6} )

CROS_WORKON_LOCALNAME="../aosp/system/update_engine"
CROS_WORKON_PROJECT="aosp/platform/system/update_engine"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon python-r1

DESCRIPTION="Chrome OS Update Engine Update Payload Scripts"
HOMEPAGE="https://chromium.googlesource.com/aosp/platform/system/update_engine"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"

RDEPEND="
	dev-python/protobuf-python[${PYTHON_USEDEP}]
	!<chromeos-base/devserver-0.0.3
"
DEPEND=""

src_install() {
	# Install update_payload scripts.
	install_update_payload() {
		insinto "$(python_get_sitedir)/update_payload"
		doins $(printf '%s\n' scripts/update_payload/*.py | grep -v unittest)
		doins scripts/update_payload/update-payload-key.pub.pem
	}
	python_foreach_impl install_update_payload
}

src_test() {
	# Run python script unittests.
	cd scripts/update_payload
	local unittest_script
	for unittest_script in *_unittest.py; do
		./"${unittest_script}" || die
	done
}
