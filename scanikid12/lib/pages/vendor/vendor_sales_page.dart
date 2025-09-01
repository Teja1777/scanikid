import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class VendorSalesPage extends StatefulWidget {
  const VendorSalesPage({super.key});

  @override
  State<VendorSalesPage> createState() => _VendorSalesPageState();
}

class _VendorSalesPageState extends State<VendorSalesPage> {
  User? _currentUser;
  Stream<QuerySnapshot>? _salesStream;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _salesStream = FirebaseFirestore.instance
          .collection('purchases')
          .where('vendorId', isEqualTo: _currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sales'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _buildSalesContent(),
    );
  }

  Widget _buildSalesContent() {
    if (_currentUser == null) {
      return const Center(child: Text('You must be logged in to see sales.'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _salesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firestore Error: ${snapshot.error}");
          String errorMessage = 'An error occurred while fetching sales.';

          if (snapshot.error.toString().contains('FAILED_PRECONDITION')) {
            errorMessage =
                'Database setup required. Please check the debug console for a link to create the necessary Firestore index.';
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Could Not Load Sales',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 45.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.point_of_sale, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Sales Yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your sales history will appear here after you send a receipt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final salesDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: salesDocs.length,
          itemBuilder: (context, index) {
            final doc = salesDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isPaid = data['status'] == 'paid';
            final items = (data['items'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp != null
                ? DateFormat('d MMM yyyy, h:mm a').format(timestamp.toDate())
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ExpansionTile(
                title: Text('Student: ${data['studentName'] ?? 'N/A'} (ID: ${data['studentRollNo'] ?? 'N/A'})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                subtitle: Text(date),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${(data['totalAmount'] as num).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Chip(
                      label: Text(isPaid ? 'Paid' : 'Pending'),
                      backgroundColor: isPaid
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      labelStyle: TextStyle(
                        color: isPaid
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                        horizontal: 0.0,
                        vertical: -4,
                      ),
                    ),
                  ],
                ),
                children: [
                  const Divider(height: 1),
                  ...items.map(
                    (item) => ListTile(
                      dense: true,
                      title: Text(item['name']),
                      trailing: Text(
                        '₹${(item['price'] as num).toStringAsFixed(2)}',
                      ),
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
}
