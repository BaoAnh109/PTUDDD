import 'package:ql_mon_hoc/MonHoc.dart';
import 'package:ql_mon_hoc/Loai.dart';
import 'package:ql_mon_hoc/DocFile.dart';

import 'dart:io';

void nhapMonHoc(List<MonHoc> danhSachMonHoc) {
  print('Nhập số lượng môn học:');
  int soLuong = int.parse(stdin.readLineSync()!);

  for (int i = 0; i < soLuong; i++) {
    print('Nhập thông tin môn học thứ ${i + 1}:');
    print('Chọn loại môn học (1: Lý thuyết, 2: Thực hành, 3: Đồ án):');
    int loai = int.parse(stdin.readLineSync()!);

    print('Nhập mã môn học:');
    String maMon = stdin.readLineSync()!;
    print('Nhập tên môn học:');
    String tenMon = stdin.readLineSync()!;
    print('Nhập số tín chỉ:');
    int soTinChi = int.parse(stdin.readLineSync()!);

    if (loai == 1) {
      print('Nhập điểm tiểu luận:');
      double diemTieuLuan = double.parse(stdin.readLineSync()!);
      print('Nhập điểm cuối kỳ:');
      double diemCuoiKy = double.parse(stdin.readLineSync()!);
      danhSachMonHoc.add(
        LyThuyet(maMon, tenMon, soTinChi, diemTieuLuan, diemCuoiKy),
      );
    } else if (loai == 2) {
      print('Nhập điểm kiểm tra lần 1:');
      double ktl1 = double.parse(stdin.readLineSync()!);
      print('Nhập điểm kiểm tra lần 2:');
      double ktl2 = double.parse(stdin.readLineSync()!);
      print('Nhập điểm kiểm tra lần 3:');
      double ktl3 = double.parse(stdin.readLineSync()!);
      danhSachMonHoc.add(ThucHanh(maMon, tenMon, soTinChi, ktl1, ktl2, ktl3));
    } else if (loai == 3) {
      print('Nhập điểm giảng viên hướng dẫn:');
      double gVHuongDan = double.parse(stdin.readLineSync()!);
      print('Nhập điểm giảng viên phản biện:');
      double gVPhanBien = double.parse(stdin.readLineSync()!);
      danhSachMonHoc.add(DoAn(maMon, tenMon, soTinChi, gVHuongDan, gVPhanBien));
    } else {
      print('Loại môn học không hợp lệ. Vui lòng thử lại.');
      i--;
    }
  }
}

void showListMonHoc(List<MonHoc> danhSachMonHoc) {
  print('Danh sách môn học:');
  for (var monHoc in danhSachMonHoc) {
    monHoc.hienThiThongTin();
    print('Điểm trung bình: ${monHoc.tinhDiemTrungBinh()}');
    print('-------------------------');
  }
}

bool isSorted(List<MonHoc> danhSachMonHoc) {
  for (int i = 0; i < danhSachMonHoc.length - 1; i++) {
    if (danhSachMonHoc[i].tenMonHoc.compareTo(danhSachMonHoc[i + 1].tenMonHoc) >
        0) {
      return false;
    }
  }
  return true;
}

List<MonHoc> sortBySoTC(List<MonHoc> danhSachMonHoc) {
  danhSachMonHoc.sort((a, b) => a.soTinChi.compareTo(b.soTinChi));
  return danhSachMonHoc;
}

MonHoc? findMaxSoTC(List<MonHoc> danhSachMonHoc) {
  if (danhSachMonHoc.isEmpty) {
    return null;
  }

  MonHoc maxSoTC = danhSachMonHoc[0];
  for (var monHoc in danhSachMonHoc) {
    if (monHoc.soTinChi > maxSoTC.soTinChi) {
      maxSoTC = monHoc;
    }
  }
  return maxSoTC;
}

void checkTenMonHoc(List<MonHoc> danhSachMonHoc, String tenMonHoc) {
  for (var monHoc in danhSachMonHoc) {
    if (monHoc.tenMonHoc == tenMonHoc) {
      print('Môn học "$tenMonHoc" có trong danh sách.');
      monHoc.hienThiThongTin();
      return;
    }
  }
  print('Môn học "$tenMonHoc" không có trong danh sách.');
  danhSachMonHoc.add(LyThuyet('MH000', tenMonHoc, 0, 0.0, 0.0));
}

int countSoTinChi(List<MonHoc> danhSachMonHoc) {
  int totalSoTinChi = 0;
  for (var monHoc in danhSachMonHoc) {
    totalSoTinChi += monHoc.soTinChi;
  }
  return totalSoTinChi;
}

void main() async {
  List<MonHoc> danhSachMonHoc = [];
  nhapMonHoc(danhSachMonHoc);
  showListMonHoc(danhSachMonHoc);
  print('-----------------------------------------------------------------');
  if (isSorted(danhSachMonHoc)) {
    print('Danh sách môn học đã được sắp xếp theo tên môn học.');
  } else {
    print('Danh sách môn học chưa được sắp xếp theo tên môn học.');
  }
  print('-----------------------------------------------------------------');
  print('Danh sách môn học sau khi sắp xếp theo số tín chỉ:');
  List<MonHoc> danhSachMonHocSorted = sortBySoTC(danhSachMonHoc);
  showListMonHoc(danhSachMonHocSorted);
  print('-----------------------------------------------------------------');
  MonHoc? monHocMaxSoTC = findMaxSoTC(danhSachMonHoc);
  if (monHocMaxSoTC != null) {
    print('Môn học có số tín chỉ cao nhất:');
    monHocMaxSoTC.hienThiThongTin();
  }
  print('-----------------------------------------------------------------');
  print('Nhập tên môn học cần kiểm tra:');
  String tenMonHocCanKiemTra = stdin.readLineSync()!;
  checkTenMonHoc(danhSachMonHoc, tenMonHocCanKiemTra);
  print('-----------------------------------------------------------------');

  List<MonHoc> danhSachMonHocTuFile = await readFile('lib/MonHoc.txt');
  print('Danh sách môn học từ file:');
  showListMonHoc(danhSachMonHocTuFile);
  print('-----------------------------------------------------------------');
  int tongSoTinChi = countSoTinChi(danhSachMonHocTuFile);
  print('Tổng số tín chỉ của các môn học trong file: $tongSoTinChi');
}
