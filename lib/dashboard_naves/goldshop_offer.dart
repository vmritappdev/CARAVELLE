import 'dart:convert';


import 'package:caravelle/model/offerscreen.dart';
import 'package:caravelle/dashboard_naves/jewelery_screen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class GoldShopOffersScreen extends StatefulWidget {
  final String? mainCategory;
  final String? subCategory;
  final String subProducts;
  final String? product;
  final String? type;

  const GoldShopOffersScreen({
    Key? key,
    this.mainCategory,
    this.subCategory,
    required this.subProducts,
    this.product,
    this.type,
  }) : super(key: key);

  @override
  State<GoldShopOffersScreen> createState() => _GoldShopOffersScreenState();
}

class _GoldShopOffersScreenState extends State<GoldShopOffersScreen> {
  final TextEditingController _searchController = TextEditingController();
 
  String _sortBy = "Default";
  bool _sortAscending = true;

  bool isLoading = true;
  bool isLoadingMore = false;
  List<dynamic> totalData = [];

  List<Offer> offers = [];
  int currentPage = 1;
  bool hasMoreData = true;

  // Separate controllers for each layout
  final ScrollController _gridScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _fullScreenScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSubProductItems();
    _setupScrollControllers();
  }

  void _setupScrollControllers() {
    _gridScrollController.addListener(_onGridScroll);
    _fullScreenScrollController.addListener(_onFullScreenScroll);
  }

  void _onGridScroll() {
    if (_gridScrollController.position.pixels == _gridScrollController.position.maxScrollExtent && hasMoreData && !isLoadingMore) {
      _loadMoreData();
    }
  }

  void _onFullScreenScroll() {
    if (_fullScreenScrollController.position.pixels == _fullScreenScrollController.position.maxScrollExtent && hasMoreData && !isLoadingMore) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoadingMore) return;
    
    setState(() {
      isLoadingMore = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    // Add more dummy data
    final newOffers = [
      Offer(
        imagePath: 'assets/images/cara4.png',
        title: "Gold Necklace ${offers.length + 1}",
        originalPrice: "",
        discountedPrice: "",
        description: "Beautiful gold necklace",
        grossWeight: "10.5g",
        netWeight: "8.2g",
        size: "18 inches",
        tagNumber: "TAG-${offers.length + 1}",
        status: 'ACTIVE',
        subproduct: 'Necklace'
      ),
      Offer(
        imagePath: 'assets/images/cara2.png',
        title: "Gold Earrings ${offers.length + 2}",
        originalPrice: "",
        discountedPrice: "",
        description: "Elegant gold earrings",
        grossWeight: "5.2g",
        netWeight: "4.1g",
        size: "Small",
        tagNumber: "TAG-${offers.length + 2}",
        status: 'ACTIVE',
        subproduct: 'Earrings'
      ),
    ];

    setState(() {
      offers.addAll(newOffers);
      isLoadingMore = false;
      currentPage++;
      if (currentPage >= 3) {
        hasMoreData = false;
      }
    });
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    _horizontalScrollController.dispose();
    _fullScreenScrollController.dispose();
    super.dispose();
  }

  /// 🔹 Fetch Sub Product Items API Call
 Future<void> fetchSubProductItems() async {
  try {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${baseUrl}sub_product_items.php'),
      body: {
        'token': token,
        'sub_product': widget.subProducts,
        'product': widget.product ?? '',
        'type': widget.type ?? '',
      },
    );

    print('🔹 API URL: https://caravelle.in/barcode/app/sub_product_items.php');
    print('🔹 Sent Product: ${widget.product}');
    print('🔹 Sent SubProduct: ${widget.subProducts}');
    print('🔹 Sent Type: ${widget.type}');
    print('🔹 Status Code: ${response.statusCode}');

    // ✅ Pretty print full JSON with brackets & indentation
    try {
      final decoded = json.decode(response.body);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(decoded);
      print('✅ Full Response:\n$prettyJson');
    } catch (e) {
      print('⚠️ JSON Decode Error: $e');
      print('Raw Response: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response'] == 'success' && data['total_data'] != null) {
        final List<dynamic> list = data['total_data'];

        setState(() {
          offers = list.map((item) {
            return Offer(
              imagePath: (item['image_url'] != null && item['image_url'].isNotEmpty)
                  ? item['image_url']
                  : "",
              title: item['product']?.toString() ?? 'Unknown Product',
              // 🟡 Here we apply your product/subproduct logic
              originalPrice: item['design']?.toString() ?? '',
              discountedPrice: '',
              description: item['name']?.toString() ?? '',
              grossWeight: item['gross']?.toString() ?? '',
              netWeight: item['net']?.toString() ?? '',
              size: item['touch']?.toString() ?? '',
              tagNumber: item['barcode']?.toString() ?? '',
              status: item['status']?.toString() ?? '',
              subproduct: item['sub_product']?.toString() ?? '',
            );
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          offers = [];
          isLoading = false;
        });
        print('⚠️ No Data Found');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('❌ Server Error: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Exception: $e');
    setState(() {
      isLoading = false;
    });
  }
}


  // Layout types
  int _selectedLayout = 0;
  
  // For bottom sheet filter
  List<String> _selectedCategories = [];

  // Layout options data
  final List<LayoutOption> _layoutOptions = [
    LayoutOption(id: 0, title: "", subtitle: "", icon: Icons.grid_view_rounded, type: "grid"),
    LayoutOption(id: 1, title: "", subtitle: "", icon: Icons.view_carousel_rounded, type: "horizontal"),
    LayoutOption(id: 2, title: "", subtitle: "", icon: Icons.view_agenda_rounded, type: "list"),
  ];

void _navigateToDetailScreen(BuildContext context, Offer offer) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => JewelryDetailScreen(
        offer: offer,
        tagNumber: offer.tagNumber ?? '', // ✅ null అయితే empty string
      ),
    ),
  );
}


  double _parseWeight(String weight) {
    if (weight == null || weight.isEmpty) return 0.0;
    String cleanWeight = weight.replaceAll('g', '').trim();
    return double.tryParse(cleanWeight) ?? 0.0;
  }

 List<Offer> get _filteredOffers {
  List<Offer> filtered = List.from(offers);
  
  // ✅ Search filter - first 2 letters enter chesinappude work avutundi
  if (_searchController.text.isNotEmpty && _searchController.text.length >= 2) {
    final searchTerm = _searchController.text.toLowerCase();
    filtered = filtered.where((offer) => 
      offer.title.toLowerCase().contains(searchTerm) ||
      offer.description.toLowerCase().contains(searchTerm) ||
      (offer.subproduct?.toLowerCase().contains(searchTerm) ?? false)
    ).toList();
  }
  
  // Category filter
  if (_selectedCategories.isNotEmpty) {
    filtered = filtered.where((offer) {
      for (String category in _selectedCategories) {
        if (offer.title.toLowerCase().contains(category.toLowerCase()) ||
            (offer.subproduct?.toLowerCase().contains(category.toLowerCase()) ?? false)) {
          return true;
        }
      }
      return false;
    }).toList();
  }
  
  // Sort logic
  if (_sortBy == "Weight") {
    filtered.sort((a, b) {
      double weightA = _parseWeight(a.grossWeight ?? "0");
      double weightB = _parseWeight(b.grossWeight ?? "0");
      return _sortAscending ? weightA.compareTo(weightB) : weightB.compareTo(weightA);
    });
  } else if (_sortBy == "Newest" || _sortBy == "Oldest") {
    filtered.sort((a, b) {
      int indexA = offers.indexOf(a);
      int indexB = offers.indexOf(b);
      return _sortAscending ? indexA.compareTo(indexB) : indexB.compareTo(indexA);
    });
  }
  
  return filtered;
}
  void _showLayoutOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: 180.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Layout", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                      IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: Colors.grey, size: 20.sp), padding: EdgeInsets.zero, constraints: BoxConstraints()),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _layoutOptions.map((layout) => _buildCompactLayoutOption(layout)).toList()),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactLayoutOption(LayoutOption layout) {
    bool isSelected = _selectedLayout == layout.id;
    return GestureDetector(
      onTap: () {
        setState(() { _selectedLayout = layout.id; });
        Navigator.pop(context);
      },
      child: Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.amber.shade300 : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
          boxShadow: [
            if (isSelected) BoxShadow(color: Colors.amber.withOpacity(0.15), blurRadius: 8, offset: Offset(0, 2), spreadRadius: 1),
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Icon(layout.icon, color: isSelected ? Colors.amber.shade700 : Colors.grey.shade600, size: 24.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
   appBar: AppBar(
  automaticallyImplyLeading: false,
  centerTitle: false,
  backgroundColor: AppTheme.primaryColor,
  elevation: 0,
  shadowColor: AppTheme.primaryColor.withOpacity(0.3),

  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white, size: 22),
    onPressed: () => Navigator.pop(context),
  ),

  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        widget.subProducts.toUpperCase(),
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15.sp,
          letterSpacing: -0.5,
        ),
      ),
      SizedBox(width: 6.w),
      Text(
        "(${_filteredOffers.length}) items",
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),

  actions: [
    IconButton(
      icon: Icon(Icons.favorite_border, color: Colors.white, size: 20),
      onPressed: () {
        // TODO: Favourite Action
        print('❤️ Favourite clicked');
      },
    ),
    IconButton(
      icon: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
      onPressed: () {
        // TODO: Cart Action
        print('🛒 Cart clicked');
      },
    ),
  ],
),


      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar with Items Count
              Row(
                children: [
                 Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: TextField(
      controller: _searchController,
      onChanged: (value) {
        if (value.length >= 2) {
          setState(() {});
        } else if (value.isEmpty) {
          setState(() {});
        }
      },
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 8.w),
          child: Icon(
            Icons.search,
            color: AppTheme.primaryColor,
            size: 20.sp,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 32.w,
          minHeight: 32.h,
        ),
        hintText: "Search jewelry...",
        hintStyle: GoogleFonts.inter(
          color: Colors.grey.shade500,
          fontSize: 13.sp,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
      ),
    ),
  ),
),

                 
                ],
              ),
              SizedBox(height: 10.h),

              // Filter + Layout + Sort Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: SizedBox(
                  height: 50.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filter Button
                      GestureDetector(
                        onTap: () => _showFilterBottomSheet(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                          child: Row(children: [
                            Icon(Icons.filter_list, color: AppTheme.primaryColor, size: 16.sp), SizedBox(width: 4.w),
                            Text(_selectedCategories.isEmpty ? "Filter" : "Filter (${_selectedCategories.length})", style: GoogleFonts.inter(fontSize: 12)),
                          ]),
                        ),
                      ),

                      // Layout Button
                      GestureDetector(
                        onTap: () => _showLayoutOptionsSheet(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                          child: Row(children: [
                            Icon(Icons.grid_view_rounded, color: AppTheme.primaryColor, size: 16.sp), SizedBox(width: 6.w),
                            Text("Layout", style: GoogleFonts.inter(fontSize: 12, )),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor, size: 16.sp),
                          ]),
                        ),
                      ),

                      // Sort Button
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            if (value == "Weight Low to High") { _sortBy = "Weight"; _sortAscending = true; }
                            else if (value == "Weight High to Low") { _sortBy = "Weight"; _sortAscending = false; }
                            else if (value == "Newest First") { _sortBy = "Newest"; _sortAscending = false; }
                            else if (value == "Oldest First") { _sortBy = "Oldest"; _sortAscending = true; }
                            else { _sortBy = "Default"; }
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: "Weight Low to High", child: Text("Weight Low to High")),
                          PopupMenuItem(value: "Weight High to Low", child: Text("Weight High to Low")),
                          PopupMenuItem(value: "Newest First", child: Text("Newest First")),
                          PopupMenuItem(value: "Oldest First", child: Text("Oldest First")),
                        ],
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                          child: Row(children: [
                            Icon(Icons.sort, color: AppTheme.primaryColor, size: 16.sp), SizedBox(width: 4.w),
                            Text("Sort", style: GoogleFonts.inter(fontSize: 12)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Selected Filter Chips
              if (_selectedCategories.isNotEmpty) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  height: 40.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _selectedCategories.map((category) {
                      return Container(margin: EdgeInsets.only(right: 8.r), child: Chip(
                        label: Text(category, style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white)),
                        backgroundColor: AppTheme.primaryColor,
                        deleteIcon: Icon(Icons.close, size: 16, color: Colors.white),
                        onDeleted: () { setState(() { _selectedCategories.remove(category); }); },
                      ));
                    }).toList(),
                  ),
                ),
              //  SizedBox(height: 8.h),
              ],


          SizedBox(height: 20.h),

              // Main Content
              Expanded(child: _buildContentByLayout()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentByLayout() {
    if (isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    if (!isLoading && offers.isEmpty) return Center(child: Text("No Products Found", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])));
    if (_filteredOffers.isEmpty) return Center(child: Text("No products found", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16.sp)));

    switch (_selectedLayout) {
      case 0: return _buildGridView();
      case 1: return _buildHorizontalView();
      case 2: return _buildFullScreenView();
      default: return _buildGridView();
    }
  }

  // Grid View with Proper Scrollbar
  Widget _buildGridView() {
  double screenWidth = MediaQuery.of(context).size.width;
  return RawScrollbar(
    controller: _gridScrollController,
    thumbColor: AppTheme.primaryColor,
    trackColor: AppTheme.primaryColor.withOpacity(0.1),
    thickness: 6.0,
    radius: const Radius.circular(10),
    thumbVisibility: true,
    trackVisibility: false,
    interactive: true,
    child: GridView.builder(
      controller: _gridScrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth < 400 ? 2 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: _filteredOffers.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredOffers.length) {
          // 🔹 buildLoadingItem remove chesam → safe empty space
          return const SizedBox.shrink();
        }
        final offer = _filteredOffers[index];
        return _buildPremiumProductCard(context, offer);
      },
    ),
  );
}

  // Horizontal View with Proper Scrollbar - IMPROVED
  Widget _buildHorizontalView() {
  return RawScrollbar(
    controller: _horizontalScrollController,
    thumbColor: AppTheme.primaryColor,
    trackColor: AppTheme.primaryColor.withOpacity(0.1),
    thickness: 5.0,
    thumbVisibility: true,
    trackVisibility: false,
    interactive: true,
    child: ListView.builder(
      controller: _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: _filteredOffers.length,
      itemBuilder: (context, index) {
        final offer = _filteredOffers[index];
        return Container(
          width: 320.w, // ✅ Increased width for full screen design
          margin: EdgeInsets.only(right: 12.w, left: index == 0 ? 8.w : 0),
          child: _buildHorizontalProductCard(offer),
        );
      },
    ),
  );
}


  // Full Screen View with Proper Scrollbar
