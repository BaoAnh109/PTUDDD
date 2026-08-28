import 'package:ql_nhan_vien/NhanVien.dart';
import 'package:ql_nhan_vien/CanBo.dart';

void main() {
  Nhanvien nv = Nhanvien.fullPara(
    "NV001",
    "Nguyễn Trần Tuấn",
    2.34,
    "Tổ chức",
    23,
  );
  CanBo cb = CanBo.fullPara(
    'NV002',
    'Trần Văn Bình',
    2.34,
    "Tổ chức",
    26,
    "Trưởng phòng",
    2.0,
  );
  Nhanvien nv3 = Nhanvien.fullPara("NV003", "Nguyễn Nam", 2.34, "Nhân sự", 27);
  List<Nhanvien> lstNhanVien = [];
  lstNhanVien.add(nv);
  lstNhanVien.add(cb);
  lstNhanVien.add(nv3);
  print("Danh sách nhân viên và cán bộ: ");
  for (Nhanvien x in lstNhanVien) {
    print(x);
  }

  List<Nhanvien> lstLoaiA = lstNhanVien
      .where((a) => a.xepLoai() == "A")
      .toList();
  print('Danh sách nhân viên và cán bộ xếp loại A:');
  for (Nhanvien x in lstLoaiA) {
    print(x);
  }
}
