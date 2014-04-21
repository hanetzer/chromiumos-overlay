# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("6f41e101b1cda04dbb29099bde9bf553bcdc39b7" "ef8cc1ad97a267903a6920d4a59154227c698e36")
CROS_WORKON_TREE=("0e6042bcd0e6726e058eeabd91623cae85c0be13" "7138119fbac6549792f50b88eb26e7de1671c19f")
CROS_WORKON_PROJECT=("chromiumos/platform/factory" "chromiumos/platform/installer")
CROS_WORKON_LOCALNAME=("factory" "installer")
CROS_WORKON_DESTDIR=("${S}" "${S}/installer")
CROS_WORKON_LOCALNAME="factory"

inherit cros-workon python cros-constants

CLOSURE_LIB_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/closure-library-20130212-95c19e7f0f5f.zip"
WEBGL_AQUARIUM_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/webgl-aquarium-20130524.tar.bz2"

DESCRIPTION="Chrome OS Factory Tools and Data"
HOMEPAGE="http://www.chromium.org/"
SRC_URI="${CLOSURE_LIB_URI}
	${WEBGL_AQUARIUM_URI}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="+autotest +build_tests -content_shell -chromeless_tty -ecs"

DEPEND="virtual/chromeos-interface
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
	dev-python/ws4py
	dev-util/stressapptest
	chromeos-base/audiotest
	chromeos-base/chromeos-factory-board
	chromeos-base/memento_softwareupdate
	>=chromeos-base/vpd-0.0.1-r11
	media-gfx/zbar
	media-sound/sox"

# Binaries from other packages (ex, chrome).
STRIP_MASK="*/chromedriver */selenium/*"

TARGET_DIR="/usr/local/factory"

src_unpack() {
	default
	cros-workon_src_unpack

	# Need to remove webgl_aquarium_static/ first because we have a README
	# file in it.
	local webgl_aquarium_path="${S}/py/test/pytests/webgl_aquarium_static"
	rm -rf ${webgl_aquarium_path}
	mv "${WORKDIR}/webgl_aquarium_static" "${webgl_aquarium_path%/*}" || die
}

src_compile() {
	emake CLOSURE_LIB_ARCHIVE="${DISTDIR}/${CLOSURE_LIB_URI##*/}"
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
		par install bundle

	# Sanity check: make sure we can import stuff with only the
	# .par file.
	PYTHONPATH="${D}${TARGET_DIR}/bundle/shopfloor/factory.par" \
		"$(PYTHON)" -c "import cros.factory.test.state" || die

	dosym ../../../../local/factory/py $(python_get_sitedir)/cros/factory

	# Replace chromeos-common.sh symlink with the real file
	cp --remove-destination "${S}/installer/share/chromeos-common.sh" \
		"${D}${TARGET_DIR}/bundle/factory_setup/lib/chromeos-common.sh" || die

	# Replace fmap.py symlink with the real file
	cp --remove-destination "${S}/py/gooftool/fmap.py" \
		"${D}${TARGET_DIR}/bundle/factory_setup/" || die

	# Directories used by Goofy.
	keepdir /var/factory/{,log,state,tests}

	# Install factory test enabled tag
	touch "${D}${TARGET_DIR}/enabled"

	# Make sure everything is group- and world-readable.
	chmod -R go=rX "${D}${TARGET_DIR}"
}

pkg_postinst() {
	python_mod_optimize ${TARGET_DIR}/py
}
