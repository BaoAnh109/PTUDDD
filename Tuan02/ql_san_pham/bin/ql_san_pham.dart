import 'package:ql_san_pham/ql_san_pham.dart';
import 'package:ql_san_pham/docFile.dart';

void main() async {
  List<SanPham> ds = await readFile('lib/sanpham.txt');
  print("Đọc dữ liệu từ file: ");
  for (SanPham x in ds) {
    x.showInfo();
  }
}
