import 'package:flutter/material.dart';
import 'dart:math';
import 'user_screen.dart';
import 'dart:math' show cos, sqrt, asin;

void main() {
  runApp(const EVChargingApp());
}

class EVChargingApp extends StatelessWidget {
  const EVChargingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV Hue Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const LoginPage(),
    );
  }
}

// --- MODELS ---
class Station {
  String id, code, name, address;
  double voltage; // V
  double power;   // kW
  String chargingType; // AC/DC
  double pricePerKwh;
  int activePorts;
  bool isActive;
  double lat; // Vĩ độ
  double lng; // Kinh độ

  Station({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    this.voltage = 220,
    required this.power,
    required this.chargingType,
    required this.pricePerKwh,
    required this.activePorts,
    this.isActive = true,
    required this.lat,
    required this.lng,
  });
}

class Booking {
  String id, userName, userPhone, carPlate, stationName, date, time, status, cancelReason;
  double totalKwh;
  Booking({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.carPlate,
    required this.stationName,
    required this.date,
    required this.time,
    required this.totalKwh,
    this.status = "Đã xác nhận",
    this.cancelReason = "",
  });
}

// --- MOCK DATABASE ---
class AppData {
  static final Random _random = Random();
  static List<Station> stations = List.generate(10, (index) {
    List<String> hueLocations = ["Tràng Tiền", "Đại Nội", "Đông Ba", "Tự Đức", "Vỹ Dạ", "Ngự Bình", "Tòa Khâm", "Thuận An", "Kim Long", "An Cựu"];
    return Station(
      id: DateTime.now().millisecondsSinceEpoch.toString() + index.toString(),
      code: (10000000 + _random.nextInt(90000000)).toString(),
      name: "Trạm ${hueLocations[index]}",
      address: "TP. Huế",
      power: 7 + _random.nextDouble() * 3,
      chargingType: _random.nextBool() ? "AC" : "DC",
      pricePerKwh: 6000 + _random.nextInt(3001).toDouble(),
      activePorts: 6 + _random.nextInt(4),
      lat: 16.46 + (_random.nextDouble() * 0.05), // Tạo tọa độ giả quanh Huế
    lng: 107.58 + (_random.nextDouble() * 0.05),
    );
  });

  static List<Booking> allBookings = List.generate(5, (index) {
    return Booking(
      id: 'BK-00${index + 1}',
      userName: 'Khách hàng Huế ${index + 1}',
      userPhone: '0905 123 45$index',
      carPlate: '75A-${100 + index}.XX',
      stationName: stations[index % 10].name,
      date: '2024-01-15',
      time: '08:00',
      totalKwh: 20.0,
    );
  });
  static List<UserAccount> accounts = [
    UserAccount(username: "admin", password: "123", name: "Quản trị viên", phone: "000", dob: "01/01/1990", gender: "Nam", email: "admin@evhue.com"),
    UserAccount(username: "user", password: "123", name: "Trần Minh Tâm", phone: "0786231849", dob: "09/11/2004", gender: "Nam", email: "tranminhtamk46@gmail.com"),
  ];

  static List<EVCar> userCars = [
  EVCar(
    id: "1",
    name: "VinFast VF8",
    plate: "75A-123.45",
    owner: "Trần Minh Tâm",
    range: "400km",
    totalKm: 1250.5,
  ),
  EVCar(
    id: "2",
    name: "VinFast VF e34",
    plate: "43A-678.90",
    owner: "Trần Minh Tâm",
    range: "300km",
    totalKm: 980.2,
  ),
  EVCar(
    id: "3",
    name: "Tesla Model 3",
    plate: "30F-456.78",
    owner: "Trần Minh Tâm",
    range: "500km",
    totalKm: 2100.0,
  ),
  EVCar(
    id: "4",
    name: "Hyundai Kona Electric",
    plate: "51G-234.56",
    owner: "Trần Minh Tâm",
    range: "415km",
    totalKm: 1650.7,
  ),
  EVCar(
    id: "5",
    name: "Kia EV6",
    plate: "92C-345.67",
    owner: "Trần Minh Tâm",
    range: "528km",
    totalKm: 890.4,
  ),
  EVCar(
    id: "6",
    name: "BMW iX3",
    plate: "88A-789.01",
    owner: "Trần Minh Tâm",
    range: "460km",
    totalKm: 1345.9,
  ),
];

}
class UserAccount {
  String username, password, name, phone, dob, gender, email;
  UserAccount({
    required this.username, required this.password, required this.name, 
    required this.phone, required this.dob, required this.gender, required this.email
  });
}

class EVCar {
  String id, name, plate, owner, range;
  double totalKm;
  EVCar({required this.id, required this.name, required this.plate, required this.owner, required this.range, required this.totalKm});
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passController = TextEditingController();
  bool isLogin = true; // Chuyển đổi giữa Đăng nhập và Đăng ký

