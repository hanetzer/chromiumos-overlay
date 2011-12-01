# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_PROJECT="chromium/src/base"

inherit cros-workon cros-debug toolchain-funcs

DESCRIPTION="Chrome base/ library extracted for use on Chrome OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="cros_host"

RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/nss
	x11-libs/gtk+"
DEPEND="${RDEPEND}
	dev-cpp/gtest
	cros_host? ( dev-util/scons )"

src_prepare() {
	ln -s "${S}" "${WORKDIR}/base" &> /dev/null

	mkdir -p "${WORKDIR}/build"
	cp -p "${FILESDIR}/build_config.h" "${WORKDIR}/build/." || die

	cp -p "${FILESDIR}/SConstruct" "${S}" || die
	epatch "${FILESDIR}"/gtest_include_path_fixup.patch
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	scons || die "third_party/chrome compile failed"
}

# insheaders <subdir> <headers>
# install all of the headers into /usr/include/base/subdir/,
# and find all of the headers in ${S}/subdir/.
insheaders() {
	local subdir="$1/"; shift
	insinto /usr/include/base/${subdir}
	doins "${@/#/${subdir}}" || die
}

src_install() {
	dolib.a libbase.a || die

	insheaders third_party/icu icu_utf.h

	insheaders third_party/nspr prtime.h

	insheaders third_party/valgrind valgrind.h

	insheaders third_party/dynamic_annotations dynamic_annotations.h

	insheaders . \
		at_exit.h \
		base_api.h \
		atomic_ref_count.h \
		atomic_sequence_num.h \
		atomicops.h \
		atomicops_internals_arm_gcc.h \
		atomicops_internals_x86_gcc.h \
		base_switches.h \
		basictypes.h \
		bind.h \
		bind_helpers.h \
		bind_internal.h \
		callback.h \
		callback_internal.h \
		callback_old.h \
		command_line.h \
		compiler_specific.h \
		eintr_wrapper.h \
		environment.h \
		file_descriptor_posix.h \
		file_path.h \
		file_util.h \
		file_util_deprecated.h \
		float_util.h \
		format_macros.h \
		gtest_prod_util.h \
		hash_tables.h \
		lazy_instance.h \
		logging.h \
		message_loop.h \
		message_loop_proxy.h \
		message_pump.h \
		message_pump_libevent.h \
		message_pump_glib.h \
		native_library.h \
		observer_list.h \
		pickle.h \
		platform_file.h \
		port.h \
		rand_util.h \
		safe_strerror_posix.h \
		scoped_ptr.h \
		stl_util-inl.h \
		string16.h \
		stringprintf.h \
		string_piece.h \
		string_tokenizer.h \
		string_number_conversions.h \
		string_split.h \
		string_util.h \
		string_util_posix.h \
		task.h \
		template_util.h \
		time.h \
		tracked.h \
		tuple.h \
		utf_string_conversion_utils.h \
		utf_string_conversions.h \
		values.h

	insheaders debug \
		debugger.h \
		stack_trace.h \
		trace_event.h \

	insheaders json \
		json_reader.h \
		json_writer.h \
		string_escape.h

	insheaders memory \
		raw_scoped_refptr_mismatch_checker.h \
		ref_counted.h \
		scoped_temp_dir.h \
		scoped_ptr.h \
		scoped_vector.h \
		singleton.h \
		weak_ptr.h

	insheaders synchronization \
		condition_variable.h \
		lock.h \
		lock_impl.h \
		waitable_event.h

	insheaders threading \
		non_thread_safe.h \
		non_thread_safe_impl.h \
		platform_thread.h \
		thread.h \
		thread_checker.h \
		thread_checker_impl.h \
		thread_local.h \
		thread_local_storage.h \
		thread_restrictions.h \
		thread_collision_warner.h

	insinto /usr/include/build
	doins "${WORKDIR}"/build/build_config.h || die
}
