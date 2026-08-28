class SanPham {
  late String _maSP;
  late String _tenSP;
  late double _donGia;
  late double _giamGia;

  SanPham() {
    _maSP = 'SP001';
    _tenSP = 'Sản phẩm 1';
    _donGia = 100000;
    _giamGia = 0.1;
  }
  SanPham.fullPara(String maSP, String tenSP, double donGia, double giamGia) {
    _maSP = maSP;
    _tenSP = tenSP;
    _donGia = donGia;
    _giamGia = giamGia;
  }

  String get maSP => _maSP;
  set maSP(String value) {
    _maSP = value;
  }

  String get tenSP => _tenSP;
  set tenSP(String value) {
    _tenSP = value;
  }

  double get donGia => _donGia;
  set donGia(double value) {
    _donGia = value;
  }

  double get giamGia => _giamGia;
  set giamGia(double value) {
    _giamGia = value;
  }

  double getThueNhapKhau() {
    return _donGia * 0.1;
  }

  void showInfo() {
    print('Mã sản phẩm: $_maSP');
    print('Tên sản phẩm: $_tenSP');
    print('Đơn giá: $_donGia');
    print('Giảm giá: $_giamGia');
  }
}
