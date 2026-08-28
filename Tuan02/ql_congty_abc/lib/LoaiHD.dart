import 'package:ql_congty_abc/HoaDon.dart';

import 'dart:math';

class HoaDonCaNhan extends HoaDon {
  late double _khoangCach;

  HoaDonCaNhan() : super();

  HoaDonCaNhan.full(
    String maKH,
    String tenKH,
    int soLuong,
    double giaBan,
    this._khoangCach,
  ) : super.full(maKH, tenKH, soLuong, giaBan);

  @override
  double chietKhau() {
    double ck = (soLuong < 3) ? 0 : (0.05 * giaBan * soLuong);
    if (_khoangCach < 10) ck += (50000 * soLuong);
    return ck;
  }

  @override
  double troGia() {
    double tg = 0.02 * giaBan * soLuong;
    if (soLuong > 2) tg += 100000;
    return tg;
  }

  @override
  void xuat() {
    super.xuat();
    print('Khoảng cách: $_khoangCach km\n------------------------');
  }
}

class HoaDonDaiLy extends HoaDon {
  late int _thoiGianHopTac;

  HoaDonDaiLy() : super();

  HoaDonDaiLy.full(
    String maKH,
    String tenKH,
    int soLuong,
    double giaBan,
    this._thoiGianHopTac,
  ) : super.full(maKH, tenKH, soLuong, giaBan);

  @override
  double chietKhau() {
    double baseRate = 30.0;
    if (_thoiGianHopTac > 5) {
      baseRate += (_thoiGianHopTac - 5);
      baseRate = min(baseRate, 35.0);
    }
    return (baseRate / 100) * giaBan * soLuong;
  }

  @override
  double troGia() {
    return 0;
  }

  @override
  void xuat() {
    super.xuat();
    print('Thời gian hợp tác: $_thoiGianHopTac năm\n------------------------');
  }
}

class HoaDonCongTy extends HoaDon {
  late int _soNhanVien;

  HoaDonCongTy() : super();

  HoaDonCongTy.full(
    String maKH,
    String tenKH,
    int soLuong,
    double giaBan,
    this._soNhanVien,
  ) : super.full(maKH, tenKH, soLuong, giaBan);

  @override
  double chietKhau() {
    if (_soNhanVien > 5000) return 0.07 * giaBan * soLuong;
    if (_soNhanVien > 1000) return 0.05 * giaBan * soLuong;
    return 0;
  }

  @override
  double troGia() {
    return 120000.0 * soLuong;
  }

  @override
  void xuat() {
    super.xuat();
    print('Số nhân viên: $_soNhanVien\n------------------------');
  }
}
