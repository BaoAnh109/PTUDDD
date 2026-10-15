import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/notification_service.dart';

/// Một nhiệm vụ trong Bài về nhà.
class HwTask {
  HwTask({required this.title, this.remindAt, this.done = false});
  String title;
  DateTime? remindAt;
  bool done;
}

/// Lưu danh sách nhiệm vụ vào file `todolist.txt`.
/// Mỗi dòng: `title|epochMillis(trống nếu chưa hẹn)|0|1(done)`.
class _HwStorage {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/todolist.txt');
  }

  Future<List<HwTask>> readAll() async {
    final f = await _file();
    if (!await f.exists()) return [];
    final tasks = <HwTask>[];
    for (final line in await f.readAsLines()) {
      final parts = line.split('|');
      if (parts.length < 3) continue;
      tasks.add(HwTask(
        title: parts[0],
        remindAt: parts[1].isEmpty
            ? null
            : DateTime.fromMillisecondsSinceEpoch(int.tryParse(parts[1]) ?? 0),
        done: parts[2] == '1',
      ));
    }
    return tasks;
  }

  Future<void> writeAll(List<HwTask> tasks) async {
    final f = await _file();
    final buf = StringBuffer();
    for (final t in tasks) {
      final safe = t.title.replaceAll('|', ' ').replaceAll('\n', ' ');
      buf.writeln('$safe|${t.remindAt?.millisecondsSinceEpoch ?? ''}|'
          '${t.done ? '1' : '0'}');
    }
    await f.writeAsString(buf.toString());
  }
}

/// Bài về nhà — Todolist:
/// - Màn hình chính: danh sách nhiệm vụ đọc từ file.
/// - Icon chuông ở mỗi nhiệm vụ: chọn giờ để hẹn thông báo.
/// - Nút thêm: màn hình nhập nhiệm vụ mới, "Lưu nhiệm vụ" lưu vào file
///   và quay về màn hình chính.
/// - Đánh dấu hoàn thành: hộp xác nhận → thông báo trên khay hệ thống
///   số nhiệm vụ đã hoàn thành.
class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final _storage = _HwStorage();
  List<HwTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    _tasks = await _storage.readAll();
    if (mounted) setState(() {});
  }

  Future<void> _save() => _storage.writeAll(_tasks);

  /// Chọn giờ hẹn thông báo cho một nhiệm vụ.
  Future<void> _pickReminder(HwTask task) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    task.remindAt = when;
    await _save();
    await NotificationService.instance.scheduleAt(
      id: stableId('hw-${task.title}'),
      title: 'Nhắc nhiệm vụ',
      body: task.title,
      when: when,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã hẹn nhắc lúc ${_fmtTime(when)}')),
      );
      setState(() {});
    }
  }

  /// Đánh dấu hoàn thành: hộp xác nhận → notification báo số đã hoàn thành.
  Future<void> _toggleDone(HwTask task, bool done) async {
    if (!done) {
      setState(() => task.done = false);
      await _save();
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Đánh dấu "${task.title}" là đã hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => task.done = true);
    await _save();
    final doneCount = _tasks.where((t) => t.done).length;
    await NotificationService.instance.showNow(
      id: stableId('hw-done-count'),
      title: 'Todolist',
      body: 'Bạn đã hoàn thành $doneCount/${_tasks.length} nhiệm vụ. '
          'Tiếp tục phát huy!',
    );
    if (mounted) setState(() {});
  }

  Future<void> _openAdd() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _AddTaskScreen()),
    );
    if (added == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài về nhà — Todolist')),
      body: _tasks.isEmpty
          ? const Center(child: Text('Chưa có nhiệm vụ nào.\nBấm + để thêm.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _tasks.length,
              itemBuilder: (context, i) {
                final t = _tasks[i];
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: t.done,
                      onChanged: (v) => _toggleDone(t, v ?? false),
                    ),
                    title: Text(
                      t.title,
                      style: TextStyle(
                        decoration:
                            t.done ? TextDecoration.lineThrough : null,
                        color: t.done ? Colors.grey : null,
                      ),
                    ),
                    subtitle: t.remindAt == null
                        ? null
                        : Text('Hẹn: ${_fmtTime(t.remindAt!)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Hẹn giờ thông báo',
                      onPressed: () => _pickReminder(t),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Màn hình thêm nhiệm vụ mới của Bài về nhà.
class _AddTaskScreen extends StatefulWidget {
  const _AddTaskScreen();

  @override
  State<_AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<_AddTaskScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập tên nhiệm vụ trước khi lưu')),
      );
      return;
    }
    final storage = _HwStorage();
    final tasks = await storage.readAll();
    tasks.add(HwTask(title: title));
    await storage.writeAll(tasks);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhiệm vụ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                labelText: 'Tên nhiệm vụ',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu nhiệm vụ'),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtTime(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
