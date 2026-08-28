abstract class Phong {
  late String _maPhong;
  late int _soNguoi;
  late int _soDien;
  late int _soNuoc;

  Phong(String maPhong, int soNguoi, int soDien, int soNuoc) {
    _maPhong = maPhong;
    _soNguoi = soNguoi;
    _soDien = soDien;
    _soNuoc = soNuoc;
  }

  String get maPhong => _maPhong;
  int get soNguoi => _soNguoi;
  int get soDien => _soDien;
  int get soNuoc => _soNuoc;

  double tinhTienDien() {
    return _soDien * 2 + _soNuoc * 8;
  }

  void showInfo() {
    print('Mã phòng: $_maPhong');
    print('Số người: $_soNguoi');
    print('Số điện: $_soDien');
    print('Số nước: $_soNuoc');
  }
}
