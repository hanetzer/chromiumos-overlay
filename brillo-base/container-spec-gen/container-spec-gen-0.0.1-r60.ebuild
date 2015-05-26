# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="4fa60e6293523feda51d5fbd934bb0fff6e37e8b"
CROS_WORKON_TREE="da759b85910566911374e24ab7c6a66686880a68"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_GYP_FILE="python-protos.gyp"
PLATFORM_SUBDIR="soma"

inherit cros-workon platform python

DESCRIPTION="Generated Python code for serializing ContainerSpec protobuffers."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/protobuf"

# TODO(cmasone): Deprecate this ebuild and replace with sandbox-spec-gen
# once all consumers are moved over to the new proto. http://brbug.com/1028
src_install() {
	local python_dir="$(python_get_sitedir)"
	insinto "${python_dir}/generated"
	doins "${OUT}/gen/protos/py/soma_container_spec_pb2.py"
	doins "${OUT}/gen/protos/py/soma_sandbox_spec_pb2.py"
	touch "${D}/${python_dir}/generated/__init__.py"
}
