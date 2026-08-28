import 'Phong.dart';
import 'LoaiPhong.dart';

import 'dart:io';

Future<List<Phong>> docFile(String file) async {
  List<Phong> listPhong = [];
  try {
    var lines = await File(file).readAsLines();
    for (var line in lines) {
      var parts = line.split('#');
      if (parts[0].contains('A')) {
        listPhong.add(
          LoaiPhongA(
            parts[0],
            int.parse(parts[1]),
            int.parse(parts[2]),
            int.parse(parts[3]),
            int.parse(parts[4]),
          ),
        );
      } else if (parts[0].contains('B')) {
        listPhong.add(
          LoaiPhongB(
            parts[0],
            int.parse(parts[1]),
            int.parse(parts[2]),
            int.parse(parts[3]),
            int.parse(parts[4]),
            int.parse(parts[5]),
          ),
        );
      }
    }
  } catch (e) {
    print('Lỗi khi đọc file: $e');
  }
  return listPhong;
}
