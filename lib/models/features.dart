class Features {
  bool isUSBDebug;
  bool isCamera;
  bool isAppInstallation;
  bool isSoftReset;
  bool isSoftBoot;
  bool isHardReset;
  bool isOutgoingCalls;
  bool isSetting;
  List<String> apps;
  bool warningAudio;
  bool warningWallpaper;
  String passwordChange;
  bool isDeveloperOptions;
  String wallpaperUrl;

  Features({
    required this.isUSBDebug,
    required this.isCamera,
    required this.isAppInstallation,
    required this.isSoftReset,
    required this.isSoftBoot,
    required this.isHardReset,
    required this.isOutgoingCalls,
    required this.isSetting,
    required this.apps,
    required this.warningAudio,
    required this.warningWallpaper,
    required this.passwordChange,
    required this.isDeveloperOptions,
    required this.wallpaperUrl,
  });

  factory Features.fromJson(Map<String, dynamic> json) => Features(
    isUSBDebug: json['isUSBDebug'] as bool,
    isCamera: json['isCamera'] as bool,
    isAppInstallation: json['isAppInstallation'] as bool,
    isSoftReset: json['isSoftReset'] as bool,
    isSoftBoot: json['isSoftBoot'] as bool,
    isHardReset: json['isHardReset'] as bool,
    isOutgoingCalls: json['isOutgoingCalls'] as bool,
    isSetting: json['isSetting'] as bool,
    apps: List<String>.from(json['apps'] ?? []),
    warningAudio: json['warningAudio'] as bool,
    warningWallpaper: json['warningWallpaper'] as bool,
    passwordChange: json['passwordChange'] as String,
    isDeveloperOptions: json['isDeveloperOptions'] as bool,
    wallpaperUrl: json['wallpaperUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'isUSBDebug': isUSBDebug,
    'isCamera': isCamera,
    'isAppInstallation': isAppInstallation,
    'isSoftReset': isSoftReset,
    'isSoftBoot': isSoftBoot,
    'isHardReset': isHardReset,
    'isOutgoingCalls': isOutgoingCalls,
    'isSetting': isSetting,
    'apps': apps,
    'warningAudio': warningAudio,
    'warningWallpaper': warningWallpaper,
    'passwordChange': passwordChange,
    'isDeveloperOptions': isDeveloperOptions,
    'wallpaperUrl': wallpaperUrl,
  };

  Features copyWith({
    bool? isUSBDebug,
    bool? isCamera,
    bool? isAppInstallation,
    bool? isSoftReset,
    bool? isSoftBoot,
    bool? isHardReset,
    bool? isOutgoingCalls,
    bool? isSetting,
    List<String>? apps,
    bool? warningAudio,
    bool? warningWallpaper,
    String? passwordChange,
    bool? isDeveloperOptions,
    String? wallpaperUrl,
  }) {
    return Features(
      isUSBDebug: isUSBDebug ?? this.isUSBDebug,
      isCamera: isCamera ?? this.isCamera,
      isAppInstallation: isAppInstallation ?? this.isAppInstallation,
      isSoftReset: isSoftReset ?? this.isSoftReset,
      isSoftBoot: isSoftBoot ?? this.isSoftBoot,
      isHardReset: isHardReset ?? this.isHardReset,
      isOutgoingCalls: isOutgoingCalls ?? this.isOutgoingCalls,
      isSetting: isSetting ?? this.isSetting,
      apps: apps ?? List<String>.from(this.apps),
      warningAudio: warningAudio ?? this.warningAudio,
      warningWallpaper: warningWallpaper ?? this.warningWallpaper,
      passwordChange: passwordChange ?? this.passwordChange,
      isDeveloperOptions: isDeveloperOptions ?? this.isDeveloperOptions,
      wallpaperUrl: wallpaperUrl ?? this.wallpaperUrl,
    );
  }
}
