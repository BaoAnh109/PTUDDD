import 'package:flutter/material.dart';

import 'screens/bai1_screen.dart';
import 'screens/bai2_screen.dart';
import 'screens/bai4_screen.dart';
import 'screens/homework_screen.dart';

void main() {
  runApp(const BaiTap7App());
}

class BaiTap7App extends StatelessWidget {
  const BaiTap7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bài tập tuần 7 - Google Maps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}

/// Màn hình chính: chọn bài tập để chạy thử.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static final List<_MenuItem> _items = [
    _MenuItem(
      title: 'Bài 1 - Map Navigator',
      subtitle: 'Bản đồ, vị trí hiện tại, đường đi tới TP.HCM',
      icon: Icons.map,
      builder: (context) => const Bai1Screen(),
    ),
    _MenuItem(
      title: 'Bài 2 - Route Finder',
      subtitle: 'Nhập 2 tọa độ để tìm đường đi',
      icon: Icons.route,
      builder: (context) => const Bai2Screen(),
    ),
    _MenuItem(
      title: 'Bài 4 - Trên lớp',
      subtitle: 'Đích = vị trí hiện tại, khoảng cách/thời gian, '
          'chạm bản đồ chọn điểm, tìm địa điểm (Places API)',
      icon: Icons.navigation,
      builder: (context) => const Bai4Screen(),
    ),
    _MenuItem(
      title: 'Bài tập về nhà',
      subtitle: 'Tìm địa chỉ (Geocoding), chọn phương tiện, '
          'lưu tuyến đường yêu thích (SQLite)',
      icon: Icons.home,
      builder: (context) => const HomeworkScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài tập tuần 7 - Multimedia: Google Maps'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = _items[i];
          return Card(
            child: ListTile(
              leading: Icon(item.icon, color: Colors.blue, size: 32),
              title: Text(item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: item.builder),
              ),
            ),
          );
        },
      ),
    );
  }
}
