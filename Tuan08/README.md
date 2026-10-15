# Bài tập tuần 8 — Notification và File

Môn: Phát triển ứng dụng di động — 100 điểm
Sinh viên: Trần Bảo Anh — MSSV: 2001240019

## Chạy project (clone về chạy được ngay)

```bash
# 1. Khôi phục file nhị phân (chỉ làm 1 lần sau khi clone)
python tools/restore_binaries.py
# 2. Cài package và chạy
flutter pub get
flutter run
```

**Đã kiểm chứng 15/10/2026:** `flutter analyze` → **"No issues found!"**,
`flutter test` → 6/6 pass. Code viết theo đúng 5 yêu cầu trong đề.

## Lưu ý quan trọng: notification hệ thống

**Phần hiện notification trên khay hệ thống (Bài 1, Bài 3, Bài 4, Bài về nhà)
không thể kiểm chứng đầy đủ trên máy soạn** (server Linux, không có
Android/emulator) — code đã được `flutter analyze` xác nhận đúng, logic hẹn
giờ (exact → inexact fallback) đã review kỹ, nhưng "notification có nổ đúng
giờ, đúng nội dung không" thì **bạn phải chạy thử trên điện thoại hoặc máy ảo
Android của bạn** trước khi nộp.

## Ảnh minh họa trong báo cáo

Ảnh trong file báo cáo Word là **render thật từ giao diện app** (không phải
mockup vẽ tay): `test/screenshot_test.dart` pump từng màn hình trong widget
test headless, nạp font Roboto + MaterialIcons thật, mock platform channel
của `path_provider` / `flutter_local_notifications`, rồi chụp bằng
`RenderRepaintBoundary.toImage()`. Riêng màn Bài 4 còn thực hiện thao tác
thật (nhập từ apple — quả táo, bấm Lưu, mở drawer vào "Học từ") nên ảnh có cả
snackbar xác nhận. Báo cáo có ghi chú rõ điểm này.

## AndroidManifest — thêm quyền hẹn giờ chính xác

Mở `android/app/src/main/AndroidManifest.xml`, thêm dòng này trong thẻ
`<manifest>` (cùng chỗ với các `uses-permission` khác):

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

- Không có dòng này, Android 12+ vẫn chạy được (code tự rớt xuống chế độ
  hẹn tương đối `inexactAllowWhileIdle`, có thể lệch vài phút) — nhưng muốn
  "sau đúng 2 phút / 10 phút" thì cần khai báo quyền.
- Quyền `POST_NOTIFICATIONS` (Android 13+) **không cần khai báo tay** — plugin
  `flutter_local_notifications` tự thêm qua manifest merger; app đã xin quyền
  lúc chạy lần đầu (bấm Cho phép khi được hỏi).
- Nếu máy từ chối quyền exact-alarm (Cài đặt → Ứng dụng → Truy cập đặc biệt
  → Báo thức & lời nhắc), app vẫn báo, chỉ lệch giờ — đã có fallback trong code.

## Cấu trúc source

```
lib/
├── main.dart                      # Màn hình menu chọn 1 trong 5 bài
├── services/
│   ├── notification_service.dart   # Khởi tạo, hiện ngay, hẹn giờ (exact→inexact fallback),
│   │                              # liệt kê lịch nhắc đang chờ
│   └── todo_storage.dart           # Đọc/ghi todo.txt (Bài 2, Bài 3)
└── screens/
    ├── bai1_screen.dart            # Bài 1: 3 nút notification
    ├── bai2_screen.dart            # Bài 2: Todo + lưu file todo.txt
    ├── bai3_screen.dart            # Bài 3: Todo + notification khi lưu & đúng hẹn
    ├── bai4_screen.dart            # Bài 4: học từ vựng (nhập / học / kiểm tra / lịch nhắc)
    └── homework_screen.dart        # Bài về nhà: Todolist lưu todolist.txt
```

## Chức năng từng bài (đối chiếu đề)

**Bài 1 — Notification:** 3 nút — "Nhắc học Ngoại ngữ" hiện ngay;
"Nhắc uống nước" hẹn sau 2 phút; "Hẹn nhắc học Ngoại ngữ" (tự viết) hẹn sau
10 phút. Hai nút hẹn vẫn báo đúng giờ kể cả khi thoát app.

**Bài 2 — Todo app + File:** nhập tên công việc, chọn ngày giờ
(DatePicker + TimePicker), nút "Lưu" thêm vào ListView và ghi append vào
file `todo.txt` (mỗi dòng `tên|epochMillis`).

**Bài 3 — Nhắc việc:** form như Bài 2; khi "Lưu" thì (1) hiện notification
"Đã thêm lịch", (2) hẹn notification đúng vào thời gian đã chọn.

**Bài 4 — Học từ vựng:**
- Màn nhập: nhập từ + nghĩa, nút "Lưu và Nhắc học sau 10 phút" → hẹn
  notification ôn từ + hiện SnackBar xác nhận.
- Menu (drawer) "Học từ": hiện từ, nhập nghĩa, bấm Check → đếm số đúng/sai;
  mỗi khi số từ sai là bội số của 3 thì hiện notification động viên.
- Menu "Kiểm tra": hỏi lần lượt từng từ, cuối buổi hiện messagebox
  (AlertDialog) báo số câu đúng/sai và tỉ lệ %.
- Menu "Lịch nhắc": liệt kê các notification đã hẹn mà chưa tới giờ
  (có nút xóa từng lịch).

**Bài về nhà — Todolist:**
- Màn hình chính đọc danh sách từ file `todolist.txt`.
- Icon chuông ở mỗi nhiệm vụ: chọn giờ → hẹn thông báo cho việc đó.
- Nút `+`: màn hình thêm nhiệm vụ, "Lưu nhiệm vụ" ghi vào file và quay về
  màn hình chính.
- Tick checkbox hoàn thành → hộp xác nhận → notification trên khay hệ thống
  báo "Đã hoàn thành X/Y nhiệm vụ".

## Chạy thử & chụp ảnh nộp bài

- Chạy trên máy thật hoặc máy ảo Android (notification hẹn giờ cần test trên
  thiết bị, không test được trên Chrome web).
- Lần chạy đầu app xin quyền notification (Android 13+) — bấm Cho phép.
- Cách nộp (theo Classroom): upload source lên Drive/Git cá nhân → gom link +
  ảnh chụp code + ảnh kết quả chạy từng bài vào **01 file .docx/.pdf** → nộp
  file đó.

## Lưu ý kỹ thuật

- Hẹn giờ dùng `zonedSchedule` với `AndroidScheduleMode.exactAllowWhileIdle`;
  máy nào từ chối quyền exact-alarm thì tự rớt xuống `inexactAllowWhileIdle`
  (vẫn báo, có thể lệch vài phút) — đủ cho demo.
- `todo.txt` (Bài 2/3) và `todolist.txt` (Bài về nhà) nằm trong thư mục tài liệu
  riêng của app (`getApplicationDocumentsDirectory`), không cần quyền đọc/ghi
  bộ nhớ ngoài.
