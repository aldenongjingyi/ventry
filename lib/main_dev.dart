import 'app/config/flavor_config.dart';
import 'main.dart';

Future<void> main() async {
  FlavorConfig.init(
    flavor: Flavor.dev,
    appName: 'Ventry Dev',
    envFile: '.env.dev',
  );
  await bootstrap();
}
