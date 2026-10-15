// Chụp ảnh màn hình UI THẬT của app (render headless, không phải mockup).
// Chạy: flutter test test/screenshot_test.dart
// Ảnh ra: ~/workspace/ptuddd/baitap8/report/shots/*.png
//
// Lưu ý kỹ thuật: testWidgets chạy trong FakeAsync zone nên mọi tác vụ
// async "thật" (nạp font qua engine, toImage, ghi file) phải bọc trong
// tester.runAsync, còn pump/interact widget giữ trong fake zone.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:baitap8_notification_file/main.dart';
import 'package:baitap8_notification_file/screens/bai1_screen.dart';
import 'package:baitap8_notification_file/screens/bai2_screen.dart';
import 'package:baitap8_notification_file/screens/bai3_screen.dart';
import 'package:baitap8_notification_file/screens/bai4_screen.dart';
import 'package:baitap8_notification_file/screens/homework_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/src/platform_flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

const _fontDir = '/home/hatch/flutter-sdk/bin/cache/artifacts/material_fonts';
const _outDir = '/home/hatch/workspace/ptuddd/baitap8/report/shots';

Future<void> _loadFonts() async {
  Future<ByteData> bytes(String name) async {
    final data = await File('$_fontDir/$name').readAsBytes();
    return ByteData.view(data.buffer);
  }

  final roboto = FontLoader('Roboto')
    ..addFont(bytes('Roboto-Regular.ttf'))
    ..addFont(bytes('Roboto-Medium.ttf'))
    ..addFont(bytes('Roboto-Bold.ttf'));
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(bytes('MaterialIcons-Regular.otf'));
  await icons.load();
}

Future<void> _shot(
  WidgetTester tester,
  Widget app,
  String name, {
  Future<void> Function()? interact,
}) async {
  await tester.runAsync(_loadFonts);
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 3.0;
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: app));
  await tester.pumpAndSettle();
  if (interact != null) {
    await interact();
    await tester.pumpAndSettle();
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final pngBytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.0);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = png!.buffer.asUint8List();
    image.dispose();
    return bytes;
  });
  final out = File('$_outDir/$name.png');
  await tester.runAsync(() async {
    await out.create(recursive: true);
    await out.writeAsBytes(pngBytes!);
  });
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
  debugPrint('saved $name.png (${pngBytes!.length} bytes)');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Đăng ký platform implementation cho federated plugin
    // (trong app thật việc này do GeneratedPluginRegistrant làm).
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        final tmp = await Directory.systemTemp.createTemp('baitap8_shots');
        return tmp.path;
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('dexterous.com/flutter/local_notifications'),
            (call) async {
      switch (call.method) {
        case 'initialize':
          return true;
        case 'pendingNotificationRequests':
          return <Map<String, Object?>>[];
        default:
          return null;
      }
    });
  });

  testWidgets('menu', (tester) async {
    await _shot(tester, const Bai8App(), 'menu');
  });

  testWidgets('bai1', (tester) async {
    await _shot(tester, const MaterialApp(home: Bai1Screen()), 'bai1');
  });

  testWidgets('bai2', (tester) async {
    await _shot(tester, const MaterialApp(home: Bai2Screen()), 'bai2');
  });

  testWidgets('bai3', (tester) async {
    await _shot(tester, const MaterialApp(home: Bai3Screen()), 'bai3');
  });

  testWidgets('bai4 - man hoc tu sau khi luu 1 tu', (tester) async {
    await _shot(
      tester,
      const MaterialApp(home: Bai4Screen()),
      'bai4',
      interact: () async {
        // Nhập từ + nghĩa rồi Lưu (gọi scheduleIn qua channel đã mock).
        await tester.enterText(find.byType(TextField).at(0), 'apple');
        await tester.enterText(find.byType(TextField).at(1), 'quả táo');
        await tester.tap(find.text('Lưu và Nhắc học sau 10 phút'));
        await tester.pumpAndSettle();
        // Mở drawer -> vào "Học từ".
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Học từ'));
      },
    );
  });

  testWidgets('homework', (tester) async {
    await _shot(
        tester, const MaterialApp(home: HomeworkScreen()), 'homework');
  });
}
