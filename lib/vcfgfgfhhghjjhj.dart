
import 'dart:convert';

import 'package:caravelle/dashboard_naves/cart_screen.dart';
import 'package:caravelle/dashboard_naves/whislist_screen.dart' hide CartScreen;
import 'package:caravelle/model/offerscreen.dart';
import 'package:caravelle/dashboard_naves/jewelery_screen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class GoldShopOffersScreen1 extends StatefulWidget {
  final String? mainCategory;
  final String? subCategory;
  final String subProducts;
  final String? product; // ✅ new
  final String? type;    // ✅ new

  const GoldShopOffersScreen1({
    Key? key,
    this.mainCategory,
    this.subCategory,
    required this.subProducts,
    this.product, // ✅ add
    this.type,    // ✅ add
  }) : super(key: key);

  @override
  State<GoldShopOffersScreen1> createState() => _GoldShopOffersScreen1State();
}

class _GoldShopOffersScreen1State extends State<GoldShopOffersScreen1> {
  final TextEditingController _searchController = TextEditingController();
 
  String _sortBy = "Default";
  bool _sortAscending = true;

  bool isLoading = true;
  List<dynamic> totalData = [];

  List<Offer> offers = [];


  @override
  void initState() {
    super.initState();
    fetchSubProductItems();
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
        'sub_product': widget.subProducts, // single sub product name (e.g. LADIES BRACELET)
        'product': widget.product ?? '', // ✅ send main product
        'type': widget.type ?? '',       // ✅ send type
      },
    );

    print('🔹 API URL: https://caravelle.in/barcode/app/sub_product_items.php');
    print('🔹 Sent SubProduct: ${widget.subProducts}');
    print('🔹 Status Code: ${response.statusCode}');
      print('🔹 Sent Product: ${widget.product}');
    print('🔹 Sent Type: ${widget.type}');
    

    response.body.toString().split('\n').forEach((line) => print(line));


    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response'] == 'success' && data['total_data'] != null) {
        final List<dynamic> list = data['total_data'];
        

        // ✅ Convert API response to Offer model list
        setState(() {
          offers = list.map((item) {
             print('🖼️ Image URL: ${item['image_url']}');
            return Offer(
            imagePath: item['image_url'] != null && item['image_url'].isNotEmpty
    ? "${item['image_url']}"
    : "",


              title: item['product']?.toString() ?? 'Unknown Product',
              originalPrice: '', // optional: add if backend sends price
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
        // ❌ No Data
        setState(() {
          offers = [];
          isLoading = false;
        });
        print('⚠️ No Data Found');
      }
    } else {
      // ❌ Server Error
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
  int _selectedLayout = 0; // 0: Grid, 1: Horizontal, 2: Full Screen
  
  // For bottom sheet filter
  List<String> _selectedCategories = [];
  final List<String> _jewelryCategories = [
    "Mangalasutra",
    "Vaddanam", 
    "Vanki",
    "Earrings",
    "Necklace",
    "Bangles",
    "Rings",
    "Bridal Set",
    "Temple Jewelry",
  ];

  // Layout options data
  final List<LayoutOption> _layoutOptions = [
  LayoutOption(
    id: 0,
    title: "",
    subtitle: "",
    icon: Icons.grid_view_rounded,
    type: "grid",
  ),
  LayoutOption(
    id: 1, 
    title: "",
    subtitle: "",
    icon: Icons.view_carousel_rounded,
    type: "horizontal",
  ),
  LayoutOption(
    id: 2,
    title: "",
    subtitle: "",
    icon: Icons.view_agenda_rounded,
    type: "list",
  ),
];

  // Detail screen for each jewelry item
  void _navigateToDetailScreen(BuildContext context, Offer offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JewelryDetailScreen(offer: offer,tagNumber: '',),
      ),
    );
  }

  // Add this method to parse weight
  double _parseWeight(String weight) {
    if (weight == null || weight.isEmpty) return 0.0;
    String cleanWeight = weight.replaceAll('g', '').trim();
    return double.tryParse(cleanWeight) ?? 0.0;
  }

  List<Offer> get _filteredOffers {
    List<Offer> filtered = List.from(offers);
    
    // Search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((offer) => 
        offer.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        offer.description.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    // Category filter from bottom sheet
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((offer) {
        for (String category in _selectedCategories) {
          if (offer.title.toLowerCase().contains(category.toLowerCase())) {
            return true;
          }
        }
        return false;
      }).toList();
    }
    
    // Sort logic - UPDATED WITH WEIGHT AND DATE SORTING
    if (_sortBy == "Weight") {
      filtered.sort((a, b) {
        double weightA = _parseWeight(a.grossWeight ?? "0");
        double weightB = _parseWeight(b.grossWeight ?? "0");
        return _sortAscending ? weightA.compareTo(weightB) : weightB.compareTo(weightA);
      });
    } else if (_sortBy == "Newest" || _sortBy == "Oldest") {
      // For demo, using list index as creation order
      filtered.sort((a, b) {
        int indexA = offers.indexOf(a);
        int indexB = offers.indexOf(b);
        return _sortAscending ? indexA.compareTo(indexB) : indexB.compareTo(indexA);
      });
    }
    
    return filtered;
  }

  

  // Show Layout Options Bottom Sheet
 void _showLayoutOptionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          height: 180.h, // Even more compact
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Layout",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey, size: 20.sp),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Layout Options - Compact
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _layoutOptions.map((layout) {
                        return _buildCompactLayoutOption(layout);
                      }).toList(),
                    ),
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
      setState(() {
        _selectedLayout = layout.id;
      });
      Navigator.pop(context);
    },
    child: Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: isSelected ? Colors.amber.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.amber.shade300 : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          if (isSelected)
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        layout.icon,
        color: isSelected ? Colors.amber.shade700 : Colors.grey.shade600,
        size: 24.sp,
      ),
    ),
  );
}
 void _showFilterBottomSheet(BuildContext context) {
  // New filter state variables
  double _selectedSize = 5.0;
  String _selectedDesignType = '';

  final List<String> _designTypes = ['Plain', 'Studded with Stones'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filters",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search categories...",
                          hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 13.h),
                          prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  
                  // Section Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select your favourite categories",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Categories List with Checkboxes - 2 columns layout
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Categories Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 3.0,
                            ),
                            itemCount: _jewelryCategories.length,
                            itemBuilder: (context, index) {
                              final category = _jewelryCategories[index];
                              final isSelected = _selectedCategories.contains(category);
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    category,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2D3748),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setModalState(() {
                                      if (value == true) {
                                        _selectedCategories.add(category);
                                      } else {
                                        _selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                  checkColor: Colors.white,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                  dense: true,
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 24.h),

                          // NEW: Weight Range Section
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Weight Range (grams)",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                
                                // Weight Input Fields in Single Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "From",
                                            labelStyle: GoogleFonts.inter(fontSize: 12.sp),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                            suffixText: "g",
                                            suffixStyle: GoogleFonts.inter(
                                              color: Colors.grey,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setModalState(() {
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Container(
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "To",
                                            labelStyle: GoogleFonts.inter(fontSize: 12.sp),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                            suffixText: "g",
                                            suffixStyle: GoogleFonts.inter(
                                              color: Colors.grey,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setModalState(() {
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // NEW: Size Slider Section
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Size",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    Text(
                                      "${_selectedSize.toStringAsFixed(1)}",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                
                                // Size Slider
                                Slider(
                                  value: _selectedSize,
                                  min: 1.0,
                                  max: 10.0,
                                  divisions: 18, // For 0.5 increments
                                  label: _selectedSize.toStringAsFixed(1),
                                  activeColor: AppTheme.primaryColor,
                                  inactiveColor: Colors.grey.shade300,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _selectedSize = value;
                                    });
                                  },
                                ),
                                
                                // Size indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "1",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "10",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // NEW: Design Type Section
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Design Type",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                
                                // Design Type Selection
                                Row(
                                  children: _designTypes.map((type) {
                                    final isSelected = _selectedDesignType == type;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            _selectedDesignType = type;
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppTheme.primaryColor : Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            type,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected ? Colors.white : Color(0xFF2D3748),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Actions
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategories.clear();
                                _selectedSize = 5.0;
                                _selectedDesignType = '';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Clear All",
                              style: GoogleFonts.inter(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Apply all filters
                              setState(() {
                                // You can store these filter values in your main state
                                // and use them to filter your jewelry items
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Apply Filters",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
  final List<Offer> offers1 = [
    Offer(
      imagePath: 'assets/images/cara4.png',
      title: "Gold Mangalasutra",
      originalPrice: "",
      discountedPrice: "",
      description: "Traditional bridal mangalasutra with intricate design and premium 18K gold finish.",
      grossWeight: "8.5g",
      netWeight: "7.2g",
      size: "22 inches",
      tagNumber: "TAG-TMP-008",
      status: 'status',
      subproduct: 'sub_product'
    ),
    Offer(
      imagePath: 'assets/images/cara2.png',
      title: "Gold Vaddanam",
      originalPrice: "",
      discountedPrice: "",
      description: "Elegant waist belt with detailed craftsmanship and precious stone work.",
      grossWeight: "15.2g",
      netWeight: "12.8g",
      size: "32 inches", 
      tagNumber: "TAG-TMP-008",
       status: 'status',
       subproduct: 'sub_product'
    ),
    Offer(
      imagePath: 'assets/images/cara2.png',
      title: "Gold Vanki",
      originalPrice: "",
      discountedPrice: "",
      description: "Traditional armlet with classic design patterns and comfortable fit.",
      grossWeight: "6.8g",
      netWeight: "5.5g",
      size: "Medium",
      tagNumber: "TAG-TMP-008",
       status: 'status',
       subproduct: 'sub_product'
    ),
    Offer(
      imagePath: 'assets/images/cara4.png',
      title: "Diamond Earrings",
      originalPrice: "",
      discountedPrice: "",
      description: "Luxurious diamond-studded earrings with premium 18K gold setting.",
      grossWeight: "4.2g",
      netWeight: "3.1g",
      size: "Small",
      tagNumber: "TAG-TMP-008",
       status: 'status',
       subproduct: 'sub_product'
    ),
    Offer(
      imagePath: 'assets/images/cara2.png',
      title: "Pearl Necklace",
      originalPrice: "",
      discountedPrice: "",
      description: "Elegant pearl necklace with gold accents and secure clasp.",
      grossWeight: "12.5g",
      netWeight: "9.8g",
      size: "18 inches",
      tagNumber: "TAG-TMP-008",
       status: 'status',
       subproduct: 'sub_product'
    ),
    Offer(
      imagePath: 'assets/images/cara3.png',
      title: "Bridal Set",
      originalPrice: "",
      discountedPrice: "",
      description: "Complete bridal jewelry set including necklace, earrings, and bangles.",
      grossWeight: "45.6g",
      netWeight: "38.2g",
      size: "Set",
      tagNumber: "TAG-TMP-008",
       status: 'status',
       subproduct: 'sub_product'
    ),
    Offer(
      imagePath: 'assets/images/cara4.png',
      title: "Gold Bangles",
      originalPrice: "",
      discountedPrice: "",
      description: "Set of four traditional gold bangles with intricate carvings.",
      grossWeight: "22.4g",
      netWeight: "18.7g",
      size: "2.5 inches",
      tagNumber: "TAG-TMP-008",
       status: 'status',
       subproduct: 'sub_product'
    ),
    Offer(
      imagePath: 'assets/images/cara4.png',
      title: "Temple Jewelry",
      originalPrice: "",
      discountedPrice: "",
      description: "Traditional temple-style jewelry with divine motifs and premium finish.",
      grossWeight: "28.9g",
      netWeight: "24.3g",
      size: "20 inches",
      tagNumber: "TAG-TMP-008",
       status: 'status',
       subproduct: 'sub_product'
    ),
  ];

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
         widget.subProducts,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppTheme.headerSize,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        shadowColor: AppTheme.primaryColor.withOpacity(0.3),
      ),
      body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🟢 Header Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
            ],
          ),
        ),

        // 🟢 Search Bar
        Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search jewelry...",
              hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 10.h),
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
              border: InputBorder.none,
            ),
          ),
        ),
      //  SizedBox(height: 16.h),

        // 🟢 Filter + Layout + Sort Row
      Padding(
  padding: EdgeInsets.symmetric(horizontal: 0.w), // left-right equal padding
  child: SizedBox(
    height: 50.h,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 Equal spacing
      children: [
        // 🔹 Filter Button
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: AppTheme.primaryColor, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  _selectedCategories.isEmpty
                      ? "Filter"
                      : "Filter (${_selectedCategories.length})",
                  style: GoogleFonts.inter(fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        // 🔹 Layout Button
        GestureDetector(
          onTap: () => _showLayoutOptionsSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.layers, color: AppTheme.primaryColor, size: 16.sp),
                SizedBox(width: 4.w),
                Text("Layout", style: GoogleFonts.inter(fontSize: 12)),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor, size: 16.sp),
              ],
            ),
          ),
        ),

        // 🔹 Sort Button
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              if (value == "Weight Low to High") {
                _sortBy = "Weight";
                _sortAscending = true;
              } else if (value == "Weight High to Low") {
                _sortBy = "Weight";
                _sortAscending = false;
              } else if (value == "Newest First") {
                _sortBy = "Newest";
                _sortAscending = false;
              } else if (value == "Oldest First") {
                _sortBy = "Oldest";
                _sortAscending = true;
              } else {
                _sortBy = "Default";
              }
            });
          },
          itemBuilder: (context) => const [
          //  PopupMenuItem(value: "Default", child: Text("Default")),
            PopupMenuItem(value: "Weight Low to High", child: Text("Weight Low to High")),
            PopupMenuItem(value: "Weight High to Low", child: Text("Weight High to Low")),
            PopupMenuItem(value: "Newest First", child: Text("Newest First")),
            PopupMenuItem(value: "Oldest First", child: Text("Oldest First")),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.sort, color: AppTheme.primaryColor, size: 16.sp),
                SizedBox(width: 4.w),
                Text("Sort", style: GoogleFonts.inter(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),

     //   SizedBox(height: 16.h),

        // 🟢 Selected Filter Chips
        if (_selectedCategories.isNotEmpty) ...[
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _selectedCategories.map((category) {
                return Container(
                  margin: EdgeInsets.only(right: 8.r),
                  child: Chip(
                    label: Text(
                      category,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                    deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        _selectedCategories.remove(category);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8.h),
        ],

        // 🟢 Current Layout Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _layoutOptions[_selectedLayout].icon,
                color: AppTheme.primaryColor,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _layoutOptions[_selectedLayout].title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),

        // 🟢 Main Content — Fixed logic
        Expanded(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                // Show loader while fetching
                return const Center(child: CircularProgressIndicator());
              }

              if (!isLoading && offers.isEmpty) {
                // Show "No Products Found" only after loading finishes
                return Center(
                  child: Text(
                    "No Products Found",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                );
              }

              // When products available — show content
              return _buildContentByLayout();
            },
          ),
        ),
      ],
    ),
  ),
),

    );
  }

  Widget _buildContentByLayout() {
    if (_filteredOffers.isEmpty) {
      return Center(
        child: Text(
          "No products found",
          style: GoogleFonts.inter(
            color: Colors.grey,
            fontSize: 16.sp,
          ),
        ),
      );
    }

    switch (_selectedLayout) {
      case 0: // Grid Layout
        return _buildGridView();
      case 1: // Horizontal Layout
        return _buildHorizontalView();
      case 2: // Full Screen Layout
        return _buildFullScreenView();
      default:
        return _buildGridView();
    }
  }

  // Grid View - BIGGER IMAGE
  Widget _buildGridView() {
    double screenWidth = MediaQuery.of(context).size.width;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth < 400 ? 2 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: _filteredOffers.length,
      itemBuilder: (context, index) {
        final offer = _filteredOffers[index];
        return _buildPremiumProductCard(context, offer);
      },
    );
  }

  // Horizontal View - BIGGER IMAGE
 // UPDATED HORIZONTAL VIEW - WITH BIG IMAGE LIKE FULL SCREEN
