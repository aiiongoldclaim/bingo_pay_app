import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intro/intro.dart';
import '../core/config/flavor_config.dart';
import '../core/di/injection.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

// Future<void> bootstrap() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Lock to portrait regardless of the device's rotation-lock setting or
//   // physical orientation — the app has no landscape layouts.
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   await configureDependencies(FlavorConfig.instance.name ?? 'prod');
//   Bloc.observer = AppBlocObserver();
//   runApp(
//     FlavorConfig.instance.isProduction
//         ? const App()
//         : FlavorBanner(child: const App()),
//   );
// }
Future<void> bootstrap() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Native splash ko hold karo jab tak Flutter ka pehla frame ready na ho
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final view = binding.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  final isTablet = shortestSide >= 540;

  await SystemChrome.setPreferredOrientations(
    isTablet
        ? DeviceOrientation.values
        : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await configureDependencies(FlavorConfig.instance.name ?? 'prod');
  Bloc.observer = AppBlocObserver();

  runApp(
    Intro(
      controller: IntroController(stepCount: 7),
      cardDecoration: IntroCardDecoration(
        tapBarrierToContinue: true,
        showPreviousButton: false,
        nextButtonStyle: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith(
            (states) => Colors.lightBlue,
          ),
          shape: MaterialStateProperty.resolveWith(
            (states) => const RoundedRectangleBorder(),
          ),
        ),
        closeButtonStyle: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith(
            (states) => Colors.lime,
          ),
          shape: MaterialStateProperty.resolveWith(
            (states) => const RoundedRectangleBorder(),
          ),
          foregroundColor: MaterialStateColor.resolveWith(
            (states) => Colors.white,
          ),
        ),
      ),
      topLayerBuilder: (context, controller) {
        return Padding(
          // padding: EdgeInsets.only(top: 6.h, left: 80.w, right: 20),
          padding: const EdgeInsets.only(top: 48, left: 280, right: 20),
          child: TextButton(
            onPressed: controller.close,
            style: ButtonStyle(
              foregroundColor: MaterialStateColor.resolveWith(
                (states) => Colors.white70,
              ),
              backgroundColor: MaterialStateColor.resolveWith(
                (states) => Colors.white24,
              ),
            ),
            child: const Text("Exit"),
          ),
        );
      },
      child: FlavorConfig.instance.isProduction
          ? const App()
          : FlavorBanner(child: const App()),
    ),
  );

}
