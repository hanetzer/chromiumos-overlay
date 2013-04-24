# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("f83e0a1e7af90313f6b1e3ce3b1813b296ee59ed" "d391ba33815a40f4495d25ac8367fec74ad1b675")
CROS_WORKON_TREE=("96ac1fff68037806d217287a2d861f03d616975a" "f2a3067aefb352f4ab30e91457528300e2939380")
CROS_WORKON_PROJECT=("chromiumos/platform/factory" "chromiumos/platform/installer")
CROS_WORKON_LOCALNAME=("factory" "installer")
CROS_WORKON_DESTDIR=("${S}" "${S}/installer")

inherit cros-workon
inherit cros-binary
inherit python

DESCRIPTION="Chrome OS Factory Tools and Data"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="+autotest +build_tests"

DEPEND="chromeos-base/chromeos-chrome
	dev-python/pyyaml
	dev-python/unittest2
	chromeos-base/chromeos-factory-board"
RDEPEND="!chromeos-base/chromeos-factorytools
	dev-lang/python
	dev-python/argparse
	dev-python/jsonrpclib
	dev-python/netifaces
	dev-python/python-evdev
	dev-python/pyyaml
	dev-python/setproctitle
	dev-python/unittest2
	dev-util/stressapptest
	chromeos-base/chromeos-factory-board
	>=chromeos-base/vpd-0.0.1-r11"

CROS_WORKON_LOCALNAME="factory"

TARGET_DIR="/usr/local/factory"

CROS_BINARY_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/closure-library-20130212-95c19e7f0f5f.zip"
CROS_BINARY_SUM="56cebce034fad6a8c1ecf9f159e3310dbb25b331"

src_unpack() {
	cros-workon_src_unpack
	cros-binary_src_unpack
}

src_compile() {
	emake CLOSURE_LIB_ARCHIVE="${CROS_BINARY_STORE_DIR}/${CROS_BINARY_URI##*/}"
}

src_install() {
	overlay_zip="${EROOT}usr/local/factory/bundle/shopfloor/overlay.zip"
	if [ -e "$overlay_zip" ]; then
		make_par_args="--add-zip $overlay_zip"
	else
		make_par_args=
	fi

	emake DESTDIR="${D}" TARGET_DIR="${TARGET_DIR}" \
		PYTHON_SITEDIR="${EROOT}/$(python_get_sitedir)" \
		PYTHON="$(PYTHON)" \
		MAKE_PAR_ARGS="$make_par_args" \
		par install

	dosym ../../../../local/factory/py $(python_get_sitedir)/cros/factory

	# Replace chromeos-common.sh symlink with the real file
	cp --remove-destination "${S}/installer/chromeos-common.sh" \
		"${D}${TARGET_DIR}/bundle/factory_setup/lib/chromeos-common.sh" || die

	if use autotest && use build_tests; then
		# For now, point 'custom' to suite_Factory.  TODO(jsalz): Actually
		# install files directly into custom as appropriate.
		dosym ../autotest/client/site_tests/suite_Factory ${TARGET_DIR}/custom
		# We need to preserve the chromedriver and selenium library
		# (from chromeos-chrome pyauto test folder which is stripped by default)
		# for factory test images.
		local pyauto_path="/usr/local/autotest/client/deps/pyauto_dep"
		exeinto "$TARGET_DIR/bin/"
		doexe "${ROOT}$pyauto_path/test_src/out/Release/chromedriver"
		insinto "$TARGET_DIR/py/automation"
		doins -r "${ROOT}$pyauto_path/test_src/third_party/webdriver/pylib/selenium"
	fi

	# Directories used by Goofy.
	keepdir /var/factory/{,log,state,tests}

        # Make sure everything is group- and world-readable.
        chmod -R go=rX "${D}${TARGET_DIR}"
}

pkg_postinst() {
	python_mod_optimize ${TARGET_DIR}/py
	# Sanity check: make sure we can import stuff with only the
	# .par file.
	PYTHONPATH="${EROOT}/${TARGET_DIR}/bundle/shopfloor/factory.par" \
		"$(PYTHON)" -c "import cros.factory.test.state" || die
}
