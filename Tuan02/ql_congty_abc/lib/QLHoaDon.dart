import 'HoaDon.dart';
import 'LoaiHD.dart';

import 'dart:io';
import 'dart:math';

class QuanLyHoaDon {
  final List<HoaDon> _dsHoaDon;

  QuanLyHoaDon() : _dsHoaDon = [];

  QuanLyHoaDon.fromList(List<HoaDon> hoaDon)
    : _dsHoaDon = List<HoaDon>.from(hoaDon);

  List<HoaDon> get dsHoaDon => List.unmodifiable(_dsHoaDon);

  void nhapDanhSach([String tenFile = 'hoa_don.txt']) {
    final file = File(tenFile);
    if (!file.existsSync()) {
      print('Không tìm thấy file dữ liệu: $tenFile');
      return;
    }

    _dsHoaDon.clear();
    final dongDuLieu = file.readAsLinesSync();
    for (var i = 0; i < dongDuLieu.length; i++) {
      final dong = dongDuLieu[i].trim();
      if (dong.isEmpty || dong.startsWith('#')) continue;

      try {
        final parts = dong.split('|');
        if (parts.length != 6) {
          throw const FormatException('Dòng phải có 6 trường dữ liệu.');
        }

        final loai = parts[0].trim().toUpperCase();
        final maKH = parts[1].trim();
        final tenKH = parts[2].trim();
        final soLuong = int.parse(parts[3].trim());
        final giaBan = double.parse(parts[4].trim());
        final thamSoRieng = double.parse(parts[5].trim());

        switch (loai) {
          case 'CA_NHAN':
            _dsHoaDon.add(
              HoaDonCaNhan.full(maKH, tenKH, soLuong, giaBan, thamSoRieng),
            );
            break;
          case 'DAI_LY':
            _dsHoaDon.add(
              HoaDonDaiLy.full(
                maKH,
                tenKH,
                soLuong,
                giaBan,
                thamSoRieng.toInt(),
              ),
            );
            break;
          case 'CONG_TY':
            _dsHoaDon.add(
              HoaDonCongTy.full(
                maKH,
                tenKH,
                soLuong,
                giaBan,
                thamSoRieng.toInt(),
              ),
            );
            break;
          default:
            throw const FormatException('Loại hóa đơn không hợp lệ.');
        }
      } on FormatException catch (e) {
        print('Bỏ qua dòng ${i + 1}: ${e.message}');
      } on ArgumentError catch (e) {
        print('Bỏ qua dòng ${i + 1}: ${e.message}');
      }
    }
    print('Đã nhập ${_dsHoaDon.length} hóa đơn từ file $tenFile.');
  }

  void xuatDanhSach() {
    if (dsHoaDon.isEmpty) {
      print('Danh sách hóa đơn trống.');
      return;
    }
    print('\n=== DANH SÁCH HÓA ĐƠN ===');
    for (var hd in dsHoaDon) {
      hd.xuat();
    }
  }

  double tongThanhTien() {
    return dsHoaDon.fold(0, (sum, hd) => sum + hd.thanhTien());
  }

  double tongTroGia() {
    return dsHoaDon.fold(0, (sum, hd) => sum + hd.troGia());
  }

  void khachHangMuaNhieuNhat() {
    if (dsHoaDon.isEmpty) return;
    int maxSL = dsHoaDon.map((e) => e.soLuong).reduce(max);
    var dsMax = dsHoaDon.where((hd) => hd.soLuong == maxSL).toList();

    print('\n=== KHÁCH HÀNG MUA NHIỀU NHẤT (Số lượng: $maxSL) ===');
    for (var hd in dsMax) {
      hd.xuat();
    }
  }

  double tongChietKhauCongTy() {
    return dsHoaDon.whereType<HoaDonCongTy>().fold(
      0,
      (sum, hd) => sum + hd.chietKhau(),
    );
  }

  void sapXepDanhSach() {
    dsHoaDon.sort((a, b) {
      int cmpSL = a.soLuong.compareTo(b.soLuong);
      if (cmpSL != 0) return cmpSL;
      return b.thanhTien().compareTo(a.thanhTien());
    });
    print('\n=> Đã sắp xếp danh sách (SL tăng dần, Thành tiền giảm dần).');
  }

  void timKiemTheoMaKH(String maTimKiem) {
    var ketQua = dsHoaDon.where((hd) => hd.maKH == maTimKiem).toList();
    if (ketQua.isEmpty) {
      print('=> Khách hàng lạ');
    } else {
      print('\n=== KẾT QUẢ TÌM KIẾM MÃ: $maTimKiem ===');
      for (var hd in ketQua) {
        hd.xuat();
      }
    }
  }
}
