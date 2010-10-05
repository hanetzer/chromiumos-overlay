# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Generate an XKB configuration file for Chromium OS.

The generated file will be used to configure modifier keys (ex. swap Alt and
Control keys.)
"""

__author__ = "yusukes"

import sys

KEY_STRING_TO_HUMAN_READABLE_NAME = {
    'search': 'Search',
    'leftcontrol': 'Left Control',
    'leftalt': 'Left Alt',
    'capslock': 'Caps Lock',
    'disabled': '"VoidSymbol" (= disabled)',
}

KEY_STRING_TO_KEYSYM = {
    'search': 'Super_L',
    'leftcontrol': 'Control_L',
    'leftalt': 'Alt_L, Meta_L',
    'capslock': 'Caps_Lock',
    'disabled': 'VoidSymbol',
}

KEY_STRING_TO_MODIFIER_NAME = {
    'search': 'Mod4',
    'leftcontrol': 'Control',
    'leftalt': 'Mod1',
    'capslock': 'Lock',
    # 'disabled' is not necessary.
}


def OutputRemapEntry(use_search_key_as, use_leftcontrol_key_as,
                     use_leftalt_key_as):
    """Outputs an XKB entry like this:

    // Search (Win-L) and CapsLock keys are mapped to Left Control.
    // Left Control key is mapped to Left Alt.
    // Left Alt key is mapped to Search.
    partial modifier_keys
    xkb_symbols "leftcontrol_leftalt_search" {
      key <LWIN> { [ Control_L ] };
      key <CAPS> { [ Control_L ] };
      key <LCTL> { [ Alt_L, Meta_L ] };
      key <LALT> { [ Super_L ] };
      modifier_map Mod4 { <LALT> };
      modifier_map Control { <LWIN>, <CAPS> };
      modifier_map Mod1 { <LCTL> };
    };

    Args:
    use_search_key_as: a string. 'search', 'leftcontrol', or 'leftalt'.
    use_leftcontrol_key_as: ditto.
    use_leftalt_key_as: ditto.
    """

    modifier_keys = {
        'search': [],
        'leftcontrol': [],
        'leftalt': [],
        'capslock': [],
        'disabled': [],
    }
    modifier_keys[use_search_key_as] += ['<LWIN>', '<CAPS>']
    modifier_keys[use_leftcontrol_key_as] += ['<LCTL>']
    modifier_keys[use_leftalt_key_as] += ['<LALT>']

    print ''
    print '// Search (Win-L) and CapsLock keys are mapped to %s.' % (
        KEY_STRING_TO_HUMAN_READABLE_NAME[use_search_key_as])
    print '// Left Control key is mapped to %s.' % (
        KEY_STRING_TO_HUMAN_READABLE_NAME[use_leftcontrol_key_as])
    print '// Left Alt key is mapped to %s.' % (
        KEY_STRING_TO_HUMAN_READABLE_NAME[use_leftalt_key_as])
    print 'partial modifier_keys'
    print 'xkb_symbols "%s_%s_%s" {' % (
        use_search_key_as, use_leftcontrol_key_as, use_leftalt_key_as)
    print '  key <LWIN> { [ %s ] };' % KEY_STRING_TO_KEYSYM[use_search_key_as]
    print '  key <CAPS> { [ %s ] };' % KEY_STRING_TO_KEYSYM[use_search_key_as]
    print '  key <LCTL> { [ %s ] };' % (
        KEY_STRING_TO_KEYSYM[use_leftcontrol_key_as])

    lalt = KEY_STRING_TO_KEYSYM[use_leftalt_key_as]
    # We have to overwrite both level-1 (default: Alt_L) and level-2
    # (default: Meta_L) mappings.
    if lalt.find(',') == -1:
      print '  key <LALT> { [ %s, %s ] };' % (lalt, lalt)
    else:
      print '  key <LALT> { [ %s ] };' % lalt
    for key in modifier_keys.keys():
        if key != 'disabled' and len(modifier_keys[key]) > 0:
            print '  modifier_map %s { %s };' % (
                KEY_STRING_TO_MODIFIER_NAME[key], ', '.join(modifier_keys[key]))
    print '};'


def main():
    key_strings = ['search', 'leftcontrol', 'leftalt', 'capslock', 'disabled']
    for use_search_key_as in key_strings:
        for use_leftcontrol_key_as in key_strings:
            for use_leftalt_key_as in key_strings:
                OutputRemapEntry(use_search_key_as, use_leftcontrol_key_as,
                                 use_leftalt_key_as)

if __name__ == '__main__':
  sys.exit(main())
