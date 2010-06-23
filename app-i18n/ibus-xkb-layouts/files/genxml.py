#! /usr/bin/python
# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Pre-generate XML data of XKB layout engines.
#
# By default, ibus-engine-xkb-layouts generates the XML data at runtime in
# xkb-layouts.xml:
#
#   <engines exec="/usr/libexec/ibus-engine-xkb-layouts --xml">
#
# As of writing, this generates XML data of 176KB. In Chromium OS, we
# don't use most of the keyboard layouts, so it's wasteful to parse the
# large XML data. Besides, running a command is also a bit expensive.
#
# The script is used to pre-generate compact XML data at build time, with
# all the unnecessary keyboard layouts stripped.
#
# WARNING:
# This scripts has to be compatible with output from
# "ibus-engine-xkb-layouts --xml". When the logic in ibus-engine-xkb-layouts is
# changed, the script has to be updated as well.
#
# To check the output matches, do the followigns in chroot:
# $ /build/x86-generic/usr/libexec/ibus-engine-xkb-layouts --xml \
#   > /tmp/original.out
# $ cd ~/trunk/src/third_party/chromiumos-overlay/app-i18n/ibus-xkb-layouts
# $ python files/genxml.py > /tmp/genxml.out
# $ diff /tmp/original.out /tmp/genxml.out

import StringIO
import fileinput
import optparse
import re
import sys
import xml.dom.minidom
import xml.sax.saxutils


def Escape(xml_text):
  """Escapes the given XML text."""
  xml_text = xml.sax.saxutils.escape(xml_text)
  # Escape apostrophes to be compatible with output from
  # "ibus-engine-xkb-layouts --xml".
  return re.sub(r"'", '&apos;', xml_text)

def ExtractWhitelist(file_name):
  """Extracts the whitelist from the given C header file."""
  xkb_whitelist = set()
  for line in fileinput.input(file_name):
    # Extract the xkb engine name from lines like:
    #   "xkb:us::eng",        // US - English
    match = re.search(r'"(xkb:.*?)"', line)
    if match:
      xkb_whitelist.add(match.group(1))
  return xkb_whitelist


def ParseConfigItem(configItem):
  """Parses configItem element."""
  names = configItem.getElementsByTagName('name')
  descriptions = configItem.getElementsByTagName('description')
  name = names[0].childNodes[0].data if names else ''
  description = descriptions[0].childNodes[0].data if descriptions else ''
  languages = []
  for languageList in configItem.getElementsByTagName('languageList'):
    for iso639Id in languageList.getElementsByTagName('iso639Id'):
      languages.append(iso639Id.childNodes[0].data)
  return [name, description, languages]


def PrintEngines(output, layout_name, layout_description,
                 variant_name, variant_description, languages,
                 xkb_whitelist):
  """Print engine descriptions as XML."""
  for language in languages:
    engine_name = 'xkb:%s:%s:%s' % (layout_name, variant_name, language)
    # If the whitelist is given, and the engine name is not in the list,
    # skip it.
    if xkb_whitelist and not engine_name in xkb_whitelist:
      continue
    # Adds special hotkey on Japanese keyboard to activate English input
    # TODO(suzhe): make sure the corresponding key on ChromeOS device generates
    # the same key symbol.
    engine_hotkeys = 'Eisu_toggle' if language == 'eng' else ''

    engine_longname = layout_description
    if variant_description:
      engine_longname = '%s - %s' % (layout_description, variant_description)

    engine_layout = layout_name
    if variant_name:
      engine_layout = '%s(%s)' % (layout_name, variant_name)

    rank = 0
    if layout_name == 'us' and not variant_name:
      rank = 100

    print >>output, '        <engine>'
    print >>output, '            <name>%s</name>' % Escape(engine_name)
    print >>output, '            <longname>%s</longname>' % (
      Escape(engine_longname.encode('utf-8')))
    print >>output, '            <description></description>'
    print >>output, '            <language>%s</language>' % Escape(language)
    print >>output, '            <license></license>'
    print >>output, '            <author></author>'
    print >>output, '            <icon></icon>'
    print >>output, '            <layout>%s</layout>' % Escape(engine_layout)
    print >>output, '            <hotkeys>%s</hotkeys>' % engine_hotkeys
    print >>output, '            <rank>%d</rank>' % rank
    print >>output, '        </engine>'


def ParseXkbRulesXml(output, file_name, xkb_whitelist):
  """Parses the XKB rules file such as evdev.xml and xorg.xml."""
  print >>output, '<engines>'
  dom = xml.dom.minidom.parse(file_name)
  for layout in dom.getElementsByTagName('layout'):
    # Don't call getElementsByTagName('configItem') here as it extracts
    # <configItem> elements inside <variantList>.
    for childNode in layout.childNodes:
      if childNode.nodeName == 'configItem':
        configItem = childNode
        layout_name, layout_description, layout_languages = (
            ParseConfigItem(configItem))
        PrintEngines(output, layout_name, layout_description,
                     '', '', layout_languages, xkb_whitelist)
    for variantList in layout.getElementsByTagName('variantList'):
      for configItem in variantList.getElementsByTagName('configItem'):
        variant_name, variant_description, variant_languages = (
            ParseConfigItem(configItem))
        PrintEngines(output, layout_name, layout_description,
                     variant_name, variant_description,
                     (variant_languages or layout_languages),
                     xkb_whitelist)
  print >>output, '</engines>'


def RewriteComponentXml(file_name, engines_xml):
  """RewriteComponentXmls <engines> element in xkb-layouts.xml."""
  output = StringIO.StringIO()
  for line in fileinput.input(file_name):
    if re.search(r'<engines exec=', line):
      output.write(engines_xml)
    else:
      output.write(line)
  file(file_name, 'w').write(output.getvalue())

def main():
  parser = optparse.OptionParser(usage='Usage: %prog [options]')
  parser.add_option('--xkbrules', dest='xkbrules', default=None,
                    help='Use the xkbrules file (like evdev.xml)')
  parser.add_option('--whitelist', dest='whitelist', default=None,
                    help='Use the whitelist file (C++ header)')
  parser.add_option('--rewrite', dest='rewrite', default=None,
                    help='Rewrite the IBus XML component file')
  (options, args) = parser.parse_args()

  xkb_whitelist = None
  if options.whitelist:
    xkb_whitelist = ExtractWhitelist(options.whitelist)
  if not options.xkbrules:
    print '--xkbrules has to be specified'
    sys.exit(1)
  output = StringIO.StringIO()
  ParseXkbRulesXml(output, options.xkbrules, xkb_whitelist)
  if options.rewrite:
    RewriteComponentXml(options.rewrite, output.getvalue())
  else:
    sys.stdout.write(output.getvalue())

if __name__ == '__main__':
  main()

