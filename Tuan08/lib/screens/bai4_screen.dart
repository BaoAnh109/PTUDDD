import 'package:flutter/material.dart';

import '../services/notification_service.dart';

/// Một cặp từ vựng: từ + nghĩa.
class VocabWord {
  VocabWord(this.word, this.meaning);
  final String word;
  final String meaning;
}

enum _Bai4Mode { input, learn, quiz, schedule }

/// Bài 4 — Học từ vựng:
/// - Màn nhập: nhập từ + nghĩa, nút "Lưu và Nhắc học sau 10 phút"
///   → notification + SnackBar.
/// - Menu "Học từ": hiện từ, nhập nghĩa, Check đúng/sai, đếm số đúng/sai;
///   số từ sai là bội số của 3 thì hiện notification.
/// - Menu "Kiểm tra": hỏi lần lượt từng từ, cuối buổi báo messagebox
///   số câu đúng/sai và tỉ lệ.
/// - Menu "Lịch nhắc": danh sách các lịch nhắc chưa hiển thị.
class Bai4Screen extends StatefulWidget {
  const Bai4Screen({super.key});

  @override
  State<Bai4Screen> createState() => _Bai4ScreenState();
}

class _Bai4ScreenState extends State<Bai4Screen> {
  final _words = <VocabWord>[];
  _Bai4Mode _mode = _Bai4Mode.input;

  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();

  int _learnIdx = 0;
  int _correct = 0;
  int _wrong = 0;

  int _quizIdx = 0;
  int _quizCorrect = 0;
  int _quizWrong = 0;

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Nút "Lưu và Nhắc học sau 10 phút".
  Future<void> _saveWord() async {
    final word = _wordCtrl.text.trim();
    final meaning = _meaningCtrl.text.trim();
    if (word.isEmpty || meaning.isEmpty) {
      _snack('Nhập cả từ và nghĩa trước khi lưu');
      return;
    }
    setState(() => _words.add(VocabWord(word, meaning)));
    _wordCtrl.clear();
    _meaningCtrl.clear();
    await NotificationService.instance.scheduleIn(
      id: stableId('bai4-vocab-$word'),
      title: 'Ôn từ vựng',
      body: 'Ôn lại từ: $word — $meaning',
      delay: const Duration(minutes: 10),
    );
    _snack('Đã lưu "$word" và hẹn nhắc học sau 10 phút');
  }

  /// Nút Check ở màn "Học từ".
  Future<void> _checkLearn() async {
    if (_words.isEmpty) return;
    final current = _words[_learnIdx % _words.length];
    final answer = _answerCtrl.text.trim().toLowerCase();
    final expected = current.meaning.trim().toLowerCase();
    if (answer.isEmpty) {
      _snack('Nhập nghĩa của từ rồi hãy Check');
      return;
    }
    if (answer == expected) {
      setState(() => _correct++);
      _snack('Chính xác!');
    } else {
      setState(() => _wrong++);
      _snack('Sai rồi — "$expected" mới đúng');
      // Số từ sai là bội số của 3 → notification động viên.
      if (_wrong % 3 == 0) {
        await NotificationService.instance.showNow(
          id: stableId('bai4-wrong-$_wrong'),
          title: 'Cố gắng lên!',
          body: 'Bạn đã trả lời sai $_wrong từ, ôn lại một lượt nhé.',
        );
      }
    }
    _answerCtrl.clear();
    setState(() => _learnIdx++);
  }

  /// Nút "Tiếp" ở màn "Kiểm tra".
  void _nextQuiz() {
    if (_words.isEmpty) return;
    final current = _words[_quizIdx];
    final answer = _answerCtrl.text.trim().toLowerCase();
    if (answer == current.meaning.trim().toLowerCase()) {
      _quizCorrect++;
    } else {
      _quizWrong++;
    }
    _answerCtrl.clear();
    if (_quizIdx + 1 >= _words.length) {
      final total = _quizCorrect + _quizWrong;
      final rate =
          total == 0 ? 0 : (_quizCorrect * 100 / total).toStringAsFixed(1);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kết quả kiểm tra'),
          content: Text(
            'Đúng: $_quizCorrect\nSai: $_quizWrong\nTỉ lệ đúng: $rate%',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      setState(() {
        _quizIdx = 0;
        _quizCorrect = 0;
        _quizWrong = 0;
      });
    } else {
      setState(() => _quizIdx++);
    }
  }

  void _go(_Bai4Mode mode) {
    Navigator.pop(context); // đóng drawer
    setState(() {
      _mode = mode;
      _learnIdx = 0;
      _quizIdx = 0;
      _quizCorrect = 0;
      _quizWrong = 0;
      _correct = 0;
      _wrong = 0;
      _answerCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài 4 — Học từ vựng')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('Bài 4 — Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Nhập từ mới'),
              onTap: () => _go(_Bai4Mode.input),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Học từ'),
              onTap: () => _go(_Bai4Mode.learn),
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Kiểm tra'),
              onTap: () => _go(_Bai4Mode.quiz),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Lịch nhắc'),
              onTap: () => _go(_Bai4Mode.schedule),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_mode) {
      case _Bai4Mode.input:
        return _buildInput();
      case _Bai4Mode.learn:
        return _buildLearn();
      case _Bai4Mode.quiz:
        return _buildQuiz();
      case _Bai4Mode.schedule:
        return _buildSchedule();
    }
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _wordCtrl,
            decoration: const InputDecoration(
              labelText: 'Từ mới (VD: apple)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _meaningCtrl,
            decoration: const InputDecoration(
              labelText: 'Nghĩa (VD: quả táo)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Lưu và Nhắc học sau 10 phút'),
              onPressed: _saveWord,
            ),
          ),
          const SizedBox(height: 12),
          Text('Đã lưu ${_words.length} từ',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _emptyHint() => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Chưa có từ nào.\nMở menu (góc trái) → "Nhập từ mới" để thêm từ trước nhé.',
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _buildLearn() {
    if (_words.isEmpty) return _emptyHint();
    final current = _words[_learnIdx % _words.length];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                current.word,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _answerCtrl,
            decoration: const InputDecoration(
              labelText: 'Nhập nghĩa của từ',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _checkLearn(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _checkLearn, child: const Text('Check')),
          const SizedBox(height: 12),
          Text('Đúng: $_correct   •   Sai: $_wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    if (_words.isEmpty) return _emptyHint();
    final current = _words[_quizIdx];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Câu ${_quizIdx + 1}/${_words.length}',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                current.word,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _answerCtrl,
            decoration: const InputDecoration(
              labelText: 'Nghĩa của từ là gì?',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _nextQuiz(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _nextQuiz,
            child: Text(_quizIdx + 1 >= _words.length ? 'Xem kết quả' : 'Tiếp'),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return FutureBuilder(
      future: NotificationService.instance.pending(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(
              child: Text('Chưa có lịch nhắc nào đang chờ.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final p = items[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(p.title ?? '(không tiêu đề)'),
                subtitle: Text(p.body ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await NotificationService.instance.cancel(p.id);
                    setState(() {});
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
