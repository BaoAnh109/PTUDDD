class Nhanvien {
  late String _maNV;
  late String _tenNV;
  late double _heSoLuong;
  late String _phongBan;
  late double _soNgayLV;

  static double LCB = 2340;
  Nhanvien() {
    _maNV = "NV000";
    _tenNV = "Trần Bảo Anh";
    _heSoLuong = 2.34;
    _phongBan = "Tổ chức";
    _soNgayLV = 22;
  }
  Nhanvien.fullPara(
    String manv,
    String tennv,
    double hsl,
    String pb,
    double songaylv,
  ) {
    _maNV = manv;
    _tenNV = tennv;
    _heSoLuong = hsl;
    _phongBan = pb;
    _soNgayLV = songaylv;
  }
  String xepLoai() {
    if (_soNgayLV > 25) {
      return 'A';
    } else if (_soNgayLV > 22) {
      return 'B';
    } else {
      return 'C';
    }
  }

  double tinhLuong() {
    String xLoai = xepLoai();
    double hsThiDua = 0.5;
    if (xLoai == 'A') {
      hsThiDua = 1;
    } else if (xLoai == 'B') {
      hsThiDua = 0.5;
    } else {
      hsThiDua = 0;
    }
    return LCB * _heSoLuong + hsThiDua * LCB;
  }

  @override
  String toString() {
    return "$_maNV\t $_tenNV\t$_heSoLuong\t$_soNgayLV\t${xepLoai()}\t${tinhLuong()}";
  }
}
