abstract class HoaDon {
  late String _maKH;
  late String _tenKH;
  late int _soLuong;
  late double _giaBan;

  String get maKH => _maKH;
  set maKH(String value) {
    if (!(value.length == 6 &&
        value.startsWith('KH') &&
        value.substring(2).contains(RegExp(r'^\d{4}$')))) {
      throw ArgumentError(
        'Mã khach hàng phải có 6 ký tự, bắt đầu bằng "KH" và theo sau là 4 chữ số.',
      );
    }
    _maKH = value;
  }

  String get tenKH => _tenKH;
  set tenKH(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Tên khách hàng không được để trống.');
    }
    _tenKH = value;
  }

  int get soLuong => _soLuong;
  set soLuong(int value) {
    if (value <= 0) {
      throw ArgumentError('Số lượng phải lớn hơn 0.');
    }
    _soLuong = value;
  }

  double get giaBan => _giaBan;
  set giaBan(double value) {
    if (value <= 0) {
      throw ArgumentError('Giá bán phải lớn hơn 0.');
    }
    _giaBan = value;
  }

  HoaDon();

  HoaDon.full(String maKH, String tenKH, int soLuong, double giaBan) {
    this.maKH = maKH;
    this.tenKH = tenKH;
    this.soLuong = soLuong;
    this.giaBan = giaBan;
  }

  double thueVAT() {
    return 0.1 * _giaBan * _soLuong;
  }

  double chietKhau();
  double troGia();
  double thanhTien() {
    return (_soLuong * _giaBan) - chietKhau() + thueVAT() - troGia();
  }

  void xuat() {
    print('Mã KH: $maKH | Tên: $tenKH | Số lượng: $soLuong | Giá bán: $giaBan');
    print('Thuế VAT: $thueVAT | Chiết khấu: $chietKhau | Trợ giá: $troGia');
    print('Thành tiền: $thanhTien');
  }
}
