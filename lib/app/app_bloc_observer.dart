import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:logger/logger.dart';

class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (FlavorConfig.instance.variables['enableLogging'] as bool? ?? false) {
      _logger.d('[${bloc.runtimeType}] $change');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.e(
      '[${bloc.runtimeType}] Error',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (FlavorConfig.instance.variables['enableLogging'] as bool? ?? false) {
      _logger.d('[${bloc.runtimeType}] $transition');
    }
  }
}
