# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="fe09dd6d360c2545a6916169cae9a7b5e3ebea46"
CROS_WORKON_TREE="1c249cf0cc46eb2d67ed885e91972d4584f020c6"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_GYP_FILE="python-protos.gyp"
PLATFORM_SUBDIR="soma"
PYTHON_COMPAT=( python2_7 )

inherit cros-workon platform python-r1

DESCRIPTION="Generated Python code for serializing SandboxSpec protobuffers."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!brillo-base/container-spec-gen"
DEPEND="${RDEPEND}
	dev-libs/protobuf"

py_install() {
	local python_dir="$(python_get_sitedir)"
	insinto "${python_dir}/generated"
	doins "${OUT}/gen/protos/py/soma_sandbox_spec_pb2.py"
	touch "${D}/${python_dir}/generated/__init__.py"
}

src_install() {
	python_foreach_impl py_install
}
