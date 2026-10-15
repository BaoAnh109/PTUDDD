import 'package:flutter/material.dart';

import '../services/notification_service.dart';

/// Bài 1 — 3 nút notification theo đề:
/// 1. Nhắc học Ngoại ngữ ngay lập tức.
/// 2. Nhắc uống nước sau 2 phút.
/// 3. (Tự viết) Hẹn nhắc học Ngoại ngữ sau 10 phút.
class Bai1Screen extends StatelessWidget {
  const Bai1Screen({super.key});

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final svc = NotificationService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Bài 1 — Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Nhắc học Ngoại ngữ (ngay)'),
              onPressed: () => svc.showNow(
                id: 101,
                title: 'Học Ngoại ngữ',
                body: 'Đến giờ học Ngoại ngữ rồi!',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.timer),
              label: const Text('Nhắc uống nước (sau 2 phút)'),
              onPressed: () {
                svc.scheduleIn(
                  id: 102,
                  title: 'Uống nước',
                  body: 'Nhớ uống một ly nước nhé!',
                  delay: const Duration(minutes: 2),
                );
                _snack(context, 'Đã hẹn nhắc uống nước sau 2 phút');
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Hẹn nhắc học Ngoại ngữ (sau 10 phút)'),
              onPressed: () {
                svc.scheduleIn(
                  id: 103,
                  title: 'Học Ngoại ngữ',
                  body: 'Đến giờ ôn Ngoại ngữ (đã hẹn trước 10 phút)!',
                  delay: const Duration(minutes: 10),
                );
                _snack(context, 'Đã hẹn nhắc học Ngoại ngữ sau 10 phút');
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Kéo khay thông báo của máy xuống để xem kết quả. '
              'Nút 2 và 3 vẫn báo đúng giờ kể cả khi đã thoát app.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
