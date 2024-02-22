// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ios.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IOS _$IOSFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['bundleId', 'profileName'],
    disallowNullValues: const [
      'firebase',
      'icon',
      'bundleId',
      'profileName',
      'variables'
    ],
  );
  return IOS(
    bundleId: json['bundleId'] as String,
    profileName: json['profileName'] as String,
    dynamicLinkPrefix: json['dynamicLinkPrefix'] as String?,
    weLicenseCode: json['weLicenseCode'] as String?,
    teamID: json['teamID'] as String,
    reversedGoogleClientID: json['reversedGoogleClientID'] as String?,
    facebookAppID: json['facebookAppID'] as String?,
    facebookClientToken: json['facebookClientToken'] as String?,
    variables: (json['variables'] as Map?)?.map(
          (k, e) => MapEntry(k as String,
              Variable.fromJson(Map<String, dynamic>.from(e as Map))),
        ) ??
        {},
    buildSettings: (json['buildSettings'] as Map?)?.map(
          (k, e) => MapEntry(k as String, e),
        ) ??
        {},
    generateDummyAssets: json['generateDummyAssets'] as bool? ?? true,
    firebase: json['firebase'] == null
        ? null
        : Firebase.fromJson(Map<String, dynamic>.from(json['firebase'] as Map)),
    icon: json['icon'] as String?,
  );
}
