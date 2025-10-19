import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanikid12/pages/parent/parent_purchases_page.dart';
import 'package:scanikid12/pages/parent/parent_login.dart'; // ✅ import login page

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardScreenState();
}  
class _ParentDashboardScreenState extends State<ParentDashboard> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0; // bottom nav index

  // Pages for bottom nav
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ParentLoginPage()), // ✅ go to parent-login.dart
      );
    }
  }

  /// DELETE ACCOUNT CONFIRMATION
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "This will permanently delete your account and all associated data. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                // Delete Firestore user data
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(_currentUser!.uid)
                    .delete();

                // Delete Firebase Auth user
                await _currentUser.delete();

                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ParentLoginPage()), // ✅ go to parent-login.dart
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting account: $e")),
                  );
                }
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// HOME PAGE CONTENT (your old dashboard body without top buttons)
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
          const SizedBox(height: 40), 
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Student"),
          
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white, // for icon and text color
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
             _showdialogbox();
            },
          ),
          const SizedBox(height: 24),
          _buildStudentsContent(),
        ],
      ),
    );
  }
void _showdialogbox(
    ) {
      showDialog(
        context: context,
        builder: (context) {
          final nameController = TextEditingController();
          final rollNoController = TextEditingController();
          final limitController = TextEditingController();
          // Capture context-dependent objects before async gaps.
          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          return AlertDialog(
            title: const Text("Add New Student"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Student Name"),
                ),
                TextField(
                  controller: rollNoController,
                  decoration:
                      const InputDecoration(labelText: "Roll Number"),
                ),
                TextField(
                  controller: limitController,
                  decoration:const 
                  InputDecoration(labelText: "daily Limit"),
                  keyboardType: TextInputType.number,
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
                        .collection('users')
                        .doc(_currentUser!.uid)
                        .collection('students')
                        .add({
                      'name': nameController.text,
                      'rollNo': rollNoController.text,
                      'limit': int.tryParse(limitController.text) ?? 0,
                      'createdAt': FieldValue.serverTimestamp(),
                      'qrData': jsonEncode({
                        'parentId': _currentUser .uid,
                        'isblocked':false,
                        'blockeduntil':null,
                        // 'studentId' will be added after doc creation
                      }),
                    }).then((docRef) async {
                      // Update the qrData with the actual student document ID
                      await docRef.update({
                        'qrData': jsonEncode({
                          'parentId': _currentUser.uid,
                          'studentDocId': docRef.id,
                        }),
                      });
                    });

                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                          content:
                              Text("Student added successfully")),
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
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

  /// STUDENTS CONTENT (your existing student list with QR + edit + delete)
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
            final studentLimit =studentData['limit']??0;

            final qrData =
                studentData['qrData'] as String? ??
                jsonEncode({
                  'parentId': _currentUser.uid,
                  'studentDocId': studentDoc.id,
                });

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(studentName),
                subtitle: Text("ID: $studentRollNo\nLimit:$studentLimit"),
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
                            studentDoc.id, studentName, studentRollNo,studentLimit);
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

  /// CONFIRM DELETE STUDENT
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
                  .collection('users')
                  .doc(_currentUser!.uid)
                  .collection('students')
                  .doc(studentId)
                  .delete();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Student deleted successfully")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// EDIT STUDENT
  void _showEditStudentDialog(
      String studentId, String currentName, String currentRollNo,int currentLimit) {
    final nameController = TextEditingController(text: currentName);
    final rollNoController = TextEditingController(text: currentRollNo);
    final limitController = TextEditingController(text:(currentLimit).toString());
    // Capture context-dependent objects before async gaps.
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
            TextField(
              controller:limitController,
              decoration: const InputDecoration(labelText: "daily limit"),
            )
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
                    .collection('users')
                    .doc(_currentUser!.uid)
                    .collection('students')
                    .doc(studentId)
                    .update({
                  'name': nameController.text,
                  'rollNo': rollNoController.text,
                  'limit':int.tryParse(limitController.text)??currentLimit,
                });
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                      content: Text("Student updated successfully")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentUser.email ?? "Parent",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.deepPurple),
              title: const Text("Video Explanation"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VideoExplanationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blue),
              title: const Text("Sign Out"),
              onTap: _signOut,
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Delete Account"),
              onTap: _confirmDeleteAccount,
            ),
          ],
        ),
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

/// ABOUT US PAGE
class QRCodeScreen extends StatefulWidget {
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
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  Future<Uint8List> _generateQrImage() async {
    final qrPainter = QrPainter(
      data: widget.qrData,
      version: QrVersions.auto,
      gapless: true,
      color: Colors.black,
      emptyColor: Colors.white,
    );

    final picData = await qrPainter.toImageData(1024, format: ui.ImageByteFormat.png);
    if (picData == null) throw Exception("Failed to generate QR image");
    return Uint8List.view(picData.buffer);
  }

  Future<void> _saveQrToGallery() async {
    try {
      final bytes = await _generateQrImage();
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: "scanikid_qr_${widget.studentRollNo}",
        quality: 100,
      );

      if ((result['isSuccess'] ?? false) == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR saved to Gallery ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save QR ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving QR: $e")),
      );
    }
  }

  Future<void> _shareQr() async {
    try {
      final bytes = await _generateQrImage();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/scanikid_qr_${widget.studentRollNo}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: "Here is the QR code for ${widget.studentName}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing QR: $e")),
      );
    }
  }

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
              'QR Code for ${widget.studentName} (ID: ${widget.studentRollNo})',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: widget.qrData,
              version: QrVersions.auto,
              size: qrSize,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveQrToGallery,
                  icon: const Icon(Icons.download),
                  label: const Text("Save"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _shareQr,
                  icon: const Icon(Icons.share),
                  label: const Text("Share"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
/// VIDEO EXPLANATION PAGE
class VideoExplanationPage extends StatelessWidget {
  const VideoExplanationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Explanation")),
      body: const Center(
        child: Text(
          "This is where we will add video explanations or tutorials in the future.",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}