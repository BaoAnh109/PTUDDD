import 'package:ql_mon_hoc/MonHoc.dart';

class LyThuyet extends MonHoc {
  late double _diemTieuLuan;
  late double _diemCuoiKy;

  LyThuyet(
    String maMon,
    String tenMon,
    int soTinChi,
    double diemTieuLuan,
    double diemCuoiKy,
  ) : super(maMon, tenMon, soTinChi) {
    _diemTieuLuan = diemTieuLuan;
    _diemCuoiKy = diemCuoiKy;
  }
  double get diemTieuLuan => _diemTieuLuan;
  double get diemCuoiKy => _diemCuoiKy;

  double tinhDiemTrungBinh() {
    return _diemTieuLuan * 0.3 + _diemCuoiKy * 0.7;
  }
}

class ThucHanh extends MonHoc {
  late double _ktl1;
  late double _ktl2;
  late double _ktl3;

  ThucHanh(
    String maMon,
    String tenMon,
    int soTinChi,
    double ktl1,
    double ktl2,
    double ktl3,
  ) : super(maMon, tenMon, soTinChi) {
    _ktl1 = ktl1;
    _ktl2 = ktl2;
    _ktl3 = ktl3;
  }
  double get ktl1 => _ktl1;
  double get ktl2 => _ktl2;
  double get ktl3 => _ktl3;

  double tinhDiemTrungBinh() {
    return (_ktl1 + _ktl2 + _ktl3) / 3;
  }
}

class DoAn extends MonHoc {
  late double _gVHuongDan;
  late double _gVPhanBien;

  DoAn(
    String maMon,
    String tenMon,
    int soTinChi,
    double gVHuongDan,
    double gVPhanBien,
  ) : super(maMon, tenMon, soTinChi) {
    _gVHuongDan = gVHuongDan;
    _gVPhanBien = gVPhanBien;
  }
  double get gVHuongDan => _gVHuongDan;
  double get gVPhanBien => _gVPhanBien;

  double tinhDiemTrungBinh() {
    return (_gVHuongDan + _gVPhanBien) / 2;
  }
}
