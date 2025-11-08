import 'package:caravelle/dashboard_naves/zoomorder_screen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [
    {
      'image': 'assets/images/cara4.png',
      'title': 'Gold Necklace',
      'description': '24k gold necklace, 50g',
      'status': 'Delivered',
      'price': '\$2,499.00',
      'orderNumber': '#ORD-7842',
    },
    {
      'image': 'assets/images/cara3.png',
      'title': 'Diamond Ring',
      'description': '1ct diamond ring, platinum band',
      'status': 'Processing',
      'price': '\$3,299.00',
      'orderNumber': '#ORD-7843',
    },
    {
      'image': 'assets/images/cara2.png',
      'title': 'Pearl Earrings',
      'description': 'South sea pearls, 14k gold',
      'status': 'Shipped',
      'price': '\$1,899.00',
      'orderNumber': '#ORD-7844',
    },
    {
      'image': 'assets/images/cara4.png',
      'title': 'Gold Necklace',
      'description': '24k gold necklace, 50g',
      'status': 'Delivered',
      'price': '\$2,499.00',
      'orderNumber': '#ORD-7842',
    },
    {
      'image': 'assets/images/cara9.png',
      'title': 'Silver Bracelet',
      'description': 'Sterling silver, handmade',
      'status': 'New Orders',
      'price': '\$899.00',
      'orderNumber': '#ORD-7845',
    },
    {
      'image': 'assets/images/cara8.png',
      'title': 'Ruby Pendant',
      'description': 'Natural ruby, 18k gold chain',
      'status': 'Accepted',
      'price': '\$1,599.00',
      'orderNumber': '#ORD-7846',
    },
    {
      'image': 'assets/images/cara3.png',
      'title': 'Emerald Ring',
      'description': 'Colombian emerald, white gold',
      'status': 'Declined',
      'price': '\$2,199.00',
      'orderNumber': '#ORD-7847',
    },
    {
      'image': 'assets/images/cara4.png',
      'title': 'Sapphire Earrings',
      'description': 'Blue sapphire, diamond accents',
      'status': 'Customer Cancel',
      'price': '\$1,799.00',
      'orderNumber': '#ORD-7848',
    },
  ];

  List<Map<String, dynamic>> filteredOrders = [];
  TextEditingController searchController = TextEditingController();
  
  // Status filter variables
  List<String> statusFilters = [
    'All',
    'New Orders',
    'Accepted', 
    'In Process',
    'Completed',
    'Delivered',
    'Declined',
    'Customer Cancel'
  ];
  
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    filteredOrders = orders;
  }

  void filterOrders(String query) {
    final filtered = orders.where((order) {
      final titleLower = order['title']!.toLowerCase();
      final descLower = order['description']!.toLowerCase();
      final statusLower = order['status']!.toLowerCase();
      final searchLower = query.toLowerCase();
      
      // Check if order matches both status filter and search query
      final matchesStatus = selectedStatus == 'All' || order['status'] == selectedStatus;
      final matchesSearch = titleLower.contains(searchLower) || 
                           descLower.contains(searchLower) || 
                           statusLower.contains(searchLower);
      
      return matchesStatus && matchesSearch;
    }).toList();

    setState(() {
      filteredOrders = filtered;
    });
  }

  void filterByStatus(String status) {
    setState(() {
      selectedStatus = status;
    });
    
    final filtered = orders.where((order) {
      final matchesStatus = status == 'All' || order['status'] == status;
      
      // Also apply search filter if any
      final searchQuery = searchController.text.toLowerCase();
      if (searchQuery.isNotEmpty) {
        final titleLower = order['title']!.toLowerCase();
        final descLower = order['description']!.toLowerCase();
        final statusLower = order['status']!.toLowerCase();
        
        final matchesSearch = titleLower.contains(searchQuery) || 
                             descLower.contains(searchQuery) || 
                             statusLower.contains(searchQuery);
        
        return matchesStatus && matchesSearch;
      }
      
      return matchesStatus;
    }).toList();

    setState(() {
      filteredOrders = filtered;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
      case 'Completed':
        return Colors.green;
      case 'Shipped':
      case 'In Process':
        return Colors.blue;
      case 'Processing':
      case 'Accepted':
        return Colors.orange;
      case 'New Orders':
        return Colors.purple;
      case 'Declined':
        return Colors.red;
      case 'Customer Cancel':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // Search Bar
           

            // Status Filter Scroller
            Container(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: statusFilters.length,
                itemBuilder: (context, index) {
                  final status = statusFilters[index];
                  final isSelected = selectedStatus == status;
                  
                  return GestureDetector(
                    onTap: () => filterByStatus(status),
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                          width: 1,
                        ),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),


             TextField(
              controller: searchController,
              onChanged: filterOrders,
              style: TextStyle(color: Colors.black87, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 1)
                )
              ),
            ),

            SizedBox(height: 16.h),

            // Orders Count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Orders (${filteredOrders.length})',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (selectedStatus != 'All')
                    GestureDetector(
                      onTap: () => filterByStatus('All'),
                      child: Text(
                        'Clear Filter',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No orders found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            selectedStatus == 'All'
                                ? 'Try adjusting your search'
                                : 'No $selectedStatus orders',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final statusColor = _getStatusColor(order['status'] ?? 'Processing');

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ZoomOrderScreen(
                                  order: {
                                    'image': order['image'] ?? 'assets/images/default.png',
                                    'title': order['title'] ?? '',
                                    'description': order['description'] ?? '',
                                    'status': order['status'] ?? '',
                                    'price': order['price'] ?? '',
                                    'orderNumber': order['orderNumber'] ?? '',
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Image with fallback
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.asset(
                                    order['image'] ?? 'assets/images/cara9.png',
                                    width: 80.w,
                                    height: 80.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order['title'] ?? '',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        order['description'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            child: Text(
                                              order['status'] ?? '',
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            order['price'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        order['orderNumber'] ?? '',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}