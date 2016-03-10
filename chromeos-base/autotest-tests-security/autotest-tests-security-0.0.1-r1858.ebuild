# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="3420090a4f2ebbe0a76f52889a826c448b6a2716"
CROS_WORKON_TREE="6b9f0bee273a6c049f7eb33e2b6c9f5358231da4"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Security autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="-app_shell +autotest -chromeless_tty +seccomp"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	!chromeless_tty? (
		!app_shell? (
			+tests_security_EnableChromeTesting
			+tests_security_RendererSandbox
			+tests_security_RestartJob
		)
	)
	seccomp? (
		+tests_security_Minijail_seccomp
		+tests_security_SeccompSyscallFilters
	)
	+tests_security_AccountsBaseline
	+tests_security_AltSyscall
	+tests_security_ASLR
	+tests_security_ChromiumOSLSM
	+tests_security_DbusMap
	+tests_security_DbusOwners
	+tests_security_Firewall
	+tests_security_HardlinkRestrictions
	+tests_security_HtpdateHTTP
	+tests_security_Minijail0
	+tests_security_ModuleLocking
	+tests_security_mprotect
	+tests_security_OpenFDs
	+tests_security_OpenSSLBlacklist
	+tests_security_OpenSSLRegressions
	+tests_security_ProtocolFamilies
	+tests_security_ptraceRestrictions
	+tests_security_ReservedPrivileges
	+tests_security_RootCA
	+tests_security_RootfsOwners
	+tests_security_RootfsStatefulSymlinks
	+tests_security_RuntimeExecStack
	+tests_security_SandboxedServices
	+tests_security_StatefulPermissions
	+tests_security_SuidBinaries
	+tests_security_SymlinkRestrictions
	+tests_security_SysLogPermissions
	+tests_security_SysVIPC
	x86? ( +tests_security_x86Registers )
	amd64? ( +tests_security_x86Registers )
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
