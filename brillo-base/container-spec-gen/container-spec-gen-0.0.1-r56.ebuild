# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="a16566a59c57ef76ee8b0a4dd18722e6839a50a6"
CROS_WORKON_TREE="d856ca4faf9387634a60c234cf8b90ba5f0b36f7"
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

src_install() {
	local python_dir="$(python_get_sitedir)"
	insinto "${python_dir}/generated"
	doins "${OUT}/gen/protos/py/soma_container_spec_pb2.py"
	touch "${D}/${python_dir}/generated/__init__.py"
}
