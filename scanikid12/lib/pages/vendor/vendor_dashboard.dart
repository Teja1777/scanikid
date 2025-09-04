import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camera_handle.dart';
import 'package:scanikid12/pages/vendor/vendor_sales_page.dart';
import 'package:scanikid12/pages/vendor/vendor_login.dart'; // <-- import login page

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboard> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;
  String? _scannedParentId;
  String? _scannedStudentDocId;
  String? _scannedStudentName;
  String? _scannedStudentRollNo;

  bool _isProcessingScan = false;
  final List<PurchaseItem> _purchaseItems = [];
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  double _totalAmount = 0.0;
  bool _isSendingReceipt = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  late final List<Widget> _pages = [
    _buildHomePage(),
    const VendorSalesPage(),
    _buildNotificationsPage(),
    _buildProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  /// ---------------- QR SCANNER ----------------
  Future<void> _startScanner() async {
    _resetScan();
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
    if (scannedValue == null || scannedValue.isEmpty) return;

    setState(() => _isProcessingScan = true);
    try {
      final Map<String, dynamic> qrData = jsonDecode(scannedValue);
      final parentId = qrData['parentId'] as String?;
      final studentDocId = qrData['studentDocId'] as String?;

      if (parentId == null || studentDocId == null) {
        throw Exception('Invalid QR code format.');
      }

      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .collection('students')
          .doc(studentDocId)
          .get();

      if (!studentDoc.exists) throw Exception('Student not found.');

      final studentData = studentDoc.data()!;
      setState(() {
        _scannedParentId = parentId;
        _scannedStudentDocId = studentDocId;
        _scannedStudentName = studentData['name'];
        _scannedStudentRollNo = studentData['rollNo'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Scan failed: $e')));
      _resetScan();
    } finally {
      setState(() => _isProcessingScan = false);
    }
  }

  void _resetScan() {
    setState(() {
      _scannedParentId = null;
      _scannedStudentDocId = null;
      _scannedStudentName = null;
      _scannedStudentRollNo = null;
      _purchaseItems.clear();
      _totalAmount = 0.0;
      _itemNameController.clear();
      _itemPriceController.clear();
      _isSendingReceipt = false;
    });
  }

  /// ---------------- HOME PAGE ----------------
  Widget _buildHomePage() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardShortcuts(screenWidth),
            const SizedBox(height: 24),
            _scannedStudentName != null
                ? _buildReceiptCreationUI()
                : _buildScannerPlaceholder(),
          ],
        ),
      ),
    );
  }

  /// Dashboard quick actions grid
  Widget _buildDashboardShortcuts(double screenWidth) {
    final shortcuts = [
      {'icon': Icons.today, 'label': 'Today', 'page': const VendorSalesPage()},
      {'icon': Icons.list, 'label': 'All Transactions', 'page': const VendorSalesPage()},
      {'icon': Icons.block, 'label': 'Block List', 'page': PlaceholderPage(title: 'Block List')},
      {'icon': Icons.bar_chart, 'label': 'Reports', 'page': PlaceholderPage(title: 'Reports')},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth < 600 ? 2 : 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: screenWidth < 600 ? 1 : 1.2,
      ),
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item['page'] as Widget),
          ),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData,
                    size: screenWidth * 0.1 > 50 ? 50 : screenWidth * 0.1,
                    color: Colors.deepPurple),
                const SizedBox(height: 8),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04 > 18 ? 18 : screenWidth * 0.04),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerPlaceholder() {
    return const Center(
      child: Text(
        " ",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// ---------------- OTHER PAGES ----------------
  Widget _buildNotificationsPage() {
    return const Center(child: Text("No new notifications."));
  }

  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.deepPurple,
            child: Text(
              _currentUser?.displayName?.isNotEmpty == true
                  ? _currentUser!.displayName![0].toUpperCase()
                  : 'V',
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(_currentUser?.displayName ?? "Vendor",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Vendor Account"),
        ],
      ),
    );
  }

  /// ---------------- UI BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Dashboard"),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_currentUser?.displayName ?? "Vendor"),
              accountEmail: Text(_currentUser?.email ?? "No Email"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.store, color: Colors.deepPurple),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About Us"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaceholderPage(title: "About Us")),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: () async {
                // Show spinner
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pop(context); // close spinner
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const VendorLoginPage()),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Delete Account"),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Account"),
                    content: const Text("Are you sure you want to permanently delete this account? This action cannot be undone."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                  );
                  try {
                    await _currentUser?.delete();
                    if (mounted) {
                      Navigator.pop(context); // close spinner
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const VendorLoginPage()),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context); // close spinner
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting account: $e")),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _startScanner,
        backgroundColor: Colors.deepPurple,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "Transactions"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  /// ---------------- RECEIPT CREATION ----------------
  Widget _buildReceiptCreationUI() {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(_scannedStudentName ?? 'N/A'),
        subtitle: Text("ID: ${_scannedStudentRollNo ?? 'N/A'}"),
      ),
    );
  }
}

/// ---------------- SUPPORT CLASSES ----------------
class PurchaseItem {
  final String name;
  final double price;
  PurchaseItem({required this.name, required this.price});
  Map<String, dynamic> toMap() => {'name': name, 'price': price};
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.deepPurple),
      body: Center(child: Text("$title Page")),
    );
  }
}