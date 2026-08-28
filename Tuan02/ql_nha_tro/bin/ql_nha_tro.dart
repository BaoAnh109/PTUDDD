import 'package:ql_nha_tro/Phong.dart';
import 'package:ql_nha_tro/LoaiPhong.dart';
import 'package:ql_nha_tro/DocFile.dart';

double tinhTongTienDien(List<Phong> listPhong) {
  double tongTien = 0;
  for (var phong in listPhong) {
    tongTien += phong.tinhTienDien();
  }
  return tongTien;
}

List<Phong> sapXepTheoSoDien(List<Phong> listPhong) {
  listPhong.sort((a, b) => a.soDien.compareTo(b.soDien));
  return listPhong;
}

void main() async {
  List<Phong> listPhong = await docFile('lib/phongthue.txt');
  for (var phong in listPhong) {
    phong.showInfo();
    print('Tiền điện: ${phong.tinhTienDien()}');
    print('-------------------------');
  }

  List<Phong> listPhongNg = listPhong
      .where((phong) => phong.soNguoi >= 2)
      .toList();
  print('Các phòng có ít nhất 2 người:');
  for (var phong in listPhongNg) {
    phong.showInfo();
    print('Tiền điện: ${phong.tinhTienDien()}');
    print('-------------------------');
  }
  print('-------------------------');
  print('-------------------------');
  print('Tổng tiền điện của tất cả các phòng: ${tinhTongTienDien(listPhong)}');

  print('-------------------------');
  print('Danh sách phòng sau khi sắp xếp theo số điện:');
  List<Phong> listPhongSapXep = sapXepTheoSoDien(listPhong);
  for (var phong in listPhongSapXep) {
    phong.showInfo();
    print('Tiền điện: ${phong.tinhTienDien()}');
    print('-------------------------');
  }

  print('-------------------------');
  print('Danh sách loại phòng A:');
  List<Phong> listLoaiPhongA = listPhong
      .where((phong) => phong is LoaiPhongA)
      .toList();
  for (var phong in listLoaiPhongA) {
    phong.showInfo();
    print('Tiền điện: ${phong.tinhTienDien()}');
    print('-------------------------');
  }
}
