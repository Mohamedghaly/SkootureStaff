class AppConfiguration {
  final String? appLink;
  final String? iosAppLink;
  final String? appVersion;
  final String? iosAppVersion;
  final String? forceAppUpdate;
  final String? appMaintenance;
  final String? teacherAppLink;
  final String? teacherIosAppLink;
  final String? teacherAppVersion;
  final String? teacherIosAppVersion;
  final String? teacherForceAppUpdate;
  final String? teacherAppMaintenance;
  final String? tagline;

  AppConfiguration({
    this.appLink,
    this.iosAppLink,
    this.appVersion,
    this.iosAppVersion,
    this.forceAppUpdate,
    this.appMaintenance,
    this.teacherAppLink,
    this.teacherIosAppLink,
    this.teacherAppVersion,
    this.teacherIosAppVersion,
    this.teacherForceAppUpdate,
    this.teacherAppMaintenance,
    this.tagline,
  });

  AppConfiguration copyWith({
    String? appLink,
    String? iosAppLink,
    String? appVersion,
    String? iosAppVersion,
    String? forceAppUpdate,
    String? appMaintenance,
    String? teacherAppLink,
    String? teacherIosAppLink,
    String? teacherAppVersion,
    String? teacherIosAppVersion,
    String? teacherForceAppUpdate,
    String? teacherAppMaintenance,
    String? tagline,
  }) {
    return AppConfiguration(
      appLink: appLink ?? this.appLink,
      iosAppLink: iosAppLink ?? this.iosAppLink,
      appVersion: appVersion ?? this.appVersion,
      iosAppVersion: iosAppVersion ?? this.iosAppVersion,
      forceAppUpdate: forceAppUpdate ?? this.forceAppUpdate,
      appMaintenance: appMaintenance ?? this.appMaintenance,
      teacherAppLink: teacherAppLink ?? this.teacherAppLink,
      teacherIosAppLink: teacherIosAppLink ?? this.teacherIosAppLink,
      teacherAppVersion: teacherAppVersion ?? this.teacherAppVersion,
      teacherIosAppVersion: teacherIosAppVersion ?? this.teacherIosAppVersion,
      teacherForceAppUpdate:
          teacherForceAppUpdate ?? this.teacherForceAppUpdate,
      teacherAppMaintenance:
          teacherAppMaintenance ?? this.teacherAppMaintenance,
      tagline: tagline ?? this.tagline,
    );
  }

  AppConfiguration.fromJson(Map<String, dynamic> json)
      : appLink = json['app_link'] as String?,
        iosAppLink = json['ios_app_link'] as String?,
        appVersion = json['app_version'] as String?,
        iosAppVersion = json['ios_app_version'] as String?,
        forceAppUpdate = json['force_app_update'] as String?,
        appMaintenance = json['app_maintenance'] as String?,
        teacherAppLink = json['teacher_app_link'] as String?,
        teacherIosAppLink = json['teacher_ios_app_link'] as String?,
        teacherAppVersion = json['teacher_app_version'] as String?,
        teacherIosAppVersion = json['teacher_ios_app_version'] as String?,
        teacherForceAppUpdate = json['teacher_force_app_update'] as String?,
        teacherAppMaintenance = json['teacher_app_maintenance'] as String?,
        tagline = json['tagline'] as String?;

  Map<String, dynamic> toJson() => {
        'app_link': appLink,
        'ios_app_link': iosAppLink,
        'app_version': appVersion,
        'ios_app_version': iosAppVersion,
        'force_app_update': forceAppUpdate,
        'app_maintenance': appMaintenance,
        'teacher_app_link': teacherAppLink,
        'teacher_ios_app_link': teacherIosAppLink,
        'teacher_app_version': teacherAppVersion,
        'teacher_ios_app_version': teacherIosAppVersion,
        'teacher_force_app_update': teacherForceAppUpdate,
        'teacher_app_maintenance': teacherAppMaintenance,
        'tagline': tagline
      };
}
