import 'package:flutter_flavorizr/parser/models/flavorizr.dart';
import 'package:flutter_flavorizr/parser/models/flavors/flavor.dart';
import 'package:flutter_flavorizr/parser/models/flavors/ios/enums.dart';
import 'package:flutter_flavorizr/processors/commons/string_processor.dart';

class IOSPbxprojProcessor extends StringProcessor {
  static const String teamIDEntryPoint = 'DEVELOPMENT_TEAM';
  static const String provProfileEntryPoint = 'PROVISIONING_PROFILE_SPECIFIER';
  static const String productBundleId = 'PRODUCT_BUNDLE_IDENTIFIER';
  static const List<String> entryPoints = [
    teamIDEntryPoint,
    provProfileEntryPoint,
    productBundleId,
  ];
  static const serviceExtension = 'ServiceExtension';
  static const contentExtension = 'ContentExtension';
  static const List<String> extensionTargets = [
    serviceExtension,
    contentExtension,
  ];

  String _target(String target) =>
      target.substring(0, 1).toUpperCase() + target.substring(1);

  IOSPbxprojProcessor({
    String? input,
    required Flavorizr config,
  }) : super(input: input, config: config);

  @override
  String execute() {
    StringBuffer buffer = StringBuffer();

    for (final entryPoint in entryPoints) {
      for (final target in Target.values) {
        for (final flavor in config.flavors.entries) {
          for (final extension in extensionTargets) {
            final entryPointPos = _appendStartContent(
              buffer,
              flavor.key,
              target.value,
              entryPoint,
              extension,
            );
            final int baseConfigPos;
            baseConfigPos = input!.indexOf(
              RegExp(
                _getBaseConfigEntryPointValue(
                  entryPoint: entryPoint,
                  target: target.value,
                  flavorName: flavor.key,
                  extensionTarget: extension,
                ),
              ),
            );

            input = input!.substring(baseConfigPos);

            buffer.write(
              '$entryPoint = "${_getValue(entryPoint, flavor.value, extension)}";',
            );

            _appendEndContent(buffer, entryPointPos);

            input = buffer.toString();
            buffer.clear();
          }
        }
      }
    }

    return input!;
  }

  @override
  String toString() => 'IOSPbxprojProcessor';

  int _appendStartContent(
    StringBuffer buffer,
    String flavorName,
    String target,
    String entryPoint,
    String? extensionTarget,
  ) {
    final baseConfigPos = input!.indexOf(
      RegExp(
        _getBaseConfigEntryPointValue(
          entryPoint: entryPoint,
          flavorName: flavorName,
          target: target,
          extensionTarget: extensionTarget,
        ),
      ),
    );

    final startContent = input!.substring(0, baseConfigPos);
    final endContent = input!.substring(baseConfigPos);

    final int entryPointPos = endContent.indexOf(entryPoint);

    buffer.write(startContent);

    buffer.write(endContent.substring(0, entryPointPos));

    return entryPointPos;
  }

  String _getBaseConfigEntryPointValue({
    required String entryPoint,
    required String target,
    required String flavorName,
    String? extensionTarget = '',
  }) {
    if (entryPoint == productBundleId) {
      return 'baseConfigurationReference = (.*)Pods-$extensionTarget.${target.toLowerCase()}-$flavorName.xcconfig \\*/;';
    } else if (entryPoint == provProfileEntryPoint) {
      final targetValue = RegExp.escape(flavorName) +
          RegExp.escape(_target(target)) +
          r'|' +
          r'Pods-' +
          RegExp.escape(extensionTarget ?? '') +
          r'\.' +
          RegExp.escape(target.toLowerCase()) +
          r'-' +
          RegExp.escape(flavorName);

      return 'baseConfigurationReference = (.*)$targetValue.xcconfig \\*/;';
    } else {
      return 'baseConfigurationReference = (.*)$flavorName${_target(target)}.xcconfig \\*/;';
    }
  }

  void _appendEndContent(StringBuffer buffer, int entryPointPos) {
    final int end = input!.substring(entryPointPos).indexOf(';') + 1;
    buffer.write(input!.substring(entryPointPos + end));
  }

  String _getValue(String entryPoint, Flavor flavor, String extensionTarget) {
    switch (entryPoint) {
      case teamIDEntryPoint:
        return flavor.ios.teamID;
      case provProfileEntryPoint:
        return flavor.ios.profileName;
      case productBundleId:
        return '${flavor.ios.bundleId}.$extensionTarget';
      default:
        return '';
    }
  }
}
