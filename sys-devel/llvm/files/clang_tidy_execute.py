#!/usr/bin/env python2
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""For executing subcommands."""

from __future__ import print_function

import os
import signal
import subprocess
import tempfile
import threading

_BUFFER_SIZE = 1


class ExecOutput(object):
  """The results of any Execute operation.

  Attributes:
    returncode: The return code for the process.
    cmd: The actual command that was run.  This may include extra
      arguments that were not asked for but needed for proper
      operation, like shell wrappers.
    cwd: Current working directory.
    rawcmd: The command that was asked to be run.
    stdout: The stdout of the command.
    sdterr: The stderr of the command.
  """

  def __init__(self,
               returncode,
               cmd=None,
               cwd=None,
               stdout=None,
               stderr=None,
               rawcmd=None):
    self.returncode = returncode
    self.cmd = cmd
    self.cwd = cwd
    self.rawcmd = rawcmd
    self.stdout = stdout
    self.stderr = stderr

class _Muxer(threading.Thread):
  """A single thread that reads and collects both mixed and unmixed output."""

  def __init__(self, unmixed, mixed, lock):
    """Create  a new _Muxer.

    Args:
      unmixed: The stream to write unmixed content to.
      mixed: The stream to write mixed content to.
      lock: The lock to use to protect access to the mixed content.
    """
    threading.Thread.__init__(self)
    self._unmixed = unmixed
    self._mixed = mixed
    self._lock = lock
    self._buffer = ''
    (self._reader, self.writer) = os.pipe()
    self._complete_event = threading.Event()

  def _ProcessData(self, data):
    """Buffer the data and emit it when we reach a full line."""
    # Append the data to the buffer
    self._buffer += data
    # If newline, flush the buffer.
    if data == '\n':
      self._FlushBuffer()

  def run(self):
    data = os.read(self._reader, _BUFFER_SIZE)
    while data:
      self._ProcessData(data)
      data = os.read(self._reader, _BUFFER_SIZE)
    # The underlying filehandle has been closed, so there is no more
    # data to read.  Flush any data we still have in the buffer to our
    # files, and then have the os flush the data to disk.  This will
    # ensure anybody trying to read the data later has it all.
    self._FlushBuffer()
    self._unmixed.flush()
    with self._lock:
      self._mixed.flush()


  def _FlushBuffer(self):
    if self._buffer:
      self._unmixed.write(self._buffer)
      # The mixed buffer is shared between Muxers, so requires a lock.
      with self._lock:
        self._mixed.write(self._buffer)
      self._buffer = ''

  def Stop(self):
    """Stop the muxer, and wait for the background thread to complete."""
    # Closing the self.writer will cause the os.read() inside run to
    # return EOF, which will cause the thread to exit.
    os.close(self.writer)
    self.join()
    os.close(self._reader)


class _CommandOutputMuxer(object):
  """A context to use when collecting stdout/stderr logs.

  This class provides an easy way to manage collecting logs from a
  process.  It provides ways to collect stdout, stderr, and a mixed
  log which intermixes stdout and stderr.
  """

  def __init__(self, stdout=None, stderr=None, mixed=None):
    """Create a new _CommandOutputMuxer.

    Args:
      stdout: The file stream used to collect stdout.
      stderr: The file stream used to collect stderr.
      mixed: The file stream used to collect the mixed stdout/stderr output.
    """
    self._stdout = stdout or tempfile.TemporaryFile(mode='w+')
    self._stdout_offset = self._stdout.tell()
    self._stderr = stderr or tempfile.TemporaryFile(mode='w+')
    self._stderr_offset = self._stderr.tell()
    self._mixed = mixed or tempfile.TemporaryFile(mode='w+')

    self._mixed_lock = threading.Lock()

    self._stdout_muxer = _Muxer(
        unmixed=self._stdout, mixed=self._mixed, lock=self._mixed_lock)
    self._stderr_muxer = _Muxer(
        unmixed=self._stderr, mixed=self._mixed, lock=self._mixed_lock)

  def Run(self, command, timeout, **kwargs):
    """Wrapper method for running the command.

    This allows CommandOutputMuxer to better control the lifecycle of
    the underlying command to make sure data is buffered correctly and
    everything is cleaned up.

    Args:
      command: The command to run
      timeout: How long (in seconds) to wait for the command to
               finish, or 0 to wait forever
      **kwargs: Arguments to pass to subprocess.Popen()

    Returns:
      Command return code.

    Raises:
      TimeoutException: If the command takes too long to execute.
    """
    # Specify some local args that are required for this class to work.
    local_args = dict(
        args=command,
        close_fds=True,
        stdin=subprocess.PIPE,
        stdout=self._stdout_muxer.writer,
        stderr=self._stderr_muxer.writer)
    local_args.update(**kwargs)

    p = subprocess.Popen(**local_args)
    p.stdin.close()
    try:
      return _PopenWaitWithTimeout(p, timeout)
    finally:
      # Now that we are done running, stop the background threads to
      # ensure that all the data they are collecting is properly
      # collected and buffered to disk before we return
      self._stdout_muxer.Stop()
      self._stderr_muxer.Stop()

  def _Read(self, fh, offset):
    fh.seek(offset)
    data = fh.read()
    return data

  def ReadStdout(self):
    return self._Read(self._stdout, self._stdout_offset)

  def ReadStderr(self):
    return self._Read(self._stderr, self._stderr_offset)

  def __enter__(self):
    self._stdout_muxer.start()
    self._stderr_muxer.start()
    return self

  def __exit__(self, exc_type, exc_value, traceback):
    exc_type = exc_type  # unused
    exc_value = exc_value  # unused
    traceback = traceback  # unused

    self._stdout.close()
    self._stderr.close()
    self._mixed.close()


class TimeoutException(Exception):
  """Raised when an Execute call times out."""


# This error code is the same code that alarm returns on linux for
# timeout.
TIMEOUT_ERROR_CODE = 142


def _PopenWaitWithTimeout(process, timeout):
  """Do Popen.wait, but with a timeout.

  Args:
    process: the Popen object itself.
    timeout: How long to wait.

  Returns:
    The error code from the child process

  Raises:
    TimeoutException: if the command takes too long.
  """

  def Kill():
    print('Killing process %d after %s seconds', process.pid, timeout)
    # process.termiante doesn't seem to always kill the process.  This
    # uses the same method the alarm command used.
    pgid = os.getpgid(process.id)
    os.killpg(pgid, signal.KILL)

  timer = threading.Timer(timeout, Kill)
  timer.start()
  try:
    returncode = process.wait()
  finally:
    if timer.is_alive():
      timer.cancel()
    else:
      raise TimeoutException()
  return returncode


def ExecuteWithTimeout(cmd, timeout, cwd=None, env=None, ignore_output=False):
  """Execute a command from shell.

  Args:
    cmd: A string command to be executed.
    timeout: How many seconds to wait, or forever if not specified
    cwd: The current working directory, or buildbot_root if not specified.
    env: A dict for the envrionment to pass to the subprocess.
    ignore_output: If specified, ExecOuput.stderr and
                   ExecOutput.stdout are not collected nor returned to
                   the caller.  This is useful in cases where
                   stdout/stderr are known to be huge, or in cases
                   where the caller knows it doesn't need the output.

  Returns:
    ExecOutput object with results of command
  """
  return _Execute(
      cmd=cmd, cwd=cwd, env=env, timeout=timeout, ignore_output=ignore_output)


def Execute(cmd, cwd=None, env=None, ignore_output=False):
  """Execute a command from shell.

  Args:
    cmd: A string command to be executed.
    cwd: The current working directory, or buildbot_root if not specified.
    env: A dict for the envrionment to pass to the subprocess.
    ignore_output: If specified, ExecOuput.stderr and
                   ExecOutput.stdout are not collected nor returned to
                   the caller.  This is useful in cases where
                   stdout/stderr are known to be huge, or in cases
                   where the caller knows it doesn't need the output.

  Returns:
    ExecOutput object with results of command
  """
  return _Execute(cmd=cmd, cwd=cwd, env=env, ignore_output=ignore_output)


def ExecuteWithTimeoutAndLogfile(cmd,
                                 timeout,
                                 logfile,
                                 cwd=None,
                                 env=None,
                                 ignore_output=False):
  """Execute a command from shell with a timeout and logfile.

  The logfile in this function is a mixture of stdout and stderr from
  the command.  Since the results are written out to a logfile, stdout
  and stderr are NOT available from the ExecOutput returned from this
  function.

  Args:
    cmd: A string command to be executed.
    timeout: How many seconds to wait, or forever if not specified
    logfile: Where to stdout and stderr from the command.
    cwd: The current working directory, or buildbot_root if not specified.
    env: A dict for the envrionment to pass to the subprocess.
    ignore_output: If specified, ExecOuput.stderr and
                   ExecOutput.stdout are not collected nor returned to
                   the caller.  This is useful in cases where
                   stdout/stderr are known to be huge, or in cases
                   where the caller knows it doesn't need the output.

  Returns:
    ExecOutput object with results of command
  """
  return _Execute(
      cmd=cmd,
      cwd=cwd,
      env=env,
      timeout=timeout,
      logfile=logfile,
      ignore_output=ignore_output)

def ExecuteWithLogfile(cmd, logfile, cwd=None, env=None, ignore_output=False):
  """Execute a command from shell with a logfile.

  The logfile in this function is a mixture of stdout and stderr from
  the command.  Since the results are written out to a logfile, stdout
  and stderr are NOT available from the ExecOutput returned from this
  function.

  Args:
    cmd: A string command to be executed.
    logfile: Where to stdout and stderr from the command.  If
        specified, the results of stdout and stderr are not provided
        in the result of this call.  Keep in mind that if you don't
        specify a logfile, the results are read back into memory.
    cwd: The current working directory, or buildbot_root if not specified.
    env: A dict for the envrionment to pass to the subprocess.
    ignore_output: If specified, ExecOuput.stderr and
                   ExecOutput.stdout are not collected nor returned to
                   the caller.  This is useful in cases where
                   stdout/stderr are known to be huge, or in cases
                   where the caller knows it doesn't need the output.

  Returns:
    ExecOutput object with results of command
  """
  return _Execute(
      cmd=cmd, cwd=cwd, env=env, logfile=logfile, ignore_output=ignore_output)


def ExecuteWithTimeoutAndStderrLogfile(cmd,
                                       timeout,
                                       logfile,
                                       stderr_logfile,
                                       cwd=None,
                                       env=None,
                                       ignore_output=False):
  """Execute a command from shell with logfiles and a timeout.

  The logfile in this function is a mixture of stdout and stderr from
  the command.  The stderr_logfile just contains the stderr output.
  Since the results are written out to logfiles, stdout and stderr are
  NOT available from the ExecOutput returned from this function.

  Args:
    cmd: A string command to be executed.
    timeout: How many seconds to wait, or forever if not specified
    logfile: Where to stdout and stderr from the command.
    stderr_logfile: Where to log stderr from the command.
    cwd: The current working directory, or buildbot_root if not specified.
    env: A dict for the envrionment to pass to the subprocess.
    ignore_output: If specified, ExecOuput.stderr and
                   ExecOutput.stdout are not collected nor returned to
                   the caller.  This is useful in cases where
                   stdout/stderr are known to be huge, or in cases
                   where the caller knows it doesn't need the output.

  Returns:
    ExecOutput object with results of command
  """
  return _Execute(
      cmd=cmd,
      cwd=cwd,
      env=env,
      timeout=timeout,
      logfile=logfile,
      stderr_logfile=stderr_logfile,
      ignore_output=ignore_output)



def ExecuteWithStderrLogfile(cmd, logfile, stderr_logfile, cwd=None, env=None):
  """Execute a command from shell with logfiles and a timeout.

  The logfile in this function is a mixture of stdout and stderr from
  the command.  The stderr_logfile just contains the stderr output.
  Since the results are written out to logfiles, stdout and stderr are
  NOT available from the ExecOutput returned from this function.

  Args:
    cmd: A string command to be executed.
    logfile: Where to stdout and stderr from the command.
    stderr_logfile: Where to log stderr from the command.
    cwd: The current working directory, or buildbot_root if not specified.
    env: A dict for the envrionment to pass to the subprocess.

  Returns:
    ExecOutput object with results of command
  """
  return _Execute(
      cmd=cmd, cwd=cwd, env=env, logfile=logfile, stderr_logfile=stderr_logfile)

# It's nice to have all the different ways of calling Exceute
# implemented here inside this function.  Except with all it's options
# and flags and stuff, it exposes a pretty bad API interface.  So
# rather than inflict that on the rest of the buildbot, we'll wrap
# this ugly API into nicer APIs above.
def _Execute(cmd,
             cwd=None,
             env=None,
             timeout=None,
             logfile=None,
             stderr_logfile=None,
             raise_on_timeout=False,
             ignore_output=False):
  """Execute a command from shell and returns the result.

  Args:
    cmd: A string command to be executed.
    cwd: The current working directory, or buildbot_root if not specified.
    env: A dict for the envrionment to pass to the subprocess.
    timeout: How many seconds to wait, or forever if not specified
    logfile: Where to stdout and stderr from the command.  If
        specified, the results of stdout and stderr are not provided
        in the result of this call.  Keep in mind that if you don't
        specify a logfile, the results are read back into memory.
    stderr_logfile: Where to log stderr from the command.  Requires
        logfile to be set.
    raise_on_timeout: controls if we raise TimeoutException on timeout
        or return TIMEOUT_ERROR_CODE.
    ignore_output: If specified, ExecOuput.stderr and
                   ExecOutput.stdout are not collected nor returned to
                   the caller.  This is useful in cases where
                   stdout/stderr are known to be huge, or in cases
                   where the caller knows it doesn't need the output.

  Returns:
    ExecOutput object with results of command

  Raises:
    TimeoutException: if timeout specified and command did not
        complete in time if raise_on_timeout is true.
  """
  cwd = cwd or os.getcwd()

  # Python provides no way to override which shell is used for
  # shell=True (it uses /bin/sh by default), so we'll override it here
  # to ensure we use bash.
  command = ['/bin/bash', '-c', cmd]
  info_line = 'Executing: %s from %s\n' % (command, cwd)
  print(info_line)

  # Default values
  stdout = None
  stderr = None
  if logfile:
    # Open stdout and write header line
    stdout = open(logfile, 'a+')
    stdout.write(info_line)
    stdout.flush()

    # If also log stderr to it's own logfile, set that up here.
    if stderr_logfile:
      stderr = open(stderr_logfile, 'a+')
      # Seek to end of file.  _CommandOutputMuxer assumes the
      # filehandle's offset is already at the end.  It turns out that
      # when opening a file in 'a', the offset isn't set until data is
      # written.
      stderr.seek(0, 2)

  with _CommandOutputMuxer(mixed=stdout, stderr=stderr) as mux:
    try:
      returncode = mux.Run(command=command, timeout=timeout, env=env, cwd=cwd)
    except TimeoutException as e:
      if raise_on_timeout:
        raise e
      returncode = TIMEOUT_ERROR_CODE

    info_line = 'Return Code: %d' % returncode
    print(info_line)
    if stdout:
      stdout.write(info_line + '\n')

    # Setup stdout and stderr for returning to the caller.  Note that
    # stdout is explicitly JUST stdout here and not the mixed output.
    # This enables callers to easily be able to run a command and
    # parse the results without having to worry about whatever the
    # command put on stderr.
    stdout_return = None if ignore_output else mux.ReadStdout()
    stderr_return = None if ignore_output else mux.ReadStderr()

    return ExecOutput(
        cmd=command,
        rawcmd=cmd,
        cwd=cwd,
        returncode=returncode,
        stdout=stdout_return,
        stderr=stderr_return)
