import 'package:flutter/material.dart';
import 'main.dart'; // Để sử dụng AppData và các Model từ file chính
import 'dart:math' show cos, sqrt, asin;

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});
  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  String currentView = "Tìm trạm";
  
  // Dữ liệu giả định cho User
  Map<String, String> userProfile = {"name": "Trần Minh Tâm", "phone": "0786231849", "pass": "123"};
  List<String> userCars = [
  "VinFast VF8 - 75A-123.45",
  "VinFast VF e34 - 43A-678.90",
  "Tesla Model 3 - 30F-456.78",
  "Hyundai Kona Electric - 51G-234.56",
  "Kia EV6 - 92C-345.67",
  "BMW iX3 - 88A-789.01",
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentView),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      // --- THANH BÊN (DRAWER) ---
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userProfile["name"]!),
              accountEmail: Text(userProfile["phone"]!),
              currentAccountPicture: CircleAvatar(
    backgroundImage: AssetImage('anh/anhnguoi.jpg'), // Đổi từ Icon sang AssetImage
  ),
              decoration: const BoxDecoration(color: Colors.teal),
            ),
            _drawerItem(Icons.map, "Tìm trạm"),
            _drawerItem(Icons.history, "Đơn đặt chỗ"),
            _drawerItem(Icons.electric_car, "Quản lý xe điện"),
            _drawerItem(Icons.person, "Hồ sơ cá nhân"),
            _drawerItem(Icons.route, "Lộ trình"),
            _drawerItem(Icons.bar_chart, "Thống kê cá nhân"),
            const Divider(),
            _drawerItem(Icons.logout, "Đăng xuất", color: Colors.red),
            
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.teal),
      title: Text(title, style: TextStyle(color: color)),
      onTap: () {
       if (title == "Đăng xuất") {
  Navigator.pushAndRemoveUntil(
    context, 
    MaterialPageRoute(builder: (_) => const LoginPage()), 
    (route) => false
  );
  return;
}
        setState(() => currentView = title);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    switch (currentView) {
      case "Tìm trạm": return _buildStationSearch();
      case "Đơn đặt chỗ": return _buildBookingHistory();
      case "Quản lý xe điện": return _buildCarManager();
      case "Hồ sơ cá nhân": return _buildProfile();
      case "Lộ trình": return _buildRoutePlanner();
      case "Thống kê cá nhân": return _buildPersonalStatistics();
      default: return const Center(child: Text("Đang phát triển"));
    }
  }
  double maxDistance = 5.0; // Mặc định tìm trong bán kính 5km
  // Giả định vị trí hiện tại của người dùng (ở Vincom Huế)
  double userLat = 16.4637;
  double userLng = 107.5905;
  // --- CHỨC NĂNG TÌM TRẠM & ĐẶT CHỖ ---
  Widget _buildStationSearch() {
    // Lọc danh sách trạm dựa trên khoảng cách
  List<Station> filteredStations = AppData.stations.where((s) {
    double dist = calculateDistance(userLat, userLng, s.lat, s.lng);
    return dist <= maxDistance;
  }).toList();

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.teal.shade50,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text("Vị trí của bạn: TP. Huế", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("Bán kính: ${maxDistance.toInt()} km"),
                Expanded(
                  child: Slider(
                    value: maxDistance,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: "${maxDistance.toInt()} km",
                    onChanged: (val) => setState(() => maxDistance = val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: filteredStations.length,
          itemBuilder: (context, i) {
            final s = filteredStations[i];
            double distance = calculateDistance(userLat, userLng, s.lat, s.lng);
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Text("${distance.toStringAsFixed(1)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Cách đây ${distance.toStringAsFixed(1)} km \nGiá: ${s.pricePerKwh.toInt()} đ/kWh"),
                isThreeLine: true,
                trailing: ElevatedButton(
                  onPressed: () => _showBookingDialog(s),
                  child: const Text("Đặt"),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
  }

  void _showBookingDialog(Station s) {
    String selectedSlot = "Cổng 1 (AC)";
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // Sử dụng StatefulBuilder để update giao diện trong Dialog
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Đặt chỗ: ${s.name}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("1. Chọn cổng sạc:", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedSlot,
                  items: ["Cổng 1 (AC)", "Cổng 2 (AC)", "Cổng 3 (DC)"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setDialogState(() => selectedSlot = val!),
                ),
                
                const SizedBox(height: 15),
                const Text("2. Chọn thời gian:", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2026));
                        if (d != null) setDialogState(() => selectedDate = d);
                      },
                      child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: selectedTime);
                        if (t != null) setDialogState(() => selectedTime = t);
                      },
                      child: Text(selectedTime.format(context)),
                    ),
                  ],
                ),

                const Divider(),
                const Text("3. Thanh toán quét mã QR:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Gọi ảnh từ thư mục anh/ cùng cấp với lib
                        Image.asset(
                          'anh/anhqr.jpg',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        const Text("Quét để thanh toán (ATM/Ví)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () {
                // 1. Tạo một đối tượng Booking mới
    final newBooking = Booking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      userName: userProfile["name"]!,
      userPhone: userProfile["phone"]!,
      carPlate: userCars.isNotEmpty ? userCars[0] : "Chưa có xe",
      stationName: s.name,
      date: "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
      time: "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
      totalKwh: 15.0, // Giả định lượng điện sạc
      status: "Hoàn thành", // Cho vào lịch sử luôn sau khi thanh toán
    );

    // 2. Thêm vào danh sách tổng của hệ thống
    setState(() {
      AppData.allBookings.insert(0, newBooking); // Thêm lên đầu danh sách
    });

    // 3. Thông báo và đóng Dialog
    Navigator.pop(ctx);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🚀 Thanh toán thành công! Đã lưu vào lịch sử sạc."),
        backgroundColor: Colors.green,
      ),
    );
              },
              child: const Text("Xác nhận đã chuyển khoản"),
            )
          ],
        ),
      ),
    );
  }

  // --- CÁC GIAO DIỆN KHÁC ---
  Widget _buildCarManager() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: AppData.userCars.length,
    itemBuilder: (context, index) {
      final car = AppData.userCars[index];
      return Card(
        child: ListTile(
          leading: const Icon(Icons.electric_car, color: Colors.teal),
          title: Text(car.name),
          subtitle: Text(car.plate),
          onTap: () => _showCarDetails(car), // Xem chi tiết
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() => AppData.userCars.removeAt(index)),
          ),
        ),
      );
    },
  );
}

