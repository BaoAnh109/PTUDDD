# Bài tập tuần 7 — Multimedia: Google Maps

Môn: Phát triển ứng dụng di động (HUIT-15DHTH02)
Sinh viên: Trần Bảo Anh — MSSV: 2001240019

## Chạy project (clone về chạy được ngay)

```bash
# 1. Khôi phục file nhị phân (chỉ làm 1 lần sau khi clone)
python tools/restore_binaries.py
# 2. Cài package và chạy
flutter pub get
flutter run
```

`flutter analyze` → **No issues found!** (kiểm chứng 15/10/2026).

> ⚠️ **Google Maps cần API key mới hiện bản đồ:** xem "Bước 1" bên dưới.
> Ngoài ra project Google Cloud phải bật Billing (cần thẻ ngân hàng) thì 4 API
> mới trả dữ liệu — chưa bật là bản đồ xám / lỗi `REQUEST_DENIED`. Google cho
> $200 credit miễn phí mỗi tháng; chạy demo bài tập chỉ tốn vài xu, nhớ tắt/xóa
> key sau khi nộp bài.

## Cấu trúc source

```
lib/
├── main.dart                      # Màn hình menu chọn bài
├── api_key.dart                    # ← THAY API KEY CỦA BẠN VÀO ĐÂY
├── services/
│   ├── directions_service.dart     # Gọi Directions API + giải mã polyline
│   ├── places_service.dart        # Tìm địa điểm bằng Places API
│   ├── geocoding_service.dart     # Địa chỉ → tọa độ (Geocoding API)
│   └── favorites_db.dart          # Lưu tuyến đường yêu thích (SQLite)
└── screens/
    ├── bai1_screen.dart           # Bài 1: Map Navigator
    ├── bai2_screen.dart           # Bài 2: Route Finder
    ├── bai4_screen.dart           # Bài 4 (trên lớp): tìm đường nâng cao
    ├── homework_screen.dart       # Bài tập về nhà
    └── favorites_screen.dart      # Danh sách tuyến đường yêu thích
```

## Bước 1 — Lấy Google Maps API Key (bắt buộc)

1. Vào [Google Cloud Console](https://console.cloud.google.com/), tạo project mới.
2. **APIs & Services > Library**: bật 4 API:
   - Maps SDK for Android
   - Directions API
   - Geocoding API
   - Places API
3. **APIs & Services > Credentials > Create Credentials > API Key** → copy key.
4. Mở file `lib/api_key.dart`, thay `'YOUR_API_KEY_HERE'` bằng key vừa copy.
5. Mở file `android/app/src/main/AndroidManifest.xml`, thêm trong thẻ `<application>`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="KEY_CUA_BAN"/>
   ```
   và quyền vị trí (nếu chưa có):
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   ```

## Bước 2 — Chạy app

```bash
flutter pub get
flutter run
```

- Chạy trên máy thật hoặc máy ảo **có bật GPS / vị trí**.
- Màn hình menu liệt kê 4 bài: Bài 1, Bài 2, Bài 4 (trên lớp), Bài tập về nhà.

## Chức năng từng bài

**Bài 1 — Map Navigator:** hiện bản đồ, marker "Vị trí của bạn", marker "Đích đến"
(TP.HCM 10.7769, 106.7009), vẽ đường đi (polyline xanh) bằng Directions API.

**Bài 2 — Route Finder:** nhập 2 tọa độ dạng `lat, lng` (VD: `10.7769, 106.7009`),
bấm "Tìm đường đi" → đánh dấu 2 marker + vẽ đường đi. Ô xuất phát tự điền
vị trí hiện tại.

**Bài 4 (trên lớp):**
1. Nút la bàn "Lấy vị trí hiện tại làm điểm đích".
2. Hiển thị khoảng cách + thời gian di chuyển (từ Directions API).
3. Chạm trực tiếp lên bản đồ để chọn điểm đích.
4. Tìm kiếm địa điểm (khách sạn, quán ăn, bệnh viện...) bằng Places API —
   chạm vào kết quả để đặt làm điểm đích.

**Bài tập về nhà:**
1. Nhập địa chỉ chữ (VD: "227 Nguyễn Văn Cừ, TP.HCM") → chuyển thành tọa độ
   bằng Geocoding API (có nút tìm riêng cho điểm xuất phát / đích).
2. Chọn phương tiện: Ô tô / Xe máy / Đi bộ (Directions API, mode tương ứng).
   *Ghi chú: Directions API không có chế độ xe máy riêng nên dùng tuyến ô tô.*
3. Vẽ đường đi + hiển thị khoảng cách / thời gian.
4. Nút "Lưu yêu thích" → lưu tuyến đường vào SQLite; mở danh sách yêu thích
   (icon trái tim) → chạm để vẽ lại tuyến đường đã lưu, hoặc xóa.

## Cách nộp bài (theo yêu cầu trên Classroom)

1. Upload toàn bộ source lên Google Drive / Git cá nhân.
2. Chụp hình source code + kết quả chạy từng bài, gom cùng đường dẫn Drive/Git
   vào **01 file .docx hoặc .pdf**.
3. Nộp file đó lên Classroom (không nộp source trực tiếp).
