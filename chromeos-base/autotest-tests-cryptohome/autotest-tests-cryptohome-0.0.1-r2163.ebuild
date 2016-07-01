# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a90282aa0f57396c44303256029dcee9ade94855"
CROS_WORKON_TREE="f5ee2f8ce1cb79d9f41a095adecb69b7c4f29020"
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