void _showCarDetails(EVCar car) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("THÔNG TIN XE: ${car.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Text("👤 Chủ sở hữu: ${car.owner}"),
          Text("🔢 Biển số: ${car.plate}"),
          Text("🛤️ Số km đã đi: ${car.totalKm} km"),
          Text("🔋 Quãng đường tối đa: ${car.range}"),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))
        ],
      ),
    ),
  );
}

  Widget _buildProfile() {
  final user = AppData.accounts[1]; // Lấy acc của bạn Tâm
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
       CircleAvatar(
          radius: 60, // Bạn có thể tăng lên 60 cho đẹp
          backgroundColor: Colors.teal.shade100,
          backgroundImage: const AssetImage('anh/anhnguoi.jpg'), // Hiển thị ảnh anh1.png
        ),
        const SizedBox(height: 20),
        _profileField("Tên", user.name),
        _profileField("Số điện thoại", user.phone),
        _profileField("Ngày sinh", user.dob),
        _profileField("Giới tính", user.gender),
        _profileField("Email", user.email),
        const Divider(height: 40),
        const Text("ĐỔI MẬT KHẨU", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(decoration: const InputDecoration(labelText: "Mật khẩu mới"), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {}, child: const Text("LƯU THÔNG TIN"))
      ],
    ),
  );
}

