import 'package:flutter/material.dart';
import 'camera_handle.dart'; // We will create this screen next

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboard> {

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['QR Scanner', 'My Sales'];


  String? _scannedStudentId; 


  Future<void> _startScanner() async {

    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    
    if (scannedValue != null) {
      setState(() {
        _scannedStudentId = scannedValue;
      });
      
      _showScanResultDialog(scannedValue);
    }
  }

  
  String? get scannedStudentId => _scannedStudentId;

  
  void _showScanResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scan Successful"),
        content: Text("Student ID: $result"),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 100,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              'ScanKid',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        actions: [
          const CircleAvatar(
            backgroundColor: Color(0xFF6366F1),
            child: Text('V', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          const Center(
            child: Text(
              'vendor',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: const Text('vendor'),
            labelStyle: const TextStyle(fontSize: 12),
            backgroundColor: Colors.grey[200],
            padding: EdgeInsets.zero,
            side: BorderSide.none,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black54),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ## Header Section ##
              const Text(
                'Vendor Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan student QR codes and create purchase requests',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // ## Tab Selection Section ##
              Row(
                children: List.generate(_tabs.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildTabButton(index),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // ## Content Area ##
              // This will show content based on the selected tab
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build the content for the currently selected tab
  Widget _buildTabContent() {
    // We only have UI for the first tab in this example
    if (_selectedTabIndex == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Scan Student QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text('Start QR Scanner'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
          
              },
              child: const Text('Enter Student ID Manually'),
            ),
          ],
        ),
      );
    }
    // Placeholder for the "My Sales" tab
    return const Center(
      child: Text(
        'Sales information will be displayed here.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // Helper to build the tab buttons
  Widget _buildTabButton(int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _tabs[index],
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