  void _handleAuth() {
    if (isLogin) {
      // Logic Đăng nhập
      try {
        final acc = AppData.accounts.firstWhere(
          (a) => a.username == userController.text && a.password == passController.text);
        
        if (acc.username == "admin") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserMainScreen()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu!")));
      }
    } else {
      // Logic Đăng ký đơn giản
      AppData.accounts.add(UserAccount(
        username: userController.text, password: passController.text,
        name: "Người dùng mới", phone: "Chưa cập nhật", dob: "01/01/2000", gender: "Nam", email: userController.text + "@gmail.com"
      ));
      setState(() => isLogin = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController confirmPassController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.teal, Colors.green])),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(30),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
  Icon(Icons.bolt, size: 60, color: Colors.teal.shade700),
  Text(
    isLogin ? "HUE EV LOGIN" : "ĐĂNG KÝ HỆ THỐNG",
    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  ),

  const SizedBox(height: 20),

  // Tên đăng nhập
  TextField(
    controller: userController,
    decoration: const InputDecoration(
      labelText: "Tên đăng nhập",
      prefixIcon: Icon(Icons.person),
    ),
  ),

  // Email (chỉ khi đăng ký)
  if (!isLogin)
    TextField(
      controller: emailController,
      decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
    ),

  // Số điện thoại (chỉ khi đăng ký)
  if (!isLogin)
    TextField(
      controller: phoneController,
      decoration: const InputDecoration(
        labelText: "Số điện thoại",
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
    ),

  // Mật khẩu
  TextField(
    controller: passController,
    decoration: const InputDecoration(
      labelText: "Mật khẩu",
      prefixIcon: Icon(Icons.lock),
    ),
    obscureText: true,
  ),

  // Xác nhận mật khẩu (chỉ khi đăng ký)
  if (!isLogin)
    TextField(
      controller: confirmPassController,
      decoration: const InputDecoration(
        labelText: "Xác nhận mật khẩu",
        prefixIcon: Icon(Icons.lock_outline),
      ),
      obscureText: true,
    ),

  const SizedBox(height: 25),

  // Nút đăng nhập / đăng ký
  ElevatedButton(
    onPressed: _handleAuth,
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
    ),
    child: Text(isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ"),
  ),

  // Chuyển đổi login / register
  TextButton(
    onPressed: () => setState(() => isLogin = !isLogin),
    child: Text(
      isLogin
          ? "Chưa có tài khoản? Đăng ký"
          : "Đã có tài khoản? Đăng nhập",
    ),
  ),
],

              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ADMIN DASHBOARD ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản trị Huế EV"),
          bottom: const TabBar(tabs: [Tab(text: "Trạm sạc"), Tab(text: "Đơn đặt"), Tab(text: "Thống kê"),]),
        ),
        body: TabBarView(
          children: [_buildStationTab(), _buildBookingTab(), const AdminStatisticsTab(), ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openStationEditor(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _openStationEditor(Station? s) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => StationDetailScreen(station: s)));
    setState(() {});
  }

  Widget _buildStationTab() {
    return ListView.builder(
      itemCount: AppData.stations.length,
      itemBuilder: (context, index) {
        final s = AppData.stations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: Icon(Icons.ev_station, color: s.isActive ? Colors.teal : Colors.grey),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Mã: ${s.code} | Cổng: ${s.activePorts}"),
            trailing: const Icon(Icons.edit),
            onTap: () => _openStationEditor(s),
          ),
        );
      },
    );
  }

  Widget _buildBookingTab() {
    return ListView.builder(
      itemCount: AppData.allBookings.length,
      itemBuilder: (context, index) {
        final b = AppData.allBookings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(b.userName),
            subtitle: Text("Trạm: ${b.stationName} - ${b.status}"),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showBookingDetails(b),
          ),
        );
      },
    );
  }

  void _showBookingDetails(Booking b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ĐƠN HÀNG: ${b.id}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
              Text("👤 Khách hàng: ${b.userName}"),

            Text("📞 Điện thoại: ${b.userPhone}"),

            Text("🚗 Biển số xe: ${b.carPlate}"),

            Text("📍 Địa điểm: ${b.stationName}"),

            Text("⏰ Thời gian: ${b.time} ngày ${b.date}"),

            Text("⚡ Lượng điện dự kiến: ${b.totalKwh} kWh"),
            if (b.cancelReason.isNotEmpty) Text("❌ Lý do hủy: ${b.cancelReason}", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            Row(
              children: [
                if (b.status != "Đã hủy")
                  Expanded(child: ElevatedButton(
                    onPressed: () => _showCancelDialog(b),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50),
                    child: const Text("Hủy đặt chỗ", style: TextStyle(color: Colors.red)))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(Booking b) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lý do hủy"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: "Nhập lý do hủy tại đây..."),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Quay lại")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                b.status = "Đã hủy";
                b.cancelReason = reasonController.text;
              });
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Đóng bottom sheet
            },
            child: const Text("Xác nhận hủy"),
          )
        ],
      ),
    );
  }
}

