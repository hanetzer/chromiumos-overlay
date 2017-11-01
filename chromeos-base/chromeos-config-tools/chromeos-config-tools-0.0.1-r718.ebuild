# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="f5ed93fdcc95af8043c4117b6cdee110e9706f35"
CROS_WORKON_TREE="4b29a126ea37dd86c627dfc4052aea1e2dcf4587"
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

	if use python; then
		if [[ -n "${fixme}" ]]; then
# python2_7: running distutils-r1_run_phase distutils-r1_python_install
# ACCESS DENIED:  mkdir:        /mnt/host/source/src/platform2/chromeos-config-python2_7
# mkdir: cannot create directory ‘/mnt/host/source/src/platform2/chromeos-config-python2_7’: Permission denied
# ERROR: chromeos-base/chromeos-config-tools-9999::chromiumos failed (install phase):
			distutils-r1_src_install
		else
			einfo "Manually installing for now"
			for fname in cros_config_host.py validate_config.py \
				validate_schema.py \
				libcros_config_host/*.py; do
				exeinto "$(dirname /usr/lib/python2.7/site-packages/${fname})"
				einfo "install ${fname}"
				doexe "${fname}"
			done
			exeinto /usr/bin
			doexe cros_config_host_py
			doexe validate_config
		fi
	fi
}

platform_pkg_test() {
	local tests=(
		cros_config_unittest
		cros_config_main_unittest
		fake_cros_config_unittest
	)

	local test_bin

	# We could run the C++ tests without Python except that the test setup
	# script needs to generate the list of target directories, which needs
	# Python. This does not seem to be available on the target:
	# File "../chromeos-config/libcros_config_host/fdt.py"
	# import libfdt
	# ImportError: No module named libfdt
	if use python; then
		for test_bin in "${tests[@]}"; do
			platform_test "run" "${OUT}/${test_bin}"
		done

		./run_tests.sh || die "cros_config unit tests have errors"
	fi
}
