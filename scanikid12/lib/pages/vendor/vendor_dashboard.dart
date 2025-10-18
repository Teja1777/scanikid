import 'dart:convert';
import 'package:flutter/material.dart';
import 'camera_handle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanikid12/pages/vendor/vendor_sales_page.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboard> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String? _scannedParentId;
  String? _scannedStudentDocId;
  String? _scannedStudentName;
  String? _scannedStudentRollNo;
  int?    _scannedStudentLimit;
  bool _isProcessingScan = false;

  final List<PurchaseItem> _purchaseItems = [];
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  double _totalAmount = 0.0;
  bool _isSendingReceipt = false;

  int _selectedIndex = 0;

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  Future<void> _startScanner() async {
    _resetScan();

    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (scannedValue == null || scannedValue.isEmpty) return;

    setState(() {
      _isProcessingScan = true;
    });

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

      if (!studentDoc.exists) {
        throw Exception('Student not found in the database.');
      }

      final studentData = studentDoc.data()!;
      setState(() {
        _scannedParentId = parentId;
        _scannedStudentDocId = studentDocId;
        _scannedStudentName = studentData['name'] as String?;
        _scannedStudentRollNo = studentData['rollNo'] as String?;
        _scannedStudentLimit = studentData['limit'] is int
            ? studentData['limit'] as int
            : 0;
// Robust parsing for 'limit' field
// Fetch student's unpaid purchases
Future<void>checkunpaid()async{
final unpaidPurchases = await FirebaseFirestore.instance
    .collection('purchases')
    .where('studentDocId', isEqualTo: studentDocId)
    .where('status', isEqualTo: 'unpaid')
    .get();

bool shouldBlock = false;

for (var doc in unpaidPurchases.docs) {
  final createdAt = doc['createdAt'] as Timestamp?;
  if (createdAt != null) {
    final difference = DateTime.now().difference(createdAt.toDate()).inDays;
    if (difference > 7) {
      shouldBlock = true;

      // Update Firestore to mark this purchase as blocked
       doc.reference.update({'isBlocked': true});
    }
  }
}

// Update UI flag for vendor
if (shouldBlock) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("❌ Student is blocked due to unpaid bills over 7 days!"),
      backgroundColor: Colors.red,
    ),
  );
}

        final rawLimit = studentData['limit'];
if (rawLimit is int) {
  _scannedStudentLimit = rawLimit;
} else if (rawLimit is String) {
  _scannedStudentLimit = int.tryParse(rawLimit);
} else if (rawLimit is double) {
  _scannedStudentLimit = rawLimit.toInt();
} else {
  _scannedStudentLimit = 0;
}
    }});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: ${e.toString()}')),
      );
      _resetScan();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingScan = false;
        });
      }
    }
  }

  void _addItem() {
  final name = _itemNameController.text;
  final price = double.tryParse(_itemPriceController.text);

  if (name.isNotEmpty && price != null && price > 0) {
    final limit = (_scannedStudentLimit ?? 0).toDouble();

    if (_totalAmount + price > limit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Limit exceeded! Cannot add this item.\nDaily Limit: ₹$limit",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // Don’t add item
    }

    setState(() {
      _purchaseItems.add(PurchaseItem(name: name, price: price));
      _totalAmount += price;
    });
    _itemNameController.clear();
    _itemPriceController.clear();
    FocusScope.of(context).unfocus();
  }
}

  Future<void> _sendReceipt() async {
    if (_purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item.')),
      );
      return;
    }

    setState(() {
      _isSendingReceipt = true;
    });

    try {
      final purchaseData = {
        'vendorId': _currentUser!.uid,
        'vendorName': _currentUser.displayName ?? 'N/A',
        'parentId': _scannedParentId,
        'studentDocId': _scannedStudentDocId,
        'studentName': _scannedStudentName,
        'studentRollNo': _scannedStudentRollNo,
        'items': _purchaseItems.map((item) => item.toMap()).toList(),
        'totalAmount': _totalAmount,
        'status': 'unpaid',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('purchases').add(purchaseData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt sent successfully!')),
      );

      _resetScan();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send receipt: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingReceipt = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leadingWidth: 100,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              'ScaniKid',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: const Color(0xFF6366F1),
            child: Text(
              _currentUser?.displayName?.isNotEmpty == true
                  ? _currentUser!.displayName![0].toUpperCase()
                  : 'V',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentUser?.displayName ?? 'Vendor',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Vendor Account',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              )
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black54),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Floating QR Scanner Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        shape: const CircleBorder(),
        onPressed: _startScanner,
        child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
// Replace your current BottomAppBar + BottomNavigationBar section with this:

bottomNavigationBar: BottomAppBar(
  shape: const CircularNotchedRectangle(),
  notchMargin: 8.0,
  child: SizedBox(
    height: 65, // fixed height for all screens
    child: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black54,
      iconSize: 26, // consistent icon sizing
      selectedFontSize: 13, // smaller font to avoid overflow
      unselectedFontSize: 12,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendorSalesPage()),
          );
        } else if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendorDashboard()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Placeholder()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Placeholder()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale_outlined),
          label: "My Sales",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    ),
  ),
),
      // Body remains same
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vendor Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              const SizedBox(height: 24),

              _buildNavigationControls(),
              const SizedBox(height: 32),

              _buildScannerContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Column(
      children: [
        _buildNavigationButton(
          label: 'Block list',
          icon: Icons.person_outline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Placeholder()),
            );
            // Implement navigation to Block list    
          },
        ),           
      ],
    );
  }
  Widget _buildScannerContent() {
    if (_isProcessingScan) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_scannedStudentName != null) {
      return _buildReceiptCreationUI();
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
    );
  }
  Widget _buildReceiptCreationUI() {
    return Column(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF6366F1)),
                  title: Text(
                    _scannedStudentName ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${_scannedStudentRollNo ?? 'N/A'}'),
                ),
                ListTile(
                  leading: const Icon(Icons.money, color: Color(0xFF6366F1)),
                  title: Text(
                    'Daily Limit: ₹${_scannedStudentLimit ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _itemPriceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1)),
              onPressed: _addItem,
              iconSize: 36,
            ),
          ],
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _purchaseItems.length,
          itemBuilder: (context, index) {
            final item = _purchaseItems[index];
            return ListTile(
              title: Text(item.name),
              trailing: Text('₹${item.price.toStringAsFixed(2)}'),
            );
          },
        ),
        const Divider(),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Remaining Limit:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Builder(
        builder: (_) {
          final remaining = (_scannedStudentLimit ?? 0) - _totalAmount;
          return Text(
            '₹${remaining.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: remaining >= 0 ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    ],
  ),
),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetScan,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
           Expanded(
  child: ElevatedButton(
    onPressed: (_isSendingReceipt ||
                ((_scannedStudentLimit ?? 0) - _totalAmount) < 0)
        ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("❌ Cannot send receipt. Limit exceeded!"),
                backgroundColor: Colors.red,
              ),
            );
          }
        : _sendReceipt,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6366F1),
    ),
    child: _isSendingReceipt
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Text('Send Receipt'),
  ),
),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(99, 102, 241, 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PurchaseItem {
  final String name;
  final double price;
  PurchaseItem({required this.name, required this.price});
  Map<String, dynamic> toMap() => {'name': name, 'price': price};
}