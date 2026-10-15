import 'package:flutter/material.dart';

import 'screens/bai1_screen.dart';
import 'screens/bai2_screen.dart';
import 'screens/bai3_screen.dart';
import 'screens/bai4_screen.dart';
import 'screens/homework_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const Bai8App());
}

class Bai8App extends StatelessWidget {
  const Bai8App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bài tập tuần 8 — Notification & File',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}

class _MenuEntry {
  _MenuEntry(this.title, this.subtitle, this.screen);
  final String title;
  final String subtitle;
  final Widget screen;
}

/// Màn hình menu chọn 1 trong 5 phần của đề.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuEntry(
        'Bài 1 — Notification',
        'Hiện & hẹn thông báo: ngay / sau 2 phút / sau 10 phút',
        const Bai1Screen(),
      ),
      _MenuEntry(
        'Bài 2 — Todo + File',
        'Nhập công việc, chọn ngày giờ, lưu vào todo.txt',
        const Bai2Screen(),
      ),
      _MenuEntry(
        'Bài 3 — Nhắc việc',
        'Như Bài 2 + notification khi lưu và đúng giờ hẹn',
        const Bai3Screen(),
      ),
      _MenuEntry(
        'Bài 4 — Học từ vựng',
        'Lưu từ, nhắc học sau 10 phút, kiểm tra, lịch nhắc',
        const Bai4Screen(),
      ),
      _MenuEntry(
        'Bài về nhà — Todolist',
        'Danh sách nhiệm vụ + hẹn giờ từng việc, lưu file',
        const HomeworkScreen(),
      ),
    ];
    return Scaffold(
      appBar:
          AppBar(title: const Text('Bài tập tuần 8 — Notification và File')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = items[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(e.title),
              subtitle: Text(e.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => e.screen),
              ),
            ),
          );
        },
      ),
    );
  }
}
