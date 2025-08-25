import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardScreenState();
}

// Dummy QRCodeScreen widget for demonstration
class QRCodeScreen extends StatelessWidget {
  final Map<String, String> studentDetails;

  const QRCodeScreen({super.key, required this.studentDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'QR Code for ${studentDetails['name']} (ID: ${studentDetails['id']})',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: jsonEncode(studentDetails),
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentDashboardScreenState extends State<ParentDashboard> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Students', 'Purchases', 'Notifications'];
  final List<Map<String, String>> _students =
      []; // List to hold student details

  // Controllers for the text fields in the dialog
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  // Function to show the "Add New Student" dialog
  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _studentNameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'Roll Number/ID'),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                // Clear the text fields when the dialog is cancelled
                _studentNameController.clear();
                _studentIdController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('Add Student'),
              onPressed: () {
                if (_studentNameController.text.isNotEmpty &&
                    _studentIdController.text.isNotEmpty) {
                  final newStudent = {
                    'name': _studentNameController.text,
                    'id': _studentIdController.text,
                  };
                  setState(() {
                    _students.add(newStudent);
                  });
                  Navigator.of(context).pop();
                  // Clear the text fields after adding the student
                  _studentNameController.clear();
                  _studentIdController.clear();
                  // For now, navigate to a placeholder QR code screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QRCodeScreen(studentDetails: newStudent),
                    ),
                  );
                } else {
                  // Optionally show an error message if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter student name and roll number.',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
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
            backgroundColor: Colors.deepPurple,
            child: Text('P', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          const Center(
            child: Text(
              'parent', 
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: const Text('parent'),
            labelStyle: const TextStyle(fontSize: 12),
            backgroundColor: Colors.grey.shade200,
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parent Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your children and their purchases',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              children: List.generate(_tabs.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: _buildTabButton(index),
                );
              }),
            ),
            const SizedBox(height: 30),
            // This widget will now build the content based on the selected tab
            _buildSelectedTabContent(),
          ],
        ),
      ),
    );
  }

  /// Builds the content widget based on the currently selected tab index.
  Widget _buildSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildStudentsContent();
      case 1:
        return _buildPurchasesContent();
      case 2:
        return _buildNotificationsContent();
      default:
        return _buildStudentsContent(); // Fallback to the first tab
    }
  }

  /// Placeholder widget for the "Purchases" tab.
  Widget _buildPurchasesContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Purchases Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your children\'s purchase history will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder widget for the "Notifications" tab.
  Widget _buildNotificationsContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No New Notifications',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Important updates and alerts will be shown here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the UI for the "Students" tab, including the list and add button.
  Widget _buildStudentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Students',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddStudentDialog(context);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Display the list of added students
        if (_students.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students.elementAt(index);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('ID: ${student['id']!}'),
                      // Placeholder for the QR code
                      const SizedBox(height: 16),
                      Center(
                        child: QrImageView(
                          data: jsonEncode(student),
                          version: QrVersions.auto,
                          size: 100.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        else
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'No students added yet. Click "+ Add Student" to begin.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

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
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _tabs.elementAt(index),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
