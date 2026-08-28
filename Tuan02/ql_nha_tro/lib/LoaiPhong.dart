import 'Phong.dart';

class LoaiPhongA extends Phong {
  late int _soNguoiThan;

  LoaiPhongA(
    String maPhong,
    int soNguoi,
    int soDien,
    int soNuoc,
    int soNguoiThan,
  ) : super(maPhong, soNguoi, soDien, soNuoc) {
    _soNguoiThan = soNguoiThan;
  }

  int get soNguoiThan => _soNguoiThan;
  set soNguoiThan(int value) {
    _soNguoiThan = value;
  }

  @override
  double tinhTienDien() {
    return 1400 + super.tinhTienDien() + _soNguoiThan * 50;
  }

  @override
  void showInfo() {
    super.showInfo();
    print('Số người thân: $_soNguoiThan');
  }
}

class LoaiPhongB extends Phong {
  late int _giatUi;
  late int _soMay;

  LoaiPhongB(
    String maPhong,
    int soNguoi,
    int soDien,
    int soNuoc,
    int giatUi,
    int soMay,
  ) : super(maPhong, soNguoi, soDien, soNuoc) {
    _giatUi = giatUi;
    _soMay = soMay;
  }

  int get giatUi => _giatUi;
  set giatUi(int value) {
    _giatUi = value;
  }

  int get soMay => _soMay;
  set soMay(int value) {
    _soMay = value;
  }

  @override
  double tinhTienDien() {
    return 1200 + super.tinhTienDien() + _soMay * 100 + _giatUi * 5;
  }

  @override
  void showInfo() {
    super.showInfo();
    print('Giặt ủi: $_giatUi');
    print('Số máy: $_soMay');
  }
}