Widget _buildHorizontalView() {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _filteredOffers.length,
    itemBuilder: (context, index) {
      final offer = _filteredOffers[index];
      return Container(
        width: 320.w, // INCREASED: More width for bigger content
        margin: EdgeInsets.only(right: 16.w),
        child: _buildHorizontalProductCard(offer), // NEW: Special horizontal card with big image
      );
    },
  );
}


Widget _buildHorizontalProductCard(Offer offer) {
  return GestureDetector(
    onTap: () => _navigateToDetailScreen(context, offer),
    child: Container(
      constraints: BoxConstraints(
      //  maxHeight: 300, // INCREASED: More height for text buttons
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // BIG IMAGE
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.30,
           decoration: BoxDecoration(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  image: DecorationImage(
    image: (offer.imagePath.trim().isNotEmpty)
        ? (offer.imagePath.trim().startsWith('http')
            ? NetworkImage(offer.imagePath.trim())
            : AssetImage(offer.imagePath.trim()))
        : const AssetImage('assets/images/cara4.png'),
    fit: BoxFit.cover,
  ),
),

            child: Stack(
              children: [
                // Discount Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: offer.status?.toUpperCase() == 'ACTIVE'
        ? Colors.green
        : Colors.red,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(
    offer.status?.toUpperCase() == 'ACTIVE' ? 'In Stock' : 'Out  Stock',
    style: GoogleFonts.inter(
      color: Colors.white, // 👈 White text for visibility
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                ),
                // Favorite and Cart Icons
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      // Cart Icon
                      GestureDetector(
                        onTap: () => _addToCart(offer),
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: AppTheme.primaryColor,
                            size: 14.sp,
                          ),
                        ),
                      ),
                      // Favorite Icon
                      GestureDetector(
                        onTap: () => _addToWishlist(offer),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            color: AppTheme.primaryColor,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // CONTENT - WITH  horizantal desgin TEXT BUTTONS
         Flexible(
  fit: FlexFit.loose, // 👈 prevents stretching to full height
  child: Padding(
    padding: EdgeInsets.all(12.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 👈 keeps it tight fit
      children: [
        // TITLE
      Text(
  (offer.subproduct != null && offer.subproduct!.isNotEmpty)
      ? offer.subproduct! // subproduct ఉన్నప్పుడు దానినే చూపించు
      : offer.title,      // లేకపోతే product title చూపించు
  style: GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 14.sp,
    color: const Color(0xFF2D3748),
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),

        SizedBox(height: 6.h),

        // DETAILS BOX
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(8.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHorizontalDetailRow("Gross", offer.grossWeight ?? "N/A"),
              _buildHorizontalDetailRow("Net", offer.netWeight ?? "N/A"),
              if (offer.size != null)
                _buildHorizontalDetailRow("Size", offer.size!),
              if (offer.tagNumber != null)
                _buildHorizontalDetailRow("Tag", offer.tagNumber!),
            ],
          ),
        ),

        SizedBox(height: 6.h), // 👈 reduced space above buttons

        // BUTTONS ROW
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addToCart(offer),
                icon: Icon(Icons.shopping_cart, size: 16.sp, color: Colors.white),
                label: Text(
                  "Add Cart",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToWishlist(offer),
                icon: Icon(Icons.favorite_border,
                    size: 16.sp, color: AppTheme.primaryColor),
                label: Text(
                  "Wishlist",
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
        // 👇 Removed any SizedBox after this (no bottom gap)
      ],
    ),
  ),
),


          
        ],
      ),
    ),
  );
}

// UPDATED: DETAIL ROW FOR HORIZONTAL VIEW
Widget _buildHorizontalDetailRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 9.r),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 10.sp,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Color(0xFF2D3748),
            fontSize: 10.sp,
          ),
        ),
      ],
    ),
  );
}
  // CHANGED: Full Screen View - VERTICAL SCROLL LIST
  Widget _buildFullScreenView() {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: _filteredOffers.length,
      itemBuilder: (context, index) {
        final offer = _filteredOffers[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: _buildFullScreenProductCard(offer),
        );
      },
    );
  }

  // UPDATED PREMIUM PRODUCT CARD - BIGGER IMAGE & BETTER LAYOUT
  Widget _buildPremiumProductCard(BuildContext context, Offer offer) {
    return GestureDetector(
      onTap: () => _navigateToDetailScreen(context, offer),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 280.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Container - BIGGER
            Container(
              height: 152.h,
              width: double.infinity,
            decoration: BoxDecoration(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  image: DecorationImage(
    image: _getImageProvider(offer.imagePath),
    fit: BoxFit.cover,
  ),
),

              child: Stack(
                children: [
                  // Discount Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: offer.status?.toUpperCase() == 'ACTIVE'
        ? Colors.green
        : Colors.red,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(
    offer.status?.toUpperCase() == 'ACTIVE' ? 'In Stock' : 'Out  Stock',
    style: GoogleFonts.inter(
      color: Colors.white, // 👈 White text for visibility
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  ),
),

                  ),
                  // Favorite and Cart Icons
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        // Cart Icon
                        GestureDetector(
                          onTap: () {
                            _addToCart(offer);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            margin: EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: AppTheme.primaryColor,
                              size: 14.sp,
                            ),
                          ),
                        ),
                        // Favorite Icon
                        GestureDetector(
                          onTap: () {
                            _addToWishlist(offer);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: AppTheme.primaryColor,
                              size: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
         
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                   Text(
  (offer.subproduct != null && offer.subproduct!.isNotEmpty)
      ? '${offer.subproduct}'
      : offer.title,
  style: GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 14.sp,
    color: const Color(0xFF2D3748),
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),

                    SizedBox(height: 6.h),
                    
                    // Weight and Size Info - BETTER ORGANIZED
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (offer.grossWeight != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Text(
                              "Gross: ${offer.grossWeight}",
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        if (offer.netWeight != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Text(
                              "Net: ${offer.netWeight}",
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          if (offer.tagNumber != null )
  Padding(
    padding: EdgeInsets.only(bottom: 2.h),
    child: Text(
      "Tag No: ${offer.tagNumber}",
      style: GoogleFonts.inter(
        fontSize: 10.sp,
        color: Colors.grey[600],
      ),
    ),
  ),
                        if (offer.size != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Text(
                              "Size: ${offer.size}",
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                      
                      ],
                    ),
                    
                    // Price Section - BETTER VISIBILITY
                    
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED FULL SCREEN PRODUCT CARD - VERTICAL LIST ITEM
  Widget _buildFullScreenProductCard(Offer offer) {
    return GestureDetector(
      onTap: () => _navigateToDetailScreen(context, offer),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - BIGGEST
            Container(
              width: double.infinity,
              height: 250.h, // Big image for full screen view
             decoration: BoxDecoration(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  image: DecorationImage(
    image: _getImageProvider(offer.imagePath),
    fit: BoxFit.cover,
  ),
),

              child: Stack(
                children: [
                  // Discount Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: offer.status?.toUpperCase() == 'ACTIVE'
        ? Colors.green
        : Colors.red,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(
    offer.status?.toUpperCase() == 'ACTIVE' ? 'In Stock' : 'Out  Stock',
    style: GoogleFonts.inter(
      color: Colors.white, // 👈 White text for visibility
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                  ),
                  // Favorite and Cart Icons
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        // Cart Icon
                        GestureDetector(
                          onTap: () => _addToCart(offer),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: AppTheme.primaryColor,
                              size: 16.sp,
                            ),
                          ),
                        ),
                        // Favorite Icon
                        GestureDetector(
                          onTap: () => _addToWishlist(offer),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: AppTheme.primaryColor,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    offer.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /*
                  
                  // Description
                  Text(
                    offer.description,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  */
                  
                  // Details
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        _buildDetailRow("Gross Weight", offer.grossWeight ?? "N/A"),
                        _buildDetailRow("Net Weight", offer.netWeight ?? "N/A"),
                        _buildDetailRow("Size", offer.size ?? "N/A"),
                        _buildDetailRow("Tag Number", offer.tagNumber ?? "N/A"),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Price and Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
                      Row(
                        children: [
                          // Cart Button
                          ElevatedButton.icon(
                            onPressed: () => _addToCart(offer),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.shopping_cart, size: 16.sp),
                            label: Text("Add to Cart"),
                          ),
                          SizedBox(width: 18.w),
                          // Wishlist Button
                          OutlinedButton.icon(
                            onPressed: () => _addToWishlist(offer),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: AppTheme.primaryColor),
                            ),
                            icon: Icon(Icons.favorite_border, size: 16.sp),
                            label: Text("Wishlist"),
                          ),
                        ],
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Color(0xFF2D3748),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // SAME CART AND WISHLIST FUNCTIONS
  void _addToCart(Offer offer) {
    print("Added to cart: ${offer.title}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "${offer.title} added to cart",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: "Go to Cart",
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => CartScreen())
            );
          },
        ),
      ),
    );
  }

  void _addToWishlist(Offer offer) {
    print("Added to wishlist: ${offer.title}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "${offer.title} added to wishlist",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: "View Wishlist",
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => WishlistScreen())
            );
          },
        ),
      ),
    );
  }

  ImageProvider<Object> _getImageProvider(String? path) {
  final imagePath = path?.trim() ?? '';
  if (imagePath.isNotEmpty && (imagePath.startsWith('http') || imagePath.startsWith('https'))) {
    return NetworkImage(imagePath);
  } else {
    return const AssetImage('assets/images/cara4.png');
  }
}

}

// Layout Option Model
class LayoutOption {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String type;

  LayoutOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });
}