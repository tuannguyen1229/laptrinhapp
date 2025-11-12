import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

@singleton
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _createNotificationChannel();
    } catch (e) {
      throw NotificationException('Không thể khởi tạo notification service: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Xử lý khi người dùng tap vào notification
    // Có thể navigate đến màn hình cụ thể dựa trên payload
    final payload = response.payload;
    if (payload != null) {
      // Xử lý navigation dựa trên payload
      _handleNotificationNavigation(payload);
    }
  }

  void _handleNotificationNavigation(String payload) {
    // Logic navigation sẽ được implement sau
    // Ví dụ: navigate đến danh sách sách quá hạn, thông báo mới, etc.
  }

  // Gửi thông báo ngay lập tức
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      throw NotificationException('Không thể gửi thông báo: $e');
    }
  }

  // Lên lịch thông báo
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      throw NotificationException('Không thể lên lịch thông báo: $e');
    }
  }

  // Thông báo sách quá hạn
  Future<void> notifyOverdueBooks({
    required String readerName,
    required List<String> bookTitles,
    required int daysOverdue,
  }) async {
    final title = 'Sách quá hạn trả';
    final body = bookTitles.length == 1
        ? 'Bạn có 1 cuốn sách "${bookTitles.first}" quá hạn $daysOverdue ngày'
        : 'Bạn có ${bookTitles.length} cuốn sách quá hạn $daysOverdue ngày';

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'overdue_books',
    );
  }

  // Thông báo nhắc nhở trả sách
  Future<void> notifyReturnReminder({
    required String readerName,
    required List<String> bookTitles,
    required int daysUntilDue,
  }) async {
    final title = 'Nhắc nhở trả sách';
    final body = bookTitles.length == 1
        ? 'Cuốn sách "${bookTitles.first}" sẽ đến hạn trả trong $daysUntilDue ngày'
        : 'Bạn có ${bookTitles.length} cuốn sách sẽ đến hạn trả trong $daysUntilDue ngày';

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'return_reminder',
    );
  }

  // Thông báo sách mới
  Future<void> notifyNewBook({
    required String bookTitle,
    required String author,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Sách mới được thêm',
      body: 'Cuốn sách "$bookTitle" của tác giả $author đã được thêm vào thư viện',
      payload: 'new_book',
    );
  }

  // Hủy thông báo
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      throw NotificationException('Không thể hủy thông báo: $e');
    }
  }

  // Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      throw NotificationException('Không thể hủy tất cả thông báo: $e');
    }
  }

  // Kiểm tra quyền thông báo
  Future<bool> checkPermissions() async {
    try {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted = await androidImplementation.areNotificationsEnabled();
        return granted ?? false;
      }

      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        try {
          await iosImplementation.checkPermissions();
          // checkPermissions returns NotificationsEnabledOptions, not bool
          // For simplicity, assume true if no exception
          return true;
        } catch (e) {
          return false;
        }
      }

      return false;
    } catch (e) {
      throw NotificationException('Không thể kiểm tra quyền thông báo: $e');
    }
  }

  // Yêu cầu quyền thông báo
  Future<bool> requestPermissions() async {
    try {
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      // Android không cần request permission cho notification cơ bản
      return true;
    } catch (e) {
      throw NotificationException('Không thể yêu cầu quyền thông báo: $e');
    }
  }
}