import 'package:flutter/material.dart';

import '../services/favorites_db.dart';

/// Danh sách tuyến đường yêu thích đã lưu (SQLite).
/// Chạm vào một mục để vẽ lại tuyến đường đó trên bản đồ.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<FavoriteRoute>> _future;

  @override
  void initState() {
    super.initState();
    _future = FavoritesDb.instance.getAll();
  }

  Future<void> _delete(FavoriteRoute fav) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tuyến đường?'),
        content: Text('Xóa "${fav.name}" khỏi danh sách yêu thích?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true && fav.id != null && mounted) {
      await FavoritesDb.instance.delete(fav.id!);
      setState(() {
        _future = FavoritesDb.instance.getAll();
      });
    }
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'walking':
        return 'Đi bộ';
      case 'motorbike':
        return 'Xe máy';
      default:
        return 'Ô tô';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tuyến đường yêu thích')),
      body: FutureBuilder<List<FavoriteRoute>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('Chưa có tuyến đường yêu thích nào'),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final fav = items[i];
              return ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(fav.name),
                subtitle: Text(
                  '${_modeLabel(fav.mode)} • ${fav.distanceText} • ${fav.durationText}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(fav),
                ),
                onTap: () => Navigator.pop(context, fav),
              );
            },
          );
        },
      ),
    );
  }
}
