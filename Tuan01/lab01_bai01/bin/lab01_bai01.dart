import 'package:lab01_bai01/lab01_bai01.dart' as lab01_bai01;

import 'dart:io';

void main(List<String> arguments) {
  int choice;
  do {
    print("Chọn bài tập, nhập 0 để thoát:");
    choice = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
    switch (choice) {
      case 1:
        lab01_bai01.Bai01();
        break;
      case 2:
        lab01_bai01.Bai02();
        break;
      case 0:
        print("Thoát chương trình.");
        break;
      default:
        print("Lựa chọn không hợp lệ. Vui lòng chọn lại.");
    }
  } while (choice != 0);
}
