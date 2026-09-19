import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoMo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD82D8B)),
      ),
      home: const MoMoHomePage(),
    );
  }
}

class GridItem {
  final String title;
  final IconData icon;
  final Color color;

  const GridItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class MoMoHomePage extends StatefulWidget {
  const MoMoHomePage({super.key});

  @override
  State<MoMoHomePage> createState() => _MoMoHomePageState();
}

class _MoMoHomePageState extends State<MoMoHomePage> {
  static const Color momoPink = Color(0xFFD82D8B);

  int selectedIndex = 0;

  final List<GridItem> lst = const [
    GridItem(title: 'Chuyển tiền', icon: Icons.attach_money, color: Colors.red),
    GridItem(
      title: 'Thanh toán hóa đơn',
      icon: Icons.receipt_long,
      color: Colors.cyan,
    ),
    GridItem(
      title: 'Nạp tiền điện thoại',
      icon: Icons.phone_android,
      color: Colors.blue,
    ),
    GridItem(
      title: 'Mua mã thẻ di động',
      icon: Icons.sim_card,
      color: Colors.deepOrange,
    ),
    GridItem(title: 'Heo Đất MoMo', icon: Icons.savings, color: Colors.orange),
    GridItem(
      title: 'Đi bộ cùng MoMo',
      icon: Icons.directions_walk,
      color: Colors.green,
    ),
    GridItem(
      title: 'Thanh toán nước',
      icon: Icons.water_drop,
      color: Colors.lightBlue,
    ),
    GridItem(
      title: 'Quản lý chi tiêu',
      icon: Icons.account_balance_wallet,
      color: Colors.teal,
    ),
    GridItem(title: 'Quỹ nhóm', icon: Icons.groups, color: Colors.pink),
    GridItem(title: 'Chứng khoán', icon: Icons.show_chart, color: Colors.blue),
    GridItem(
      title: 'Vietlott SMS',
      icon: Icons.confirmation_number,
      color: Colors.red,
    ),
    GridItem(
      title: 'Xem thêm dịch vụ',
      icon: Icons.grid_view,
      color: Colors.grey,
    ),
  ];

  final List<GridItem> lstDeXuat = const [
    GridItem(
      title: 'Vay Nhanh',
      icon: Icons.monetization_on,
      color: Colors.orange,
    ),
    GridItem(title: 'Mua vé xem', icon: Icons.movie, color: Colors.orange),
    GridItem(
      title: 'Túi Thần Tài',
      icon: Icons.auto_awesome,
      color: Colors.red,
    ),
    GridItem(title: 'Ví Trả Sau', icon: Icons.credit_card, color: Colors.pink),
  ];

  void showMessage(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: Text('Bạn đã chọn $title'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildGridView(List<GridItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 6,
        mainAxisSpacing: 8,
        mainAxisExtent: 90,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            showMessage(items[index].title);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: items[index].color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  items[index].icon,
                  color: items[index].color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: Text(
                  items[index].title,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildEventBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/banner.jpg',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget buildPromotionBanner() {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE579),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('💕', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2025 nhà ai mà nở hoa?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF814524),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gieo quẻ với AI, tìm quý nhân của bạn',
                  maxLines: 2,
                  style: TextStyle(fontSize: 14, color: Color(0xFF814524)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: () {
              showMessage('Gieo ngay');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: momoPink),
              ),
              child: const Text(
                'Gieo ngay',
                style: TextStyle(
                  color: momoPink,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavigationItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          showMessage(title);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: isSelected ? momoPink : Colors.grey),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? momoPink : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  children: [
                    buildNavigationItem(Icons.home_outlined, 'MoMo', 0),
                    buildNavigationItem(
                      Icons.card_giftcard_outlined,
                      'Ưu đãi',
                      1,
                    ),
                    const SizedBox(width: 70),
                    buildNavigationItem(Icons.history, 'Lịch sử GD', 3),
                    buildNavigationItem(Icons.person_outline, 'Tôi', 4),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -10,
              child: InkWell(
                onTap: () {
                  showMessage('Quét mọi QR');
                },
                child: Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: momoPink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Quét mọi QR',
                      style: TextStyle(fontSize: 10, color: momoPink),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          children: [
            buildGridView(lst),

            const SizedBox(height: 15),

            buildTitle('Sự kiện đang diễn ra'),

            const SizedBox(height: 8),

            buildEventBanner(),

            const SizedBox(height: 18),

            buildTitle('MoMo đề xuất'),

            const SizedBox(height: 12),

            buildGridView(lstDeXuat),

            const SizedBox(height: 14),

            buildPromotionBanner(),

            const SizedBox(height: 18),

            buildTitle('Có thể bạn quan tâm'),

            const SizedBox(height: 10),

            Container(
              width: 45,
              height: 3,
              alignment: Alignment.centerLeft,
              child: Container(
                width: 45,
                height: 3,
                decoration: BoxDecoration(
                  color: momoPink,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}
