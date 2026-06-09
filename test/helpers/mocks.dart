import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
