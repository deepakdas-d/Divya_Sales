// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class OrderManagmenet extends StatefulWidget {
//   @override
//   _OrderManagmenetState createState() => _OrderManagmenetState();
// }

// class _OrderManagmenetState extends State<OrderManagmenet> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Form controllers
//   final TextEditingController _userIdController = TextEditingController(
//     text: 'PS01',
//   );
//   final TextEditingController _nameController = TextEditingController(
//     text: 'James',
//   );
//   final TextEditingController _addressController = TextEditingController(
//     text: 'Amester Dam',
//   );
//   final TextEditingController _phoneController = TextEditingController(
//     text: '8606053052',
//   );
//   final TextEditingController _productNoController = TextEditingController(
//     text: 'P2',
//   );
//   final TextEditingController _nosController = TextEditingController(text: '1');
//   final TextEditingController _remarkController = TextEditingController(
//     text: 'Please Make sure it reach before 20/7/2025',
//   );

//   String _selectedStatus = 'HOT';
//   String? _selectedMaker;
//   int _availability = 2;

//   List<Map<String, dynamic>> _makers = [];
//   bool _isLoadingMakers = true;

//   final List<String> _statusOptions = [
//     'HOT',
//     'PENDING',
//     'PROCESSING',
//     'COMPLETED',
//     'CANCELLED',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchMakers();
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _nameController.dispose();
//     _addressController.dispose();
//     _phoneController.dispose();
//     _productNoController.dispose();
//     _nosController.dispose();
//     _remarkController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchMakers() async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('users')
//           .where('role', isEqualTo: 'maker')
//           .get();

//       setState(() {
//         _makers = querySnapshot.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>? ?? {};
//           return {
//             'id': doc.id,
//             'name': data['name'] ?? 'Unknown',
//             'email': data['email'] ?? '',
//           };
//         }).toList();

//         if (_makers.isNotEmpty) {
//           _selectedMaker = _makers[0]['id'];
//         }
//         _isLoadingMakers = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoadingMakers = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error fetching makers: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _submitOrder() async {
//     if (_formKey.currentState!.validate() && _selectedMaker != null) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Row(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(width: 20),
//                 Text('Submitting order...'),
//               ],
//             ),
//           );
//         },
//       );

//       try {
//         final orderData = {
//           'userId': _userIdController.text.trim(),
//           'name': _nameController.text.trim(),
//           'address': _addressController.text.trim(),
//           'phoneNumber': _phoneController.text.trim(),
//           'nos': int.tryParse(_nosController.text.trim()) ?? 1,
//           'status': _selectedStatus,
//           'remark': _remarkController.text.trim(),
//           'makerId': _selectedMaker,
//           'availability': _availability,
//           'createdAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         };

//         final docRef = await _firestore.collection('orders').add(orderData);

//         Navigator.of(context).pop();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Order submitted successfully! Order ID: ${docRef.id}',
//             ),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//           ),
//         );

//         _clearForm();
//       } catch (e) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error submitting order: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please fill all required fields and select a maker'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }

