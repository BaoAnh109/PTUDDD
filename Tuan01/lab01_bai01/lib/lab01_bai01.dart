import 'dart:io';

void Bai01() {
  int soQueKem;
  double giaTien;
  do {
    print("Nhập số que kem cần mua: ");
    soQueKem = int.parse(stdin.readLineSync()!);
  } while (soQueKem <= 0);
  do {
    print("Nhập giá tiền của một que kem: ");
    giaTien = double.parse(stdin.readLineSync()!);
  } while (giaTien <= 0);
  if (soQueKem >= 10) {
    double tongTien = soQueKem * giaTien * 0.9;
    print("Tổng tiền phải trả là: $tongTien");
  } else if (soQueKem >= 5) {
    double tongTien = soQueKem * giaTien * 0.95;
    print("Tổng tiền phải trả là: $tongTien");
  } else {
    double tongTien = soQueKem * giaTien;
    print("Tổng tiền phải trả là: $tongTien");
  }
}

void Bai02() {
  int number = getInput();
  print("Số chữ số: ${countDigits(number)}");
  print("Tổng các chữ số: ${sumDigits(number)}");
  print("Tất cả các chữ số đều là lẻ: ${checkOddDigits(number)}");
  print("Chữ số lớn nhất: ${findMaxDigit(number)}");
  print("Số nguyên tố: ${isPrime(number)}");
}

int getInput() {
  print("Nhập vào một số nguyên dương: ");
  do {
    int? number = int.tryParse(stdin.readLineSync() ?? '');
    if (number != null && number > 0) {
      return number;
    }
    print("Vui lòng nhập một số nguyên dương hợp lệ.");
  } while (true);
}

int countDigits(int number) {
  int count = 0;
  while (number != 0) {
    number ~/= 10;
    count++;
  }
  return count;
}

int sumDigits(int number) {
  int sum = 0;
  while (number != 0) {
    sum += number % 10;
    number ~/= 10;
  }
  return sum;
}

bool checkOddDigits(int number) {
  while (number != 0) {
    if ((number % 10) % 2 == 0) {
      return false;
    }
    number ~/= 10;
  }
  return true;
}

int findMaxDigit(int number) {
  int maxDigit = 0;
  while (number != 0) {
    int digit = number % 10;
    if (digit > maxDigit) {
      maxDigit = digit;
    }
    number ~/= 10;
  }
  return maxDigit;
}

bool isPrime(int number) {
  if (number <= 1) return false;
  for (int i = 2; i <= number ~/ 2; i++) {
    if (number % i == 0) {
      return false;
    }
  }
  return true;
}
