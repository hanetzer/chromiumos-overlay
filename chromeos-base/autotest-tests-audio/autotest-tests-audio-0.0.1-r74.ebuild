# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="197b62b2d4e82fa42329f9325602c0d4c5cd92cf"
CROS_WORKON_TREE="09c4424b8a8bd5233622f4f9262e3e772dfc854d"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Audio autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	chromeos-base/audiotest
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_sound_infrastructure
	+tests_audio_AlsaLoopback
	+tests_audio_Aplay
	+tests_audio_CRASFormatConversion
	+tests_audio_CrasLoopback
	+tests_audio_LoopbackLatency
	+tests_audio_Microphone
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
