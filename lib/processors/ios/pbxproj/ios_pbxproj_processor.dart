import 'package:flutter_flavorizr/parser/models/flavorizr.dart';
import 'package:flutter_flavorizr/parser/models/flavors/flavor.dart';
import 'package:flutter_flavorizr/parser/models/flavors/ios/enums.dart';
import 'package:flutter_flavorizr/processors/commons/string_processor.dart';

class IOSPbxprojProcessor extends StringProcessor {
  static const String teamIDEntryPoint = 'DEVELOPMENT_TEAM';
  static const String provProfileEntryPoint = 'PROVISIONING_PROFILE_SPECIFIER';
  static const List<String> entryPoints = [
    teamIDEntryPoint,
    provProfileEntryPoint,
  ];

  String _target(String target) =>
      target.substring(0, 1).toUpperCase() + target.substring(1);

  String baseConfigEntryPoint(String flavorName, String target) =>
      'baseConfigurationReference = (.*)$flavorName${_target(target)}.xcconfig \\*/;';

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
          final entryPointPos =
              _appendStartContent(buffer, flavor.key, target.value, entryPoint);

          final baseConfigPos = input!.indexOf(
            RegExp(baseConfigEntryPoint(flavor.key, target.value)),
          );

          input = input!.substring(baseConfigPos);

          buffer
              .write('$entryPoint = "${getValue(entryPoint, flavor.value)}";');

          _appendEndContent(buffer, entryPointPos);

          input = buffer.toString();
          buffer.clear();
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
  ) {
    final baseConfigPos =
        input!.indexOf(RegExp(baseConfigEntryPoint(flavorName, target)));

    final startContent = input!.substring(0, baseConfigPos);
    final endContent = input!.substring(baseConfigPos);

    final int entryPointPos = endContent.indexOf(entryPoint);

    buffer.write(startContent);

    buffer.write(endContent.substring(0, entryPointPos));

    return entryPointPos;
  }

  void _appendEndContent(StringBuffer buffer, int entryPointPos) {
    final int end = input!.substring(entryPointPos).indexOf(';') + 1;
    buffer.write(input!.substring(entryPointPos + end));
  }

  String getValue(String entryPoint, Flavor flavor) {
    switch (entryPoint) {
      case teamIDEntryPoint:
        return flavor.ios.teamID;
      case provProfileEntryPoint:
        return flavor.ios.profileName;
      default:
        return '';
    }
  }
}
