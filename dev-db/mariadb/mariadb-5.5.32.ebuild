# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/mariadb/mariadb-5.5.32.ebuild,v 1.1 2013/09/04 20:38:02 jmbsvicetto Exp $

EAPI="5"
MY_EXTRAS_VER="20130120-0100Z"

# Build system
BUILD="cmake"

inherit flag-o-matic toolchain-funcs mysql-v2
# only to make repoman happy. it is really set in the eclass
IUSE="$IUSE"

# REMEMBER: also update eclass/mysql*.eclass before committing!

# The cross-compile logic is broken.
# The patch mariadb-5.5.32-workaround-cros-build.patch is a workaround.
KEYWORDS="-* amd64 x86"

# When MY_EXTRAS is bumped, the index should be revised to exclude these.
EPATCH_EXCLUDE=''

DEPEND="|| ( >=sys-devel/gcc-3.4.6 >=sys-devel/gcc-apple-4.0 )"
RDEPEND="${RDEPEND}
	dev-libs/libaio
	sys-devel/binutils
"

# Please do not add a naive src_unpack to this ebuild
# If you want to add a single patch, copy the ebuild to an overlay
# and create your own mysql-extras tarball, looking at 000_index.txt

# Official test instructions:
# USE='berkdb -cluster embedded extraengine perl ssl community' \
# FEATURES='test userpriv -usersandbox' \
# ebuild mariadb-X.X.XX.ebuild \
# digest clean package
src_test() {

	local TESTDIR="${CMAKE_BUILD_DIR}/mysql-test"
	local retstatus_unit
	local retstatus_tests

	# Bug #213475 - MySQL _will_ object strenously if your machine is named
	# localhost. Also causes weird failures.
	[[ "${HOSTNAME}" == "localhost" ]] && die "Your machine must NOT be named localhost"

	if ! use "minimal" ; then

		if [[ $UID -eq 0 ]]; then
			die "Testing with FEATURES=-userpriv is no longer supported by upstream. Tests MUST be run as non-root."
		fi
		has usersandbox $FEATURES && eerror "Some tests may fail with FEATURES=usersandbox"

		einfo ">>> Test phase [test]: ${CATEGORY}/${PF}"
		addpredict /this-dir-does-not-exist/t9.MYI

		# Run CTest (test-units)
		cmake-utils_src_test
		retstatus_unit=$?
		[[ $retstatus_unit -eq 0 ]] || eerror "test-unit failed"

		# Ensure that parallel runs don't die
		export MTR_BUILD_THREAD="$((${RANDOM} % 100))"

		# create directories because mysqladmin might right out of order
		mkdir -p "${S}"/mysql-test/var-tests{,/log}

		# These are failing in MySQL 5.5 for now and are believed to be
		# false positives:
		#
		# main.information_schema, binlog.binlog_statement_insert_delayed,
		# main.mysqld--help, funcs_1.is_triggers, funcs_1.is_tables_mysql,
		# funcs_1.is_columns_mysql
		# fails due to USE=-latin1 / utf8 default
		#
		# main.mysql_client_test, main.mysql_client_test_nonblock:
		# segfaults at random under Portage only, suspect resource limits.
		#
		# sys_vars.plugin_dir_basic
		# fails because PLUGIN_DIR is set to MYSQL_LIBDIR64/plugin
		# instead of MYSQL_LIBDIR/plugin
		#
		# main.flush_read_lock_kill
		# fails because of unknown system variable 'DEBUG_SYNC'
		#
		# main.openssl_1
		# error message changing
		# -mysqltest: Could not open connection 'default': 2026 SSL connection
		#  error: ASN: bad other signature confirmation
		# +mysqltest: Could not open connection 'default': 2026 SSL connection
		#  error: error:00000001:lib(0):func(0):reason(1)
		#
		# plugins.unix_socket
		# fails because portage strips out the USER enviornment variable
		#

		for t in main.mysql_client_test main.mysql_client_test_nonblock \
			binlog.binlog_statement_insert_delayed main.information_schema \
			main.mysqld--help main.flush_read_lock_kill \
			sys_vars.plugin_dir_basic main.openssl_1 plugins.unix_socket \
			funcs_1.is_triggers funcs_1.is_tables_mysql funcs_1.is_columns_mysql ; do
				mysql-v2_disable_test  "$t" "False positives in Gentoo"
		done

		# Run mysql tests
		pushd "${TESTDIR}"

		# run mysql-test tests
		perl mysql-test-run.pl --force --vardir="${S}/mysql-test/var-tests"
		retstatus_tests=$?
		[[ $retstatus_tests -eq 0 ]] || eerror "tests failed"
		has usersandbox $FEATURES && eerror "Some tests may fail with FEATURES=usersandbox"

		popd

		# Cleanup is important for these testcases.
		pkill -9 -f "${S}/ndb" 2>/dev/null
		pkill -9 -f "${S}/sql" 2>/dev/null

		failures=""
		[[ $retstatus_unit -eq 0 ]] || failures="${failures} test-unit"
		[[ $retstatus_tests -eq 0 ]] || failures="${failures} tests"
		has usersandbox $FEATURES && eerror "Some tests may fail with FEATURES=usersandbox"

		[[ -z "$failures" ]] || die "Test failures: $failures"
		einfo "Tests successfully completed"

	else

		einfo "Skipping server tests due to minimal build."
	fi
}

src_configure() {
	epatch "${FILESDIR}"/${P}-workaround-cros-build.patch

	# Append the SYSROOT Library Path in order for the linker to find
	# libbfd when cross-compiling. See crbug.com/336580 for more details.
	append-ldflags "-L${SYSROOT}/usr/${CHOST}/lib"

	# Use -levent_core instead of -levent as upstream is splitting the libs.
	sed -i '/FIND_LIBRARY.EVENT_LIBRARY/s:event):event_core):' tests/CMakeLists.txt

	# Fix cross-compiling as the build requires this.
	MYCMAKEARGS="-DSTACK_DIRECTION=-1"

	mysql-v2_src_configure
}

mysql-v2_pkg_setup() {
	# Override mysql-v2_pkg_setup so that we use the GID/UID as defined in
	# the profile rather than the eclass.
	enewgroup mysql 245 || die "problem adding 'mysql' group"
	enewuser mysql 245 -1 /dev/null mysql || die "problem adding 'mysql' user"
}
