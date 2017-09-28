# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="ec108678e26eba449c657e89f5ca30c98f73d312"
CROS_WORKON_TREE="c1297cc9425924c278919035f5729d8a390908b4"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"

DISTUTILS_OPTIONAL="1"
PYTHON_COMPAT=( python2_7 )

PLATFORM_SUBDIR="chromeos-config"

inherit cros-workon platform distutils-r1

DESCRIPTION="Chrome OS configuration tools"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="cros_host python"

RDEPEND="
	chromeos-base/libbrillo
	python? ( ${PYTHON_DEPS} )
	sys-apps/dtc
"

DEPEND="
	${RDEPEND}
	python? (
		${PYTHON_DEPS}
		dev-python/setuptools[${PYTHON_USEDEP}]
	)
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	cros-workon_src_prepare
	use python && distutils-r1_src_prepare
}

src_configure() {
	cros-workon_src_configure
	platform_src_configure
	if use python; then
		if [[ -n "${fixme}" ]]; then
			distutils-r1_src_configure
		fi
	fi
}

src_compile() {
	cros-workon_src_compile
	platform_src_compile
	if use python; then
		if [[ -n "${fixme}" ]]; then
			distutils-r1_src_compile
		fi
	fi
}

src_install() {
	dolib.so "${OUT}/lib/libcros_config.so"

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcros_config.pc

	dobin "${OUT}"/cros_config
	use cros_host && dobin "${OUT}"/cros_config_host

	if use python; then
		if [[ -n "${fixme}" ]]; then
# python2_7: running distutils-r1_run_phase distutils-r1_python_install
# ACCESS DENIED:  mkdir:        /mnt/host/source/src/platform2/chromeos-config-python2_7
# mkdir: cannot create directory ‘/mnt/host/source/src/platform2/chromeos-config-python2_7’: Permission denied
# ERROR: chromeos-base/chromeos-config-tools-9999::chromiumos failed (install phase):
			distutils-r1_src_install
		else
			einfo "Manually installing for now"
			exeinto /usr/lib/python2.7/site-packages
			for fname in cros_config_host_py/*.py; do
				einfo "install ${fname}"
				doexe "${fname}"
			done
			exeinto /usr/bin
			doexe cros_config_host_py/cros_config_host_py
		fi
	fi
}

platform_pkg_test() {
	local tests=(
		cros_config_unittest
		cros_config_main_unittest
	)

	use cros_host && tests+=( cros_config_host_main_unittest )

	local test_bin

	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done

	./run_tests.sh || die "cros_config unit tests have errors"
}