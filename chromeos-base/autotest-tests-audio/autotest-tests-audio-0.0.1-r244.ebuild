# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="36aaa77cb66b9250d1da2759aa29ddb1bfcb07ab"
CROS_WORKON_TREE="4a6284d694940ef2e57ad65ab49df782626702b0"
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
