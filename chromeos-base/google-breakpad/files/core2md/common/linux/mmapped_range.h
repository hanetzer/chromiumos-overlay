// Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef _COMMON_LINUX_MMAPPED_RANGE_H
#define _COMMON_LINUX_MMAPPED_RANGE_H

#include "google_breakpad/common/minidump_format.h"

// A range of a mmaped file.
class MMappedRange {
 public:
  MMappedRange(const void* data = NULL, size_t length = 0) {
    Set(data, length);
  }

  void Set(const void* data, size_t length) {
    data_ = reinterpret_cast<const uint8_t*>(data);
    length_ = length;
  }

  // Get an object of |length| bytes at |offset| and return a pointer to it
  // unless it's out of bounds.
  const void* GetObject(size_t offset, size_t length) const {
    // Check for overflow.
    if (offset + length < offset)
      return NULL;
    if (offset + length > length_)
      return NULL;
    return data_ + offset;
  }

  // Get element |index| of an array of objects of length |element_size|
  // starting at |offset| bytes. Return NULL if out of bounds.
  const void* GetArrayElement(size_t offset,
                              size_t element_size,
                              unsigned index) const {
    const size_t element_offset = offset + index * element_size;
    return GetObject(element_offset, element_size);
  }

  // Return a new range which is a subset of this range.
  MMappedRange Subrange(size_t data_offset, size_t data_size) const {
    if (data_offset > length_ ||
        data_offset + data_size < data_offset ||
        data_offset + data_size > length_) {
      return MMappedRange(NULL, 0);
    }

    return MMappedRange(data_ + data_offset, data_size);
  }

  MMappedRange Subrange(const MDLocationDescriptor& location) const {
    return Subrange(location.rva, location.data_size);
  }

  const uint8_t* data() const { return data_; }
  size_t length() const { return length_; }

 private:
  const uint8_t* data_;
  size_t length_;
};

#endif  // _COMMON_LINUX_MMAPPED_RANGE_H
