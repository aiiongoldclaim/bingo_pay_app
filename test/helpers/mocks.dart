import 'package:bingo_pay/features/products/data/datasources/product_remote_datasource.dart';
import 'package:bingo_pay/features/transactions/data/datasources/order_remote_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockOrderRemoteDataSource extends Mock implements OrderRemoteDataSource {}
