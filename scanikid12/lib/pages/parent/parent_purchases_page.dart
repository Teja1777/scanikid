import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ParentPurchasesPage extends StatefulWidget {
  const ParentPurchasesPage({super.key});

  @override
  State<ParentPurchasesPage> createState() => _ParentPurchasesPageState();
}

class _ParentPurchasesPageState extends State<ParentPurchasesPage> {
  User? _currentUser;
  Stream<QuerySnapshot>? _purchasesStream;
  String? _processingPaymentId;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _purchasesStream = FirebaseFirestore.instance
          .collection('purchases')
          .where('parentId', isEqualTo: _currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  @override
  void dispose() {
    debugPrint("--- ParentPurchasesPage dispose ---");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("--- ParentPurchasesPage build ---");
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _buildPurchasesContent(),
    );
  }

  Widget _buildPurchasesContent() {
    if (_currentUser == null) {
      return const Center(
        child: Text('You must be logged in to see purchases.'),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _purchasesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firestore Error: ${snapshot.error}");
          String errorMessage = 'An error occurred while fetching purchases.';

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
                    'Could Not Load Purchases',
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

        final purchaseDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: purchaseDocs.length,
          itemBuilder: (context, index) {
            final doc = purchaseDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isPaying = _processingPaymentId == doc.id;
            final isPaid = data['status'] == 'paid';
            final items = (data['items'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp != null
                ? DateFormat('d MMM yyyy, h:mm a').format(timestamp.toDate())
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: isPaid ? Colors.green.shade50 : null,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isPaid)
                      const Chip(
                        label: Text('Paid'),
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.zero,
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        visualDensity: VisualDensity(
                          horizontal: 0.0,
                          vertical: -4,
                        ),
                      )
                    else
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                children: [
                  const Divider(height: 1),
                  ...items.map(
                    (item) => ListTile(
                      title: Text(item['name']),
                      trailing: Text(
                        '₹${(item['price'] as num).toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  if (isPaid)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Payment Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!isPaid)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: isPaying
                            ? null
                            : () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Mock Payment'),
                                    content: const Text(
                                      'This will mark the purchase as paid. Proceed?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Pay'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;

                                setState(() {
                                  _processingPaymentId = doc.id;
                                });

                                try {
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );

                                  await FirebaseFirestore.instance
                                      .collection('purchases')
                                      .doc(doc.id)
                                      .update({'status': 'paid'});
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment failed: $e'),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _processingPaymentId = null;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: isPaying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Pay Now',
                                style: TextStyle(color: Colors.white),
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
