import 'package:flutter_flavorizr/parser/models/flavorizr.dart';
import 'package:flutter_flavorizr/parser/models/flavors/flavor.dart';
import 'package:flutter_flavorizr/parser/models/flavors/ios/enums.dart';
import 'package:flutter_flavorizr/processors/commons/string_processor.dart';

class IOSPbxprojProcessor extends StringProcessor {
  static const String teamIDEntryPoint = 'DEVELOPMENT_TEAM';
  static const String provProfileEntryPoint = 'PROVISIONING_PROFILE_SPECIFIER';
  static const String productBundleIdEntryPoint = 'PRODUCT_BUNDLE_IDENTIFIER';
  static const List<String> entryPoints = [
    teamIDEntryPoint,
    provProfileEntryPoint,
    productBundleIdEntryPoint,
  ];

  static const String serviceExtension = 'ServiceExtension';
  static const String contentExtension = 'ContentExtension';

  static const List<String> extensions = [serviceExtension, contentExtension];

  String _target(String target) =>
      target.substring(0, 1).toUpperCase() + target.substring(1);

  String baseConfigEntryPoint(String flavorName, String target) =>
      'baseConfigurationReference = (.*)$flavorName${_target(target)}.xcconfig \\*/;';

  String baseConfigExtensionEntryPoint(
          String flavorName, String target, String extension) =>
      'baseConfigurationReference = (.*)Pods-$extension.${target.toLowerCase()}-$flavorName.xcconfig \\*/;';

  IOSPbxprojProcessor({
    String? input,
    required Flavorizr config,
  }) : super(input: input, config: config);

  @override
  String execute() {
    runnerTargetProcessor();
    extensionTargetProcessor();

    return input!;
  }

  @override
  String toString() => 'IOSPbxprojProcessor';

  String? runnerTargetProcessor() {
    StringBuffer buffer = StringBuffer();

    for (final entryPoint in entryPoints) {
      for (final target in Target.values) {
        for (final flavor in config.flavors.entries) {
          final entryPointPos = _appendContent(
            buffer,
            flavor.key,
            target.value,
            entryPoint,
            null,
          );

          final baseConfigPos = input!.indexOf(
            RegExp(
              baseConfigEntryPoint(
                flavor.key,
                target.value,
              ),
            ),
          );

          input = input!.substring(baseConfigPos);

          buffer.write(
            '$entryPoint = "${_getValue(entryPoint, flavor.value, null)}";',
          );

          _appendEndContent(buffer, entryPointPos);

          input = buffer.toString();
          buffer.clear();
        }
      }
    }

    return input;
  }

  String? extensionTargetProcessor() {
    StringBuffer buffer = StringBuffer();

    for (final entryPoint in entryPoints) {
      for (final target in Target.values) {
        for (final flavor in config.flavors.entries) {
          for (final extension in extensions) {
            final entryPointPos = _appendContent(
              buffer,
              flavor.key,
              target.value,
              entryPoint,
              extension,
            );

            final baseConfigPos = input!.indexOf(
              RegExp(
                baseConfigExtensionEntryPoint(
                  flavor.key,
                  target.value,
                  extension,
                ),
              ),
            );

            input = input!.substring(baseConfigPos);

            buffer.write(
              '$entryPoint = "${_getValue(
                entryPoint,
                flavor.value,
                extension,
              )}";',
            );

            _appendEndContent(buffer, entryPointPos);

            input = buffer.toString();
            buffer.clear();
          }
        }
      }
    }

    return input;
  }

  int _appendContent(
    StringBuffer buffer,
    String flavorName,
    String target,
    String entryPoint,
    String? extension,
  ) {
    final regex = extension == null
        ? RegExp(baseConfigEntryPoint(flavorName, target))
        : RegExp(baseConfigExtensionEntryPoint(flavorName, target, extension));

    final baseConfigPos = input!.indexOf(regex);
    final startContent = input!.substring(0, baseConfigPos);
    final endContent = input!.substring(baseConfigPos);
    final entryPointPos = endContent.indexOf(entryPoint);

    buffer.write(startContent);
    buffer.write(endContent.substring(0, entryPointPos));

    return entryPointPos;
  }

  void _appendEndContent(StringBuffer buffer, int entryPointPos) {
    final int end = input!.substring(entryPointPos).indexOf(';') + 1;
    buffer.write(input!.substring(entryPointPos + end));
  }

  String _getValue(String entryPoint, Flavor flavor, String? extension) {
    switch (entryPoint) {
      case teamIDEntryPoint:
        return flavor.ios.teamID;
      case provProfileEntryPoint:
        return flavor.ios.profileName;
      case productBundleIdEntryPoint:
        return extension != null ? '${flavor.ios.bundleId}.$extension' : '';
      default:
        return '';
    }
  }
}
