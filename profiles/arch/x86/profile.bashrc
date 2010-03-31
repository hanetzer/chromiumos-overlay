function print_ld_paths() {
  # Default library directories
  local paths="$SYSROOT/usr/lib:$SYSROOT/lib"

  # Only split on newlines
  local IFS="
"

  for line in $(cat "$SYSROOT"/etc/ld.so.conf
                    "$SYSROOT"/etc/ld.so.conf.d/* 2>/dev/null); do
    if [[ "${line:0:1}" != "/" ]]; then
      continue
    fi
    if [[ "${line:0:${#SYSROOT}}" == "$SYSROOT" ]]; then
      paths="$paths:$line"
    else
      paths="$paths:$SYSROOT$line"
    fi
  done
  echo "$paths"
}

function pre_src_test() {
  # Set LD_LIBRARY_PATH to point to libraries in $SYSROOT, so that tests
  # will load libraries from there first
  if [[ -n "$SYSROOT" ]] && [[ "$SYSROOT" != "/" ]]; then
    if [[ -n "$LD_LIBRARY_PATH" ]]; then
      export LD_LIBRARY_PATH="$(print_ld_paths):$LD_LIBRARY_PATH"
    else
      export LD_LIBRARY_PATH="$(print_ld_paths)"
    fi
  fi
}
