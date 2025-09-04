import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:scanikid12/pages/parent/parent_purchases_page.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboard> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0; // bottom nav index
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      const ParentPurchasesPage(),
      _buildNotificationsPage(),
      _buildProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// HOME PAGE CONTENT
  Widget _buildHomePage() {
    return SingleChildScrollView(
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
          ElevatedButton.icon(
            onPressed: _showAddStudentDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Student"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStudentsContent(),
        ],
      ),
    );
  }

  /// NOTIFICATIONS PAGE
  Widget _buildNotificationsPage() {
    return const Center(
      child: Text(
        "No new notifications.",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  /// PROFILE PAGE
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
                  : "P",
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser?.displayName ?? "Parent",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Parent Account", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text("Sign Out"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  /// ADD STUDENT DIALOG
  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final rollNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Student Name"),
            ),
            TextField(
              controller: rollNoController,
              decoration: const InputDecoration(labelText: "Roll Number"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  rollNoController.text.isNotEmpty) {
                final newStudent = {
                  "name": nameController.text,
                  "rollNo": rollNoController.text,
                  "createdAt": FieldValue.serverTimestamp(),
                };
                final ref = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(_currentUser!.uid)
                    .collection("students")
                    .add(newStudent);

                final qrData = jsonEncode({
                  "parentId": _currentUser!.uid,
                  "studentDocId": ref.id,
                });
                await ref.update({"qrData": qrData});
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Student added successfully")),
                  );
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  /// EDIT STUDENT DIALOG
  void _showEditStudentDialog(
      String studentId, String currentName, String currentRollNo) {
    final nameController = TextEditingController(text: currentName);
    final rollNoController = TextEditingController(text: currentRollNo);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Student Name"),
            ),
            TextField(
              controller: rollNoController,
              decoration: const InputDecoration(labelText: "Roll Number"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  rollNoController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(_currentUser!.uid)
                    .collection("students")
                    .doc(studentId)
                    .update({
                  "name": nameController.text,
                  "rollNo": rollNoController.text,
                });
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Student updated successfully")),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// DELETE CONFIRMATION
  void _confirmDeleteStudent(String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete $studentName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(_currentUser!.uid)
                  .collection("students")
                  .doc(studentId)
                  .delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Student deleted")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// STUDENTS CONTENT
  Widget _buildStudentsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('students')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'No students added yet. Click "+ Add Student" to begin.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        final studentDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: studentDocs.length,
          itemBuilder: (context, index) {
            final studentDoc = studentDocs[index];
            final studentData = studentDoc.data() as Map<String, dynamic>;
            final studentName = studentData['name'] ?? 'No Name';
            final studentRollNo = studentData['rollNo'] ?? 'No ID';

            final qrData = studentData['qrData'] as String? ??
                jsonEncode({
                  'parentId': _currentUser!.uid,
                  'studentDocId': studentDoc.id,
                });

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(studentName),
                subtitle: Text("ID: $studentRollNo"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.qr_code, color: Colors.deepPurple),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeScreen(
                              qrData: qrData,
                              studentName: studentName,
                              studentRollNo: studentRollNo,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditStudentDialog(
                            studentDoc.id, studentName, studentRollNo);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDeleteStudent(studentDoc.id, studentName);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Error: User not found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ScaniKid"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Purchases"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/// QR CODE SCREEN
class QRCodeScreen extends StatelessWidget {
  final String qrData;
  final String studentName;
  final String studentRollNo;
  const QRCodeScreen({
    super.key,
    required this.qrData,
    required this.studentName,
    required this.studentRollNo,
  });

  @override
  Widget build(BuildContext context) {
    final qrSize = MediaQuery.of(context).size.width * 0.6;
    return Scaffold(
      appBar: AppBar(title: const Text('Student QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'QR Code for $studentName (ID: $studentRollNo)',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            QrImageView(data: qrData, version: QrVersions.auto, size: qrSize),
          ],
        ),
      ),
    );
  }
}