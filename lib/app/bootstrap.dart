import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import '../core/config/flavor_config.dart';
import '../core/di/injection.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

Future<void> bootstrap() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(FlavorConfig.instance.name ?? 'prod');
  Bloc.observer = AppBlocObserver();
  runApp(
    FlavorConfig.instance.isProduction
        ? const App()
        : FlavorBanner(child: const App()),
  );
}
