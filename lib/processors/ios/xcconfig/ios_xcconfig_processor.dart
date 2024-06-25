/*
 * Copyright (c) 2022 MyLittleSuite
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_flavorizr/extensions/extensions_map.dart';
import 'package:flutter_flavorizr/parser/models/flavorizr.dart';
import 'package:flutter_flavorizr/parser/models/flavors/flavor.dart';
import 'package:flutter_flavorizr/parser/models/flavors/ios/enums.dart';
import 'package:flutter_flavorizr/parser/models/flavors/ios/variable.dart';
import 'package:flutter_flavorizr/processors/commons/string_processor.dart';

class IOSXCConfigProcessor extends StringProcessor {
  final String _flavorName;
  final Flavor _flavor;
  final Target? _target;

  IOSXCConfigProcessor(
    this._flavorName,
    this._flavor,
    this._target, {
    String? input,
    required Flavorizr config,
  }) : super(
          input: input,
          config: config,
        );

  @override
  String execute() {
    StringBuffer buffer = StringBuffer();

    _appendIncludes(buffer);
    _appendBody(buffer);

    return buffer.toString();
  }

  void _appendIncludes(StringBuffer buffer) {
    buffer.writeln(
      '''#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.${_target!.value}-$_flavorName.xcconfig"''',
    );
    buffer.writeln('#include "Generated.xcconfig"');
  }

  void _appendBody(StringBuffer buffer) {
    print('===>firebase client id:${_flavor.ios.firebaseClientId}');

    final Map<String, Variable> variables = LinkedHashMap.from({
      'FLUTTER_TARGET': Variable(value: 'lib/main_$_flavorName.dart'),
      'ASSET_PREFIX': Variable(value: _flavorName),
      'BUNDLE_NAME': Variable(value: _flavorName.toUpperCase()),
      'BUNDLE_DISPLAY_NAME': Variable(value: _flavor.app.name),
      'BUNDLE_IDENTIFIER': Variable(value: _flavor.ios.bundleId),
      if (_flavor.ios.dynamicLinkPrefix != null)
        'DYNAMIC_LINK_PREFIX': Variable(value: _flavor.ios.dynamicLinkPrefix!),
      if (_flavor.ios.weLicenseCode != null)
        'WE_LICENSE_CODE': Variable(value: _flavor.ios.weLicenseCode!),
      if (_flavor.ios.firebaseClientId != null)
        'FIREBASE_CLIENT_ID': Variable(value: _flavor.ios.firebaseClientId!),
      if (_flavor.ios.reversedGoogleClientID != null)
        'REVERSED_GOOGLE_CLIENT_ID':
            Variable(value: _flavor.ios.reversedGoogleClientID!),
      if (_flavor.ios.facebookAppID != null)
        'FACEBOOK_APP_ID': Variable(value: _flavor.ios.facebookAppID!),
      if (_flavor.ios.facebookClientToken != null)
        'FACEBOOK_CLIENT_TOKEN':
            Variable(value: _flavor.ios.facebookClientToken!),
    })
      ..addAll(
        _flavor.ios.variables.where((_, variable) =>
            variable.target == null || variable.target == _target),
      );

    buffer.writeln();
    variables.forEach((key, variable) {
      buffer.writeln('$key=${variable.value}');
    });
  }

  @override
  String toString() => 'IOSXCConfigProcessor';
}
