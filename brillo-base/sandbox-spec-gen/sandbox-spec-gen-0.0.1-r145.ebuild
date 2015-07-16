# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="79e47d73359ca74fe6cb73e1b2b97b21dcbf4d91"
CROS_WORKON_TREE="2a3aba2795625efa228e07f876b0f8dae196c568"
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
