import 'dart:io';

import 'package:ql_mon_hoc/MonHoc.dart';
import 'package:ql_mon_hoc/Loai.dart';

Future<List<MonHoc>> readFile(String fileName) async {
  List<MonHoc> arrs = [];
  try {
    List<String> lines = await File(fileName).readAsLines();
    for (String line in lines) {
      List<String> parts = line.split('#');
      if (parts[0] == "LT") {
        arrs.add(
          LyThuyet(
            parts[1],
            parts[2],
            int.parse(parts[3]),
            double.parse(parts[4]),
            double.parse(parts[5]),
          ),
        );
      } else if (parts[0] == "TH") {
        arrs.add(
          ThucHanh(
            parts[1],
            parts[2],
            int.parse(parts[3]),
            double.parse(parts[4]),
            double.parse(parts[5]),
            double.parse(parts[6]),
          ),
        );
      } else if (parts[0] == "DA") {
        arrs.add(
          DoAn(
            parts[1],
            parts[2],
            int.parse(parts[3]),
            double.parse(parts[4]),
            double.parse(parts[5]),
          ),
        );
      }
    }
  } catch (e) {
    print('Lỗi khi đọc file: $e');
  }
  return arrs;
}
