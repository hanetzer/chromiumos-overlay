# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="abf933e3f7bc52f8ff080a904c7b17ebbff7053b"
CROS_WORKON_TREE=("61b4b0c05e003fddaa705031945fece7f560c7d7" "8b7b4a456849a4904f11daca066e6dd14774c530")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE="common-mk smogcheck"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon cros-debug multilib

DESCRIPTION="TPM SmogCheck library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/smogcheck/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

src_unpack() {
	cros-workon_src_unpack
	S+="/smogcheck"
}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="$(get_libdir)" install
}