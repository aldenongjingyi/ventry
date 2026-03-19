import 'app/config/flavor_config.dart';
import 'main.dart';

Future<void> main() async {
  FlavorConfig.init(
    flavor: Flavor.prod,
    appName: 'Ventry',
    envFile: '.env.prod',
  );
  await bootstrap();
}
