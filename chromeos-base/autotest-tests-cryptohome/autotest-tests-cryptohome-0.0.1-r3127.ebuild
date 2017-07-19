# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5a2cac10377d910d6d7f2553b99b595cb570dae2"
CROS_WORKON_TREE="31545d631ef01ef79fc187425f3b2004805a771a"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Cryptohome autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_platform_BootLockbox
	+tests_platform_CryptohomeBadPerms
	+tests_platform_CryptohomeChangePassword
	+tests_platform_CryptohomeFio
	+tests_platform_CryptohomeKeyEviction
	+tests_platform_CryptohomeMigrateKey
	+tests_platform_CryptohomeMount
	+tests_platform_CryptohomeMultiple
	+tests_platform_CryptohomeNonDirs
	+tests_platform_CryptohomeStress
	+tests_platform_CryptohomeTestAuth
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
