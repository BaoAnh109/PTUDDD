import 'package:flutter/material.dart';

import '../services/todo_storage.dart';

/// Bài 2 — Todo app + File:
/// nhập tên công việc, chọn ngày giờ, nút "Lưu" thêm vào ListView
/// và lưu vào file todo.txt.
class Bai2Screen extends StatefulWidget {
  const Bai2Screen({super.key});

  @override
  State<Bai2Screen> createState() => _Bai2ScreenState();
}

class _Bai2ScreenState extends State<Bai2Screen> {
  final _storage = TodoStorage('todo.txt');
  final _titleCtrl = TextEditingController();
  DateTime? _when;
  List<TodoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    _items = await _storage.readAll();
    if (mounted) setState(() {});
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _when == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nhập tên công việc và chọn ngày giờ trước khi Lưu')),
      );
      return;
    }
    await _storage.append(TodoItem(title: title, when: _when!));
    _titleCtrl.clear();
    setState(() => _when = null);
    await _reload();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu vào todo.txt')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài 2 — Todo + File')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên công việc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _when == null ? 'Chưa chọn ngày giờ' : 'Hẹn: ${_fmt(_when!)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Chọn ngày giờ'),
                  onPressed: _pickDateTime,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu'),
                onPressed: _save,
              ),
            ),
            const Divider(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Danh sách (đọc từ todo.txt):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Chưa có công việc nào'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final it = _items[i];
                        return ListTile(
                          leading: const Icon(Icons.task_alt),
                          title: Text(it.title),
                          subtitle: Text(_fmt(it.when)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
