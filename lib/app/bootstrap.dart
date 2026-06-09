import 'package:flutter/widgets.dart';

Future<void> bootstrap(Widget Function() appBuilder) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(appBuilder());
}