// --- STATION DETAIL/EDITOR SCREEN ---
class StationDetailScreen extends StatefulWidget {
  final Station? station; // Null nếu là thêm mới
  const StationDetailScreen({super.key, this.station});
  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  late TextEditingController nameCtrl, codeCtrl, addrCtrl, powerCtrl, priceCtrl, portCtrl;
  bool isActive = true;
  String type = "AC";

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.station?.name ?? "");
    codeCtrl = TextEditingController(text: widget.station?.code ?? "");
    addrCtrl = TextEditingController(text: widget.station?.address ?? "");
    powerCtrl = TextEditingController(text: widget.station?.power.toString() ?? "7.0");
    priceCtrl = TextEditingController(text: widget.station?.pricePerKwh.toString() ?? "6000");
    portCtrl = TextEditingController(text: widget.station?.activePorts.toString() ?? "6");
    isActive = widget.station?.isActive ?? true;
    type = widget.station?.chargingType ?? "AC";
  }

  void _saveStation() {
    final newStation = Station(
      id: widget.station?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: codeCtrl.text,
      name: nameCtrl.text,
      address: addrCtrl.text,
      power: double.tryParse(powerCtrl.text) ?? 7.0,
      chargingType: type,
      pricePerKwh: double.tryParse(priceCtrl.text) ?? 6000,
      activePorts: int.tryParse(portCtrl.text) ?? 6,
      isActive: isActive,
      // THÊM 2 DÒNG NÀY (Lấy tọa độ cũ hoặc mặc định):
    lat: widget.station?.lat ?? 16.46, 
    lng: widget.station?.lng ?? 107.59,
    );

    if (widget.station == null) {
      AppData.stations.add(newStation);
    } else {
      int index = AppData.stations.indexWhere((s) => s.id == widget.station!.id);
      AppData.stations[index] = newStation;
    }
    Navigator.pop(context);
  }

  void _deleteStation() {
    AppData.stations.removeWhere((s) => s.id == widget.station!.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station == null ? "Thêm trạm mới" : "Chỉnh sửa trạm"),
        actions: [
          if (widget.station != null)
            IconButton(onPressed: _deleteStation, icon: const Icon(Icons.delete, color: Colors.red))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên trạm")),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "Mã trạm")),
            TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: "Địa chỉ")),
            Row(
              children: [
                Expanded(child: TextField(controller: powerCtrl, decoration: const InputDecoration(labelText: "Công suất (kW)"), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Giá (VNĐ/kWh)"), keyboardType: TextInputType.number)),
              ],
            ),
            TextField(controller: portCtrl, decoration: const InputDecoration(labelText: "Số cổng sạc"), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: "Kiểu sạc"),
              items: ["AC", "DC"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => type = val!),
            ),
            SwitchListTile(
              title: const Text("Trạng thái hoạt động"),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveStation,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("LƯU THÔNG TIN"),
            )
          ],
        ),
      ),
    );
  }
}
// --- WIDGET THỐNG KÊ DOANH THU ---
class AdminStatisticsTab extends StatelessWidget {
  const AdminStatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Tính toán dữ liệu giả định từ danh sách booking
    double totalRevenue = AppData.allBookings
        .where((b) => b.status != "Đã hủy")
        .fold(0, (sum, item) => sum + (item.totalKwh * 7500)); // Giả định giá TB 7500đ

    int totalOrders = AppData.allBookings.length;
    int canceledOrders = AppData.allBookings.where((b) => b.status == "Đã hủy").length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TỔNG QUAN HỆ THỐNG", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          
          // Thẻ hiển thị tổng doanh thu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.teal, Colors.green]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tổng doanh thu (Dự tính)", style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 10),
                Text("${totalRevenue.toInt()} VNĐ", 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hàng hiển thị số lượng đơn
          Row(
            children: [
              _buildStatCard("Tổng đơn sạc", totalOrders.toString(), Colors.blue),
              const SizedBox(width: 10),
              _buildStatCard("Đơn đã hủy", canceledOrders.toString(), Colors.red),
            ],
          ),
          const SizedBox(height: 25),

          const Text("DOANH THU THEO TRẠM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Danh sách doanh thu từng trạm
          ...AppData.stations.map((s) {
            // Tính số đơn của trạm này
            int count = AppData.allBookings.where((b) => b.stationName == s.name).length;
            return ListTile(
              leading: const Icon(Icons.location_on, color: Colors.teal),
              title: Text(s.name),
              subtitle: Text("$count lượt sạc"),
              trailing: Text("${(count * s.pricePerKwh * 20).toInt()} đ", // Giả định mỗi lượt 20kWh
                style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}