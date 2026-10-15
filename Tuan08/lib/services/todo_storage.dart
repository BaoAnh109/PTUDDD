import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Một công việc trong Bài 2 / Bài 3.
class TodoItem {
  TodoItem({required this.title, required this.when});
  final String title;
  final DateTime when;
}

/// Đọc/ghi danh sách công việc vào file text trong thư mục tài liệu của app.
/// Mỗi dòng: `title|epochMillis` (ký tự '|' trong tiêu đề được thay bằng
/// khoảng trắng để không phá định dạng file).
class TodoStorage {
  TodoStorage(this.fileName);
  final String fileName;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<List<TodoItem>> readAll() async {
    final f = await _file();
    if (!await f.exists()) return [];
    final items = <TodoItem>[];
    for (final line in await f.readAsLines()) {
      final sep = line.lastIndexOf('|');
      if (sep < 0) continue;
      final ms = int.tryParse(line.substring(sep + 1)) ?? 0;
      items.add(TodoItem(
        title: line.substring(0, sep),
        when: DateTime.fromMillisecondsSinceEpoch(ms),
      ));
    }
    return items;
  }

  Future<void> append(TodoItem item) async {
    final f = await _file();
    await f.writeAsString(
      '${_safe(item.title)}|${item.when.millisecondsSinceEpoch}\n',
      mode: FileMode.append,
    );
  }

  String _safe(String s) => s.replaceAll('|', ' ').replaceAll('\n', ' ');
}
