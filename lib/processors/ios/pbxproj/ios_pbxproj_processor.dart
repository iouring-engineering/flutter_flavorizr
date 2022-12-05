import 'package:flutter_flavorizr/parser/models/flavorizr.dart';
import 'package:flutter_flavorizr/parser/models/flavors/ios/enums.dart';
import 'package:flutter_flavorizr/processors/commons/string_processor.dart';

import '../../../parser/models/flavors/flavor.dart';

class IOSPbxprojProcessor extends StringProcessor {
  static const String entryPoint = 'PROVISIONING_PROFILE_SPECIFIER';

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

    for (final target in Target.values) {
      for (final flavor in config.flavors.entries) {
        final entryPointPos =
            _appendStartContent(buffer, flavor.key, target.value);

        final baseConfigPos = input!.indexOf(
          RegExp(baseConfigEntryPoint(flavor.key, target.value)),
        );

        input = input!.substring(baseConfigPos);

        _updateProfileSpecifier(buffer, flavor.value);
        _appendEndContent(buffer, entryPointPos);

        input = buffer.toString();
        buffer.clear();
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

  void _updateProfileSpecifier(StringBuffer buffer, Flavor flavor) {
    final profileName = flavor.ios.profileName;

    buffer.write('$entryPoint = "$profileName";');
  }

  void _appendEndContent(StringBuffer buffer, int entryPointPos) {
    final int end = input!.substring(entryPointPos).indexOf(';') + 1;
    buffer.write(input!.substring(entryPointPos + end));
  }
}
