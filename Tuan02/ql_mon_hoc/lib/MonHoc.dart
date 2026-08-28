abstract class MonHoc {
  late String _tenMonHoc;
  late int _soTinChi;
  late String _maMonHoc;

  MonHoc(String maMonHoc, String tenMonHoc, int soTinChi) {
    _maMonHoc = maMonHoc;
    _tenMonHoc = tenMonHoc;
    _soTinChi = soTinChi;
  }

  String get maMonHoc => _maMonHoc;
  String get tenMonHoc => _tenMonHoc;
  int get soTinChi => _soTinChi;

  void hienThiThongTin() {
    print('Tên môn học: $_tenMonHoc');
    print('Mã môn học: $_maMonHoc');
    print('Số tín chỉ: $_soTinChi');
  }

  double tinhDiemTrungBinh();
}