//   void _clearForm() {
//     _userIdController.clear();
//     _nameController.clear();
//     _addressController.clear();
//     _phoneController.clear();
//     _productNoController.clear();
//     _nosController.text = '1';
//     _remarkController.clear();
//     setState(() {
//       _selectedStatus = 'HOT';
//       _availability = 1;
//       if (_makers.isNotEmpty) {
//         _selectedMaker = _makers[0]['id'];
//       }
//     });
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         validator: validator,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, color: Color(0xFF2E3192)),
//           filled: true,
//           fillColor: Color(0xFFF5F5F5),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Color(0xFF2E3192), width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.red),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.red, width: 2),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required void Function(String?) onChanged,
//     required IconData icon,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, color: Color(0xFF2E3192)),
//           filled: true,
//           fillColor: Color(0xFFF5F5F5),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Color(0xFF2E3192), width: 2),
//           ),
//         ),
//         items: items.map((String item) {
//           return DropdownMenuItem<String>(value: item, child: Text(item));
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildMakerDropdown() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: _isLoadingMakers
//           ? Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.person, color: Color(0xFF2E3192)),
//                   SizedBox(width: 12),
//                   Text('Loading makers...'),
//                   Spacer(),
//                   SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                 ],
//               ),
//             )
//           : DropdownButtonFormField<String>(
//               value: _selectedMaker,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedMaker = newValue;
//                 });
//               },
//               validator: (value) => value == null || value.isEmpty
//                   ? 'Please select a maker'
//                   : null,
//               decoration: InputDecoration(
//                 labelText: 'Select Maker',
//                 prefixIcon: Icon(Icons.person, color: Color(0xFF2E3192)),
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Color(0xFF2E3192), width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.red),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.red, width: 2),
//                 ),
//               ),
//               items: _makers.map((maker) {
//                 return DropdownMenuItem<String>(
//                   value: maker['id'],
//                   child: Text('${maker['name']} (${maker['email']})'),
//                 );
//               }).toList(),
//             ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF2E3192),
//       appBar: AppBar(
//         backgroundColor: Color(0xFF2E3192),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Order Management',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         margin: EdgeInsets.only(top: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//         ),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildTextField(
//                   label: 'User ID',
//                   controller: _userIdController,
//                   icon: Icons.badge,
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Please enter User ID' : null,
//                 ),
//                 _buildTextField(
//                   label: 'Name',
//                   controller: _nameController,
//                   icon: Icons.person,
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Please enter name' : null,
//                 ),
//                 _buildTextField(
//                   label: 'Address',
//                   controller: _addressController,
//                   icon: Icons.location_on,
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Please enter address' : null,
//                 ),
//                 _buildTextField(
//                   label: 'Phone Number',
//                   controller: _phoneController,
//                   icon: Icons.phone,
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'Please enter phone number';
//                     if (value.length < 10)
//                       return 'Please enter a valid phone number';
//                     return null;
//                   },
//                 ),
//                 FutureBuilder<QuerySnapshot>(
//                   future: _firestore.collection('products').get(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Container(
//                         margin: EdgeInsets.only(bottom: 16),
//                         padding: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFF5F5F5),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Row(
//                           children: [
//                             CircularProgressIndicator(strokeWidth: 2),
//                             SizedBox(width: 16),
//                             Text('Loading products...'),
//                           ],
//                         ),
//                       );
//                     }
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Container(
//                         margin: EdgeInsets.only(bottom: 16),
//                         padding: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFF5F5F5),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Text('No products found.'),
//                       );
//                     }
//                     final products = snapshot.data!.docs;
//                     final selectedProduct = products.firstWhere(
//                       (doc) => doc.id == _productNoController.text,
//                       orElse: () => products
//                           .first, // Default to first document, no cast needed
//                     );
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         DropdownButtonFormField<String>(
//                           value: _productNoController.text.isNotEmpty
//                               ? _productNoController.text
//                               : products.first.id,
//                           onChanged: (String? newValue) {
//                             setState(() {
//                               _productNoController.text = newValue!;
//                             });
//                           },
//                           decoration: InputDecoration(
//                             labelText: 'Select Product',
//                             prefixIcon: Icon(
//                               Icons.inventory,
//                               color: Color(0xFF2E3192),
//                             ),
//                             filled: true,
//                             fillColor: Color(0xFFF5F5F5),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Color(0xFF2E3192),
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                           items: products.map((doc) {
//                             final data =
//                                 doc.data() as Map<String, dynamic>? ?? {};
//                             return DropdownMenuItem<String>(
//                               value: doc.id,
//                               child: Text(data['name'] ?? doc.id),
//                             );
//                           }).toList(),
//                           validator: (value) => value?.isEmpty ?? true
//                               ? 'Please select a product'
//                               : null,
//                         ),
//                         SizedBox(height: 16),
//                         Builder(
//                           builder: (context) {
//                             final data =
//                                 selectedProduct.data()
//                                     as Map<String, dynamic>? ??
//                                 {};
//                             return Container(
//                               padding: EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Color(0xFFF5F5F5),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(color: Colors.grey.shade300),
//                               ),
//                               child: Row(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(8),
//                                     child:
//                                         data['imageUrl'] != null &&
//                                             data['imageUrl']
//                                                 .toString()
//                                                 .isNotEmpty
//                                         ? Image.network(
//                                             data['imageUrl'],
//                                             width: 60,
//                                             height: 60,
//                                             fit: BoxFit.cover,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) =>
//                                                     Icon(
//                                                       Icons.broken_image,
//                                                       size: 60,
//                                                       color: Colors.orange,
//                                                     ),
//                                           )
//                                         : Container(
//                                             width: 60,
//                                             height: 60,
//                                             color: Colors.orange,
//                                             child: Icon(
//                                               Icons.image,
//                                               color: Colors.white,
//                                               size: 30,
//                                             ),
//                                           ),
//                                   ),
//                                   SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           data['name'] ?? 'No Name',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         SizedBox(height: 4),
//                                         Text(
//                                           'ID: ${selectedProduct.id}',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey[700],
//                                           ),
//                                         ),
//                                         SizedBox(height: 4),
//                                         Text(
//                                           'Price: ₹${data['price']?.toString() ?? 'N/A'}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.green[700],
//                                           ),
//                                         ),
//                                         SizedBox(height: 4),
//                                         Text(
//                                           'Stock: ${data['stock']?.toString() ?? 'N/A'}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.blueGrey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(bottom: 16),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFF5F5F5),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           Icons.local_drink,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Availability',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   if (_availability > 1) {
//                                     setState(() => _availability--);
//                                   }
//                                 },
//                                 icon: Icon(Icons.remove_circle_outline),
//                                 color: Color(0xFF2E3192),
//                               ),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: Colors.grey.shade300,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   _availability.toString(),
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() => _availability++);
//                                 },
//                                 icon: Icon(Icons.add_circle_outline),
//                                 color: Color(0xFF2E3192),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 _buildTextField(
//                   label: 'NOS',
//                   controller: _nosController,
//                   icon: Icons.numbers,
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'Please enter NOS';
//                     final num = int.tryParse(value);
//                     if (num == null || num <= 0)
//                       return 'Please enter a valid number';
//                     return null;
//                   },
//                 ),
//                 _buildDropdown(
//                   label: 'Status',
//                   value: _selectedStatus,
//                   items: _statusOptions,
//                   onChanged: (String? newValue) =>
//                       setState(() => _selectedStatus = newValue!),
//                   icon: Icons.flag,
//                 ),
//                 _buildMakerDropdown(),
//                 Container(
//                   margin: EdgeInsets.only(bottom: 24),
//                   child: TextFormField(
//                     controller: _remarkController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       labelText: 'Remark',
//                       prefixIcon: Icon(Icons.message, color: Color(0xFF2E3192)),
//                       filled: true,
//                       fillColor: Color(0xFFF5F5F5),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(
//                           color: Color(0xFF2E3192),
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _submitOrder,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF2E3192),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: Text(
//                       'Submit',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class OrderManagmenet extends StatefulWidget {
  const OrderManagmenet({super.key});

  @override
  State<OrderManagmenet> createState() => _OrderManagmenetState();
}

class _OrderManagmenetState extends State<OrderManagmenet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Management'),
        backgroundColor: Color(0xFF2E3192),
      ),
      body: Center(
        child: Text(
          'Order Management Screen',
          style: TextStyle(fontSize: 24, color: Color(0xFF2E3192)),
        ),
      ),
     );
  }
}