Widget _buildFullScreenView() {
  return RawScrollbar(
    controller: _fullScreenScrollController,
    thumbColor: AppTheme.primaryColor,
    trackColor: AppTheme.primaryColor.withOpacity(0.1),
    thickness: 6.0,
    radius: Radius.circular(10),
    thumbVisibility: true,
    trackVisibility: false,
    interactive: true,
    child: ListView.builder(
      controller: _fullScreenScrollController,
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: _filteredOffers.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredOffers.length) {
          // 🔹 buildLoadingItem remove chesam → safe empty widget
          return const SizedBox.shrink();
        }
        final offer = _filteredOffers[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h, left: 8.w, right: 8.w),
          child: _buildFullScreenProductCard(offer),
        );
      },
    ),
  );
}

  // Loading Item for Infinite Scroll


  // Horizontal Product Card - IMPROVED (Compact with Cart/Wishlist)
 Widget _buildHorizontalProductCard(Offer offer) {
  return GestureDetector(
    onTap: () => _navigateToDetailScreen(context, offer),
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView( // ✅ Prevents overflow safely
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Image Section
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25, // ✅ Responsive height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _getImageProvider(offer.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // 🔹 Status Tag
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: offer.status?.toUpperCase() == 'ACTIVE'
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          offer.status?.toUpperCase() == 'ACTIVE'
                              ? 'In Stock'
                              : 'Out of Stock',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // 🔹 Cart & Wishlist Icons
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _buildIconButton(
                            Icons.shopping_cart_outlined,
                            () => _addToCart(offer),
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          _buildIconButton(
                            Icons.favorite_border,
                            () => _addToWishlist(offer),
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Product Details Section
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                RichText(
  text: TextSpan(
    children: [
      // 🔹 Subproduct లేదా Product
      TextSpan(
        text: (offer.subproduct != null && offer.subproduct!.isNotEmpty)
            ? offer.subproduct!.toUpperCase()
            : offer.title.toUpperCase(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: const Color(0xFF2D3748),
        ),
      ),

      // 🔹 OriginalPrice ఉంటే మాత్రమే brackets లో చూపించు
      if (offer.originalPrice != null &&
          offer.originalPrice!.isNotEmpty)
        TextSpan(
          text: ' (${offer.originalPrice!.toUpperCase()})',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
    ],
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),


                    SizedBox(height: 12.h),

                    // Weight / Size / Tag Info Box
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("Gross Weight", offer.grossWeight ?? "N/A"),
                          _buildDetailRow("Net Weight", offer.netWeight ?? "N/A"),
                          if (offer.size != null && offer.size!.isNotEmpty)
                            _buildDetailRow("Size", offer.size!),
                          if (offer.tagNumber != null && offer.tagNumber!.isNotEmpty)
                            _buildDetailRow("Tag Number", offer.tagNumber!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


// ✅ Updated compact detail text with better styling

  // Premium Product Card - IMPROVED
  Widget _buildPremiumProductCard(BuildContext context, Offer offer) {
    return GestureDetector(
      onTap: () => _navigateToDetailScreen(context, offer),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with radius 5
            Container(
              height: 140.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                image: DecorationImage(image: _getImageProvider(offer.imagePath), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: offer.status?.toUpperCase() == 'ACTIVE' ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        offer.status?.toUpperCase() == 'ACTIVE' ? 'In Stock' : 'Out of Stock',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Cart & Wishlist Buttons
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _buildSmallIconButton(Icons.shopping_cart_outlined, () => _addToCart(offer)),
                        SizedBox(width: 4),
                        _buildSmallIconButton(Icons.favorite_border, () => _addToWishlist(offer)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name with Subproduct in brackets
                RichText(
  text: TextSpan(
    children: [
      // 🔹 Subproduct లేదా Product
      TextSpan(
        text: (offer.subproduct != null && offer.subproduct!.isNotEmpty)
            ? offer.subproduct!.toUpperCase()
            : offer.title.toUpperCase(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
          color: const Color(0xFF2D3748),
        ),
      ),

      // 🔹 OriginalPrice ఉంటే మాత్రమే brackets లో చూపించు
      if (offer.originalPrice != null &&
          offer.originalPrice!.isNotEmpty)
        TextSpan(
          text: ' (${offer.originalPrice!.toUpperCase()})',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
    ],
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),

                  SizedBox(height: 6.h),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offer.grossWeight != null) _buildSmallDetailText("Gross: ${offer.grossWeight}"),
                      if (offer.netWeight != null) _buildSmallDetailText("Net: ${offer.netWeight}"),
                      if (offer.tagNumber != null) _buildSmallDetailText("Tag: ${offer.tagNumber}"),
                      if (offer.size != null) _buildSmallDetailText("Size: ${offer.size}"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Full Screen Product Card - IMPROVED
  Widget _buildFullScreenProductCard(Offer offer) {
    return GestureDetector(
      onTap: () => _navigateToDetailScreen(context, offer),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with radius 5
            Container(
              width: double.infinity,
              height: 200.h, // Slightly reduced
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                image: DecorationImage(image: _getImageProvider(offer.imagePath), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: offer.status?.toUpperCase() == 'ACTIVE' ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        offer.status?.toUpperCase() == 'ACTIVE' ? 'In Stock' : 'Out of Stock',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Cart & Wishlist Buttons
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        _buildIconButton(Icons.shopping_cart_outlined, () => _addToCart(offer), size: 18.sp),
                        SizedBox(width: 8),
                        _buildIconButton(Icons.favorite_border, () => _addToWishlist(offer), size: 18.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name with Subproduct
                 RichText(
  text: TextSpan(
    children: [
      // 🔹 Subproduct లేదా Product
      TextSpan(
        text: (offer.subproduct != null && offer.subproduct!.isNotEmpty)
            ? offer.subproduct!.toUpperCase()
            : offer.title.toUpperCase(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: const Color(0xFF2D3748),
        ),
      ),

      // 🔹 OriginalPrice ఉంటే మాత్రమే brackets లో చూపించు
      if (offer.originalPrice != null &&
          offer.originalPrice!.isNotEmpty)
        TextSpan(
          text: ' (${offer.originalPrice!.toUpperCase()})',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
    ],
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),

                  SizedBox(height: 12.h),
                  
                  Container(
                    decoration: BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      children: [
                        _buildDetailRow("Gross Weight", offer.grossWeight ?? "N/A"),
                        _buildDetailRow("Net Weight", offer.netWeight ?? "N/A"),
                        if (offer.size != null) _buildDetailRow("Size", offer.size!),
                        if (offer.tagNumber != null) _buildDetailRow("Tag Number", offer.tagNumber!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildIconButton(IconData icon, VoidCallback onTap, {double size = 14}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))]),
        child: Icon(icon, color: AppTheme.primaryColor, size: size),
      ),
    );
  }

  Widget _buildSmallIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: Offset(0, 1))]),
        child: Icon(icon, color: AppTheme.primaryColor, size: 12),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHorizontal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isHorizontal ? 4.h : 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: isHorizontal ? 10.sp : 12.sp)),
          Text(value, style: GoogleFonts.inter(color: Color(0xFF2D3748), fontSize: isHorizontal ? 10.sp : 12.sp)),
        ],
      ),
    );
  }

  Widget _buildSmallDetailText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(text, style: GoogleFonts.inter(fontSize: 9.sp, color: Colors.grey[600])),
    );
  }

 

  void _addToCart(Offer offer) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8),
        Expanded(child: Text("${offer.title} added to cart", style: GoogleFonts.inter(color: Colors.white, fontSize: 14))),
      ]),
      backgroundColor: Colors.green, duration: Duration(seconds: 2),
    ));
  }

  void _addToWishlist(Offer offer) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.favorite, color: Colors.white, size: 20), SizedBox(width: 8),
        Expanded(child: Text("${offer.title} added to wishlist", style: GoogleFonts.inter(color: Colors.white, fontSize: 14))),
      ]),
      backgroundColor: Colors.orange, duration: Duration(seconds: 2),
    ));
  }

  ImageProvider<Object> _getImageProvider(String? path) {
    final imagePath = path?.trim() ?? '';
    if (imagePath.isNotEmpty && (imagePath.startsWith('http') || imagePath.startsWith('https'))) {
    return NetworkImage(imagePath);
    } else {
      return AssetImage('assets/images/cara4.png');
    }
  }

  // Filter Bottom Sheet method would go here...
  void _showFilterBottomSheet(BuildContext context) {
    // Your existing filter bottom sheet code
  }
}

class LayoutOption {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String type;

  LayoutOption({required this.id, required this.title, required this.subtitle, required this.icon, required this.type});
}