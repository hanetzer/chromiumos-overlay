# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c5e14be9b5a38349bb10c3ea7625353aae62da38"
CROS_WORKON_TREE="b36cbb6be8d3f6bc9d55b43c68a0e0ee3399e9c6"
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
	+tests_audio_AlsaAPI
	+tests_audio_AlsaLoopback
	+tests_audio_Aplay
	+tests_audio_CRASFormatConversion
	+tests_audio_CrasLoopback
	+tests_audio_CrasOutputStress
	+tests_audio_LoopbackLatency
	+tests_audio_Microphone
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
