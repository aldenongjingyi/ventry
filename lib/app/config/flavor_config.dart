enum Flavor { dev, prod }

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String envFile;

  static late final FlavorConfig _instance;
  static FlavorConfig get instance => _instance;

  static bool get isDev => _instance.flavor == Flavor.dev;
  static bool get isProd => _instance.flavor == Flavor.prod;

  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.envFile,
  });

  static void init({
    required Flavor flavor,
    required String appName,
    required String envFile,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      envFile: envFile,
    );
  }
}