Widget _profileField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(initialValue: value, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
  );
}

  Widget _buildBookingHistory() {
    // Lấy danh sách booking của User (giả định lấy từ AppData)
  List<Booking> userBookings = AppData.allBookings;

  return ListView.builder(
    itemCount: userBookings.length,
    itemBuilder: (context, i) {
      final b = userBookings[i];
      bool allowable = _canCancel(b); // Kiểm tra điều kiện 30 phút

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: ListTile(
          title: Text("Đơn hàng: ${b.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Trạm: ${b.stationName}"),
              Text("Thời gian: ${b.time} ngày ${b.date}"),
              Text("Trạng thái: ${b.status}", 
                style: TextStyle(color: b.status == "Đã hủy" ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          trailing: allowable 
            ? ElevatedButton(
                onPressed: () => _confirmCancel(b),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
                child: const Text("Hủy"),
              )
            : const Tooltip(
                message: "Không thể hủy trước giờ sạc 30 phút",
                child: Icon(Icons.help_outline, color: Colors.grey),
              ),
        ),
      );
    },
  );
}

// Hàm xác nhận hủy
void _confirmCancel(Booking b) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Xác nhận hủy"),
      content: const Text("Bạn có chắc chắn muốn hủy đơn đặt chỗ này không? (Lưu ý: Chỉ được hủy trước 30 phút)"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Quay lại")),
        ElevatedButton(
          onPressed: () {
            setState(() {
              b.status = "Đã hủy";
              b.cancelReason = "Người dùng yêu cầu hủy";
            });
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã hủy đơn thành công")));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Xác nhận Hủy"),
        )
      ],
    ),
  );
  }
  double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295; // Math.PI / 180
  var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) *
          (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
  // --- GIAO DIỆN LỘ TRÌNH ---
  Widget _buildRoutePlanner() {
  final TextEditingController startCtrl = TextEditingController(text: "Huế");
  final TextEditingController endCtrl = TextEditingController(text: "Đà Nẵng");
  double distanceBetween = 105.0; // Giả định khoảng cách 105km

  // Tìm các trạm sạc "tiện đường" (giả lập logic)
  List<Station> routeStations = AppData.stations.take(3).toList(); 

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("LẬP KẾ HOẠCH HÀNH TRÌNH", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        
        // Form nhập điểm đi/đến
        Card(
  elevation: 0,
  color: Colors.grey.shade50,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        TextField(
          controller: startCtrl,
          decoration: const InputDecoration(
            labelText: "Điểm xuất phát",
            prefixIcon: Icon(Icons.my_location, color: Colors.blue),
            border: InputBorder.none,
          ),
        ),
        // Thay dấu 3 chấm bằng một đường kẻ ngang mờ
        const Divider(indent: 50, endIndent: 20, height: 1), 
        TextField(
          controller: endCtrl,
          decoration: const InputDecoration(
            labelText: "Điểm đến",
            prefixIcon: Icon(Icons.location_on, color: Colors.red),
            border: InputBorder.none,
          ),
        ),
      ],
    ),
  ),
),
        const SizedBox(height: 25),

        // Hiển thị bản đồ mô phỏng (Visual Route)
        const Text("CÁC TRẠM SẠC TRÊN HÀNH TRÌNH", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        // Vẽ lộ trình bằng nét đứt
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: routeStations.length,
          itemBuilder: (context, index) {
            final s = routeStations[index];
            return Row(
              children: [
                Column(
                  children: [
                    Container(width: 2, height: 30, color: Colors.teal.shade200),
                    const Icon(Icons.ev_station, color: Colors.teal),
                    Container(width: 2, height: 30, color: Colors.teal.shade200),
                  ],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: Text(s.name),
                      subtitle: Text("Cách lộ trình: 0.${index + 1} km"),
                      trailing: TextButton(
                        onPressed: () => _showBookingDialog(s),
                        child: const Text("Đặt trước"),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(child: Text("Hành trình dài $distanceBetween km. Bạn nên sạc tại ${routeStations[1].name} để đảm bảo pin.")),
            ],
          ),
        )
      ],
    ),
  );
}
// Hàm kiểm tra xem đơn hàng còn cho phép hủy không (trước 30 phút)
bool _canCancel(Booking b) {
  try {
    // Giả sử b.date là '2024-01-15' và b.time là '08:00'
    // Chúng ta tạo đối tượng DateTime từ thông tin booking
    DateTime bookingTime = DateTime.parse("${b.date} ${b.time}:00");
    DateTime now = DateTime.now();

    // Tính khoảng cách thời gian giữa hiện tại và lúc đặt chỗ
    Duration difference = bookingTime.difference(now);

    // Nếu thời gian còn lại lớn hơn 30 phút và trạng thái chưa bị hủy
    return difference.inMinutes > 30 && b.status != "Đã hủy";
  } catch (e) {
    return false; // Nếu lỗi định dạng thì không cho hủy để an toàn
  }
}
Widget _buildPersonalStatistics() {
  // Giả định dữ liệu thống kê từ danh sách booking của User
  // Lọc các đơn đã hoàn thành (không tính đơn đã hủy)
  final completedBookings = AppData.allBookings.where((b) => b.status == "Hoàn thành").toList();
  
  double totalMoney = 0;
  double totalKwh = 0;
  for (var b in completedBookings) {
    totalMoney += 50000; // Giả định mỗi lần sạc trung bình 50k
    totalKwh += 15.5;    // Giả định mỗi lần sạc 15.5 kWh
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TỔNG QUAN THÁNG NÀY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        
        // Thẻ tổng hợp
        Row(
  children: [
    Expanded(child: _statCard("Tổng chi", "11.560.500", Colors.orange, Icons.payments)),
    const SizedBox(width: 10),
    Expanded(child: _statCard("Năng lượng", "360 kW", Colors.green, Icons.bolt)),
  ],
),

        const SizedBox(height: 15),
        _statCard("Số lần sạc", "11 lần", Colors.blue, Icons.history),
        
        const SizedBox(height: 25),
        const Text("BIỂU ĐỒ TIÊU THỤ (kWh)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        // Vẽ biểu đồ cột đơn giản bằng các Container
        Container(
          height: 150,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar("T2", 40), _buildBar("T3", 70), _buildBar("T4", 30),
              _buildBar("T5", 90), _buildBar("T6", 50), _buildBar("T7", 100), _buildBar("CN", 20),
            ],
          ),
        ),

        const SizedBox(height: 25),
        const Text("GIAO DỊCH GẦN ĐÂY", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        // Danh sách các lần sạc đã thanh toán
        ...completedBookings.map((b) => Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(b.stationName),
            subtitle: Text("${b.date} - ${b.time}"),
            trailing: const Text("-50.000đ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ],
    ),
  );
}

// Widget thẻ thống kê nhỏ
Widget _statCard(String title, String value, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );
}


// Widget vẽ cột biểu đồ
Widget _buildBar(String day, double heightPercent) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        width: 15,
        height: heightPercent,
        decoration: BoxDecoration(color: Colors.teal.shade300, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(height: 5),
      Text(day, style: const TextStyle(fontSize: 10)),
    ],
  );
}
}