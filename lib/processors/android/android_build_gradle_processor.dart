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

import 'package:flutter_flavorizr/exception/malformed_resource_exception.dart';
import 'package:flutter_flavorizr/parser/models/config/android.dart';
import 'package:flutter_flavorizr/parser/models/flavorizr.dart';
import 'package:flutter_flavorizr/parser/models/flavors/android/res_value.dart';
import 'package:flutter_flavorizr/processors/commons/string_processor.dart';

class AndroidBuildGradleProcessor extends StringProcessor {
  static const String androidEntryPoint = 'android {';
  static const String flavorDimensions = 'flavorDimensions';
  static const String beginFlavorDimensionsMarkup =
      '// ----- BEGIN Flavors -----';
  static const String endFlavorDimensionsMarkup = '// ----- END Flavors -----';

  AndroidBuildGradleProcessor({
    String? input,
    required Flavorizr config,
  }) : super(
          input: input,
          config: config,
        );

  @override
  String execute() {
    final int androidPosition = input!.indexOf(androidEntryPoint);
    final int beginFlavorDimensionsMarkupPosition =
        input!.indexOf(beginFlavorDimensionsMarkup);
    final int endFlavorDimensionsMarkupPosition =
        input!.indexOf(endFlavorDimensionsMarkup);

    if (androidPosition < 0) {
      throw MalformedResourceException(input!);
    }

    StringBuffer buffer = StringBuffer();

    _cleanupFlavors(
      buffer,
      beginFlavorDimensionsMarkupPosition,
      endFlavorDimensionsMarkupPosition,
    );
    _appendStartContent(buffer, androidPosition);
    _appendFlavorsDimension(buffer);
    _appendFlavors(buffer);

    _appendEndContent(buffer, androidPosition);

    return buffer.toString();
  }

  void _cleanupFlavors(
    StringBuffer buffer,
    int beginFlavorDimensionsMarkupPosition,
    int endFlavorDimensionsMarkupPosition,
  ) {
    if (beginFlavorDimensionsMarkupPosition >= 0 &&
        endFlavorDimensionsMarkupPosition >= 0) {
      final String flavorDimensions = input!.substring(
        beginFlavorDimensionsMarkupPosition - 2,
        endFlavorDimensionsMarkupPosition +
            endFlavorDimensionsMarkup.length +
            4,
      );

      input = input!.replaceAll(flavorDimensions, '');
    }
  }

  void _appendStartContent(StringBuffer buffer, int androidPosition) {
    buffer.writeln(
        input!.substring(0, androidPosition + androidEntryPoint.length));
  }

  void _appendFlavorsDimension(StringBuffer buffer) {
    final flavorDimension =
        config.app?.android?.flavorDimensions ?? Android.kFlavorDimensionValue;

    buffer.writeln();
    buffer.writeln('    $beginFlavorDimensionsMarkup');
    buffer.writeln('    flavorDimensions "$flavorDimension"');
    buffer.writeln();
  }

  void _appendFlavors(StringBuffer buffer) {
    final flavorDimension =
        config.app?.android?.flavorDimensions ?? Android.kFlavorDimensionValue;

    buffer.writeln('    productFlavors {');

    config.flavors.forEach((name, flavor) {
      buffer.writeln('        $name {');
      buffer.writeln('            dimension "$flavorDimension"');
      buffer.writeln(
          '            applicationId "${flavor.android.applicationId}"');

      flavor.android.customConfig.forEach((key, value) {
        buffer.writeln('            $key $value');
      });

      final Map<String, ResValue> resValues = LinkedHashMap.from({
        'app_name': ResValue(
          type: 'string',
          value: flavor.app.name,
        )
      })
        ..addAll(flavor.android.resValues);
      resValues.forEach((key, res) {
        buffer.writeln(
            '            resValue "${res.type}", "$key", "${res.value}"');
      });

      buffer.writeln('        }');
    });

    buffer.writeln('    }');
    buffer.writeln();
  }

  void _appendEndContent(StringBuffer buffer, int androidPosition) {
    buffer.writeln('    $endFlavorDimensionsMarkup');
    buffer.write(
        input!.substring(androidPosition + androidEntryPoint.length + 1));
  }

  @override
  String toString() => 'AndroidBuildGradleProcessor';
}
