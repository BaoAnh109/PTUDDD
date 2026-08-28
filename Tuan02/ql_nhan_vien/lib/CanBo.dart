import 'NhanVien.dart';

class CanBo extends Nhanvien {
  late String _chucVu = '';
  late double _hsChucVu = 0;
  CanBo() : super() {
    _chucVu = "Unknow";
    _hsChucVu = 0;
  }
  CanBo.fullPara(
    String manv,
    String tennv,
    double hsl,
    String pb,
    double songaylv,
    String chucvu,
    double hscv,
  ) : super.fullPara(manv, tennv, hsl, pb, songaylv) {
    _chucVu = chucvu;
    _hsChucVu = hscv;
  }
  @override
  String toString() {
    return super.toString() + "\t$_chucVu\t$_hsChucVu";
  }
}
