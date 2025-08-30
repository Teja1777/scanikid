import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardScreenState();
}

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
            QrImageView(data: qrData, version: QrVersions.auto, size: 200.0),
          ],
        ),
      ),
    );
  }
}

class _ParentDashboardScreenState extends State<ParentDashboard> {
  int _selectedTabIndex = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final List<String> _tabs = ['Students', 'Purchases', 'Notifications'];
 
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  Stream<QuerySnapshot>? _purchasesStream;
  Stream<QuerySnapshot>? _unpaidPurchasesStream;

  void _initializeStreamsIfNeeded() {
   
    _purchasesStream ??= FirebaseFirestore.instance
        .collection('purchases')
        .where('parentId', isEqualTo: _currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
    _unpaidPurchasesStream ??= FirebaseFirestore.instance
        .collection('purchases')
        .where('parentId', isEqualTo: _currentUser!.uid)
        .where('status', isEqualTo: 'unpaid')
        .snapshots();
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isAdding = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Student'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _studentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                    ),
                  ),
                  TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Roll Number/ID',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _studentNameController.clear();
                    _studentIdController.clear();
                  },
                ),
                ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          final studentName = _studentNameController.text;
                          final studentRollNo = _studentIdController.text;

                          if (studentName.isEmpty || studentRollNo.isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter student name and roll number.',
                                ),
                              ),
                            );
                            return;
                          }

                          final scaffoldMessenger = ScaffoldMessenger.of(
                            this.context,
                          );

                          setState(() {
                            isAdding = true;
                          });

                          try {
                            final newStudentData = {
                              'name': studentName,
                              'rollNo': studentRollNo,
                              'createdAt': FieldValue.serverTimestamp(),
                            };

                            final studentDocRef = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(_currentUser!.uid)
                                .collection('students')
                                .add(newStudentData);

                            final qrData = jsonEncode({
                              'parentId': _currentUser!.uid,
                              'studentDocId': studentDocRef.id,
                            });

                            await studentDocRef.update({'qrData': qrData});

                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            _studentNameController.clear();
                            _studentIdController.clear();

                            Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (context) => QRCodeScreen(
                                  qrData: qrData,
                                  studentName: studentName,
                                  studentRollNo: studentRollNo,
                                ),
                              ),
                            );
                          } on FirebaseException catch (e) {
                            // This will catch specific Firebase errors, like permission denied.
                            debugPrint("Firebase Error: ${e.message} (Code: ${e.code})");
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: ${e.message ?? "A Firebase error occurred."}',
                                  ),
                                ),
                              );
                              setState(() {
                                isAdding = false;
                              });
                            }
                          } catch (e) {
                            // This will catch any other unexpected errors.
                            debugPrint("Unexpected Error: $e");
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'An unexpected error occurred. Please try again.',
                                  ),
                                ),
                              );
                              setState(() {
                                isAdding = false;
                              });
                            }
                          }
                        },
                  child: isAdding
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add Student'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Error: User not found.')),
      );
    }
    // Initialize streams here, where we are sure _currentUser is not null.
    // This will only run once because of the null check inside the method.
    _initializeStreamsIfNeeded();

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
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text(
              _currentUser.displayName?.isNotEmpty == true
                  ? _currentUser.displayName![0].toUpperCase()
                  : 'P',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Center(
            child: Text(
              _currentUser.displayName ?? 'Parent',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: const Text('parent'),
            labelStyle: const TextStyle(fontSize: 12),
            backgroundColor: Colors.grey[200],
            padding: EdgeInsets.zero,
            side: BorderSide.none,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black54),
            onPressed: _signOut,
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
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StreamBuilder<QuerySnapshot>(
                stream: _unpaidPurchasesStream,
                builder: (context, snapshot) {
                  final unpaidCount =
                      snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Row(
                    children: List.generate(_tabs.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 1.0),
                        child: _buildTabButton(index,
                            notificationCount: index == 1 ? unpaidCount : 0),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            _buildSelectedTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildStudentsContent();
      case 1:
        return _buildPurchasesContent();
      case 2:
        return _buildNotificationsContent();
      default:
        return _buildStudentsContent();
    }
  }

  Widget _buildPurchasesContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _purchasesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        final purchaseDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: purchaseDocs.length,
          itemBuilder: (context, index) {
            final doc = purchaseDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isPaid = data['status'] == 'paid';
            final items =
                (data['items'] as List<dynamic>).cast<Map<String, dynamic>>();
            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp != null
                ? DateFormat('d MMM yyyy, h:mm a').format(timestamp.toDate())
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                title: Text(
                  'Vendor: ${data['vendorName'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Student: ${data['studentName'] ?? 'N/A'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${(data['totalAmount'] as num).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                children: [
                  const Divider(height: 1),
                  ...items.map((item) => ListTile(
                        title: Text(item['name']),
                        trailing:
                            Text('₹${(item['price'] as num).toStringAsFixed(2)}'),
                      )),
                  if (!isPaid)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement payment logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text('Pay Now',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
                _showAddStudentDialog();
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

        StreamBuilder<QuerySnapshot>(
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
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong.'));
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

                final qrData =
                    studentData['qrData'] as String? ??
                    jsonEncode({
                      'parentId': _currentUser!.uid,
                      'studentDocId': studentDoc.id,
                    });

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('ID: $studentRollNo'),
                        const SizedBox(height: 16),
                        Center(child: QrImageView(data: qrData, size: 100.0)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, {int notificationCount = 0}) {
    bool isSelected = _selectedTabIndex == index;

    Widget tabContent = Container(
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
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: (notificationCount > 0)
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                tabContent,
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : tabContent,
    );
  }
}
