// leads_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales/Screens/home.dart';
import 'package:sales/Screens/individual_details.dart';

class LeadList extends StatefulWidget {
  const LeadList({super.key});

  @override
  State<LeadList> createState() => _LeadListState();
}

class _LeadListState extends State<LeadList> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  String _searchQuery = '';
  String _selectedPlace = 'All';
  String _selectedStatus = 'All';
  String _selectedproductID = 'All';
  DateTimeRange? _selectedDateRange;

  List<String> _places = ['All'];
  List<String> _statuses = ['All'];
  List<String> _productIDs = ['All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    // Load unique places, statuses, and product numbers for filters
    try {
      final leadsSnapshot = await _firestore.collection('Leads').get();
      final ordersSnapshot = await _firestore.collection('Orders').get();

      Set<String> places = {'All'};
      Set<String> statuses = {'All'};
      Set<String> productIDs = {'All'};

      for (var doc in [...leadsSnapshot.docs, ...ordersSnapshot.docs]) {
        final data = doc.data();
        if (data['place'] != null) places.add(data['place'].toString());
        if (data['status'] != null) statuses.add(data['status'].toString());
        if (data['productID'] != null)
          productIDs.add(data['productID'].toString());
      }

      setState(() {
        _places = places.toList()..sort();
        _statuses = statuses.toList()..sort();
        _productIDs = productIDs.toList()..sort();
      });
    } catch (e) {
      print('Error loading filter options: $e');
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String formatDateShort(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(date);
  }

  bool _matchesFilters(Map<String, dynamic> data) {
    // Search query filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      final name = (data['name'] ?? '').toString().toLowerCase();
      final phone1 = (data['phone1'] ?? '').toString().toLowerCase();
      final phone2 = (data['phone2'] ?? '').toString().toLowerCase();
      final leadId = (data['leadId'] ?? '').toString().toLowerCase();
      final orderId = (data['orderId'] ?? '').toString().toLowerCase();

      if (!name.contains(searchLower) &&
          !phone1.contains(searchLower) &&
          !phone2.contains(searchLower) &&
          !leadId.contains(searchLower) &&
          !orderId.contains(searchLower)) {
        return false;
      }
    }

    // Place filter
    if (_selectedPlace != 'All' && data['place'] != _selectedPlace) {
      return false;
    }

    // Status filter
    if (_selectedStatus != 'All' && data['status'] != _selectedStatus) {
      return false;
    }

    // Product No filter
    if (_selectedproductID != 'All' &&
        data['productID'] != _selectedproductID) {
      return false;
    }

    // Date range filter
    if (_selectedDateRange != null && data['createdAt'] != null) {
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      if (createdAt.isBefore(_selectedDateRange!.start) ||
          createdAt.isAfter(
            _selectedDateRange!.end.add(const Duration(days: 1)),
          )) {
        return false;
      }
    }

    return true;
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, phone, or ID...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: _selectedPlace == 'All' ? 'Place' : _selectedPlace,
            onTap: () => _showPlaceFilter(),
            isActive: _selectedPlace != 'All',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedStatus == 'All' ? 'Status' : _selectedStatus,
            onTap: () => _showStatusFilter(),
            isActive: _selectedStatus != 'All',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedproductID == 'All' ? 'Product' : _selectedproductID,
            onTap: () => _showProductFilter(),
            isActive: _selectedproductID != 'All',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedDateRange == null ? 'Date Range' : 'Date Selected',
            onTap: () => _showDateRangeFilter(),
            isActive: _selectedDateRange != null,
          ),
          const SizedBox(width: 8),
          if (_hasActiveFilters())
            _buildFilterChip(
              label: 'Clear All',
              onTap: _clearAllFilters,
              isActive: false,
              isReset: true,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    bool isReset = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isReset
              ? Colors.red.shade50
              : isActive
              ? Colors.blue.shade700
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReset
                ? Colors.red.shade300
                : isActive
                ? Colors.blue.shade700
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isReset
                ? Colors.red.shade700
                : isActive
                ? Colors.white
                : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedPlace != 'All' ||
        _selectedStatus != 'All' ||
        _selectedproductID != 'All' ||
        _selectedDateRange != null;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedPlace = 'All';
      _selectedStatus = 'All';
      _selectedproductID = 'All';
      _selectedDateRange = null;
    });
  }

  void _showPlaceFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          _buildFilterModal('Place', _places, _selectedPlace, (value) {
            setState(() {
              _selectedPlace = value;
            });
          }),
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          _buildFilterModal('Status', _statuses, _selectedStatus, (value) {
            setState(() {
              _selectedStatus = value;
            });
          }),
    );
  }

  void _showProductFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterModal(
        'Product No',
        _productIDs,
        _selectedproductID,
        (value) {
          setState(() {
            _selectedproductID = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterModal(
    String title,
    List<String> options,
    String selected,
    Function(String) onSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select $title',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (option) => ListTile(
              title: Text(option),
              trailing: selected == option
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangeFilter() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildListTile(Map<String, dynamic> data, String type, String docId) {
    final isLead = type == 'Lead';
    final id = isLead ? data['leadId'] : data['orderId'];
    final status = data['status'] ?? 'N/A';
    final followUpDate = isLead ? data['followUpDate'] : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isLead
              ? Colors.blue.shade100
              : Colors.green.shade100,
          child: Icon(
            isLead ? Icons.person_add : Icons.shopping_cart,
            color: isLead ? Colors.blue.shade700 : Colors.green.shade700,
          ),
        ),
        title: Text(
          data['name'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (id != null) ...[
              const SizedBox(height: 4),
              Text(
                '${isLead ? 'Lead' : 'Order'} ID: $id',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  data['phone1'] ?? 'No Phone',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    data['place'] ?? 'N/A',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatDateShort(data['createdAt']),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
            if (followUpDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: Colors.orange.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Follow-up: ${formatDateShort(followUpDate)}',
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.to(() => DetailPage(data: data, type: type, docId: docId));
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'follow-up':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStreamBuilder(String collection, String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    type == 'Lead' ? Icons.person_add : Icons.shopping_cart,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${type}s Found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _matchesFilters(data);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildListTile(data, type, doc.id);
          },
        );
      },
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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Leads & Orders'),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Leads'),
              Tab(text: 'Orders'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: _buildStreamBuilder('Leads', 'Lead'),
                  ),
                  SingleChildScrollView(
                    child: _buildStreamBuilder('Orders', 'Order'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
