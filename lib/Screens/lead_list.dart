import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales/Screens/home.dart';

class LeadList extends StatefulWidget {
  const LeadList({super.key});

  @override
  State<LeadList> createState() => _LeadListState();
}

class _LeadListState extends State<LeadList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Widget buildCard(Map<String, dynamic> data, String type) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (type == 'Lead' && data['leadId'] != null)
              Text(
                "Lead ID: ${data['leadId']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (type == 'Order' && data['orderId'] != null)
              Text(
                "Order ID: ${data['orderId']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            Text(
              data['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("Status: ${data['status'] ?? 'N/A'}"),
            Text("Phone 1: ${data['phone1'] ?? 'N/A'}"),
            if (data['phone2'] != null && data['phone2'].toString().isNotEmpty)
              Text("Phone 2: ${data['phone2']}"),
            Text("Address: ${data['address'] ?? 'N/A'}"),
            Text("Place: ${data['place'] ?? 'N/A'}"),
            Text("Product ID: ${data['productID'] ?? 'N/A'}"),
            Text("No. of items: ${data['nos'] ?? 'N/A'}"),
            Text("Remark: ${data['remark'] ?? 'N/A'}"),
            Text("Created At: ${formatDate(data['createdAt'])}"),
            if (type == 'Lead')
              Text("Follow-Up: ${formatDate(data['followUpDate'])}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => Home());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leads & Orders'),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Leads',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Leads')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No Leads Found'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                      return buildCard(data, 'Lead');
                    },
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Orders')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No Orders Found'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                      return buildCard(data, 'Order');
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
