import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

@injectable
class NotificationRemoteDataSource {
  final ApiClient _client;

  NotificationRemoteDataSource(this._client);

  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await _client.dio.get(ApiEndpoints.myNotifications);

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid notifications response');
    }

    dynamic listJson = responseData['data'];
    while (listJson is Map) {
      listJson = listJson['items'] ?? listJson['data'];
    }

    if (listJson is! List) {
      throw const FormatException('Invalid notifications payload');
    }

    return listJson
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();
  }

  Future<void> markAsRead(String uuid) async {
    await _client.dio.patch(ApiEndpoints.notificationRead(uuid));
  }

  Future<void> markAllAsRead() async {
    await _client.dio.patch(ApiEndpoints.notificationsReadAll);
  }
}
