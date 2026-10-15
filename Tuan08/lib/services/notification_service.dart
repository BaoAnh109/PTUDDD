import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Channel dùng chung cho mọi notification của bài tập tuần 8.
const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
  'baitap8_channel',
  'Bài tập tuần 8',
  channelDescription: 'Thông báo nhắc việc / học từ vựng',
  importance: Importance.max,
  priority: Priority.high,
);

const NotificationDetails _details = NotificationDetails(android: _androidDetails);

/// Wrapper gọn quanh flutter_local_notifications, dùng chung cho Bài 1, 3, 4
/// và Bài về nhà.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    // Android 13+: xin quyền hiện notification lúc runtime.
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Máy cũ không cần quyền runtime — bỏ qua.
    }
    _ready = true;
  }

  /// Hiện notification ngay lập tức.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(id, title, body, _details);
  }

  /// Hẹn notification sau [delay] (VD: 2 phút, 10 phút).
  Future<void> scheduleIn({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    await init();
    await _schedule(
      id: id,
      title: title,
      body: body,
      when: tz.TZDateTime.now(tz.local).add(delay),
    );
  }

  /// Hẹn notification vào thời điểm [when] (giờ địa phương).
  /// Nếu giờ đã qua hôm nay thì dời sang ngày mai.
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await init();
    final t =
        when.isBefore(DateTime.now()) ? when.add(const Duration(days: 1)) : when;
    await _schedule(
      id: id,
      title: title,
      body: body,
      when: tz.TZDateTime.from(t, tz.local),
    );
  }

  /// Thử hẹn giờ chính xác (exact) trước; máy nào từ chối quyền
  /// exact alarm thì rớt xuống hẹn tương đối (inexact) — vẫn báo, chỉ lệch giờ.
  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Danh sách các lịch nhắc chưa tới giờ (màn "Lịch nhắc" của Bài 4).
  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  Future<void> cancel(int id) => _plugin.cancel(id);
}

/// id số nguyên không âm, ổn định cho một chuỗi bất kỳ.
///
/// Dùng FNV-1a 32-bit tự viết thay vì `String.hashCode`: hashCode của chuỗi
/// trên Dart VM bị random theo mỗi lần chạy app, nên id sẽ đổi sau mỗi lần
/// mở lại app — làm hỏng việc hủy/thay thế lịch nhắc đã hẹn ("Lịch nhắc").
int stableId(String s) {
  var h = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h & 0x7fffffff;
}
