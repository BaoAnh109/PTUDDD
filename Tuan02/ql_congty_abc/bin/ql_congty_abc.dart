import 'package:ql_congty_abc/QLHoaDon.dart';

import 'dart:io';

void tamDung() {
  stdout.write('\nNhấn Enter để tiếp tục...');
  stdin.readLineSync();
}

void main(List<String> arguments) {
  QuanLyHoaDon ql = QuanLyHoaDon();
  ql.nhapDanhSach();
  while (true) {
    print('\n===== QUẢN LÝ HÓA ĐƠN ABC =====');
    print('1. Nhập danh sách hóa đơn');
    print('2. Xuất danh sách hóa đơn');
    print('3. Tính tổng thành tiền');
    print('4. Tính tổng tiền trợ giá công ty đã hỗ trợ');
    print('5. Thông tin khách hàng mua nhiều nhất');
    print('6. Tổng tiền chiết khấu đối với khách hàng công ty');
    print('7. Sắp xếp danh sách (SL tăng dần, Thành tiền giảm dần)');
    print('8. Tìm kiếm hóa đơn theo Mã khách hàng');
    print('0. Thoát chương trình');
    stdout.write('Chọn chức năng: ');

    String choice = stdin.readLineSync() ?? '';
    switch (choice) {
      case '1':
        ql.nhapDanhSach();
        break;
      case '2':
        ql.xuatDanhSach();
        break;
      case '3':
        print('=> Tổng thành tiền tất cả hóa đơn: ${ql.tongThanhTien()}');
        break;
      case '4':
        print('=> Tổng tiền trợ giá: ${ql.tongTroGia()}');
        break;
      case '5':
        ql.khachHangMuaNhieuNhat();
        break;
      case '6':
        print('=> Tổng chiết khấu cho KH Công Ty: ${ql.tongChietKhauCongTy()}');
        break;
      case '7':
        ql.sapXepDanhSach();
        ql.xuatDanhSach();
        break;
      case '8':
        stdout.write('Nhập mã KH cần tìm: ');
        String ma = stdin.readLineSync()?.trim() ?? '';
        ql.timKiemTheoMaKH(ma);
        break;
      case '0':
        print('Chương trình kết thúc. Chào tạm biệt!');
        return;
      default:
        print('Lựa chọn không hợp lệ, vui lòng chọn lại!');
    }
    tamDung();
  }
}
