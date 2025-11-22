import 'dart:convert';
import 'package:caravelle/dashboard_naves/jewelery_screen.dart'; // Ensure this path is correct
import 'package:caravelle/model/offerscreen.dart'; // Ensure this path is correct
import 'package:caravelle/model/wishlistitem_model.dart'; // Ensure this path is correct
import 'package:caravelle/uittility/app_theme.dart'; // Ensure this path is correct
import 'package:caravelle/uittility/conasthan_api.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ⚠️ గమనిక: 'baseUrl', 'token', 'AppTheme.primaryColor', 'WishlistItem' మోడల్స్ 
// మరియు 'Offer' మోడల్ మీ ప్రాజెక్ట్‌లో సరిగ్గా నిర్వచించబడి ఉండాలి.

// --- Sample Wishlist Data ---
final List<WishlistItem> dummyWishlist = [];

bool isLoading = false;


class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<WishlistItem> _wishlist = List.from(dummyWishlist);
  bool _selectAll = false;

  int get _selectedCount => _wishlist.where((item) => item.isSelected).length;

  // 🌟 సవరించిన _removeItem ఫంక్షన్ - ఇది API ద్వారా రిమూవ్ చేస్తుంది
  void _removeItem(WishlistItem item) async {
    // 1. WishlistItem ను API కాల్ కోసం Offer మోడల్‌గా మ్యాప్ చేయండి
    final offer = Offer(
      imagePath: item.imageUrl,
      title: item.displayText ?? item.brandName,
      tagNumber: item.tag,
      grossWeight: item.gross,
      netWeight: item.net,
      description: '',
      stone: '',
      // 'id' ఫీల్డ్‌కి మ్యాపింగ్ చేయండి. మీ API కి ID అవసరం
      discountedPrice: '', // లేదా item.id (మీ WishlistItem మోడల్‌లో id ఉంటే)
      whish: 'YES', // ఇది ప్రస్తుతం wishlist లో ఉందని సూచించడానికి
      originalPrice: '',
    );

    print("🗑️ REMOVING ITEM VIA API - Tag: ${item.tag}");

    // 2. API ద్వారా రిమూవ్ ఫంక్షన్ కాల్ చేయండి (isRemove: true తో)
    await addToWishlist(offer, isRemove: true);

    // 3. స్థానిక జాబితా నుండి అంశాన్ని తొలగించండి (API కాల్ విజయవంతం అయిన తర్వాత)
    setState(() {
      _wishlist.remove(item);
      // selectAll స్థితిని కూడా అప్‌డేట్ చేయండి
      _selectAll = _wishlist.isNotEmpty && _wishlist.every((i) => i.isSelected);
    });

    // fetchWishlistItems(); // అవసరమైతే జాబితాను రిఫ్రెష్ చేయండి
  }

  void _toggleSelection(WishlistItem item, bool? value) {
    setState(() {
      item.isSelected = value ?? false;
      // Update selectAll status
      _selectAll = _wishlist.isNotEmpty && _wishlist.every((i) => i.isSelected);
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      for (var item in _wishlist) {
        item.isSelected = _selectAll;
      }
    });
  }

  void _moveSelectedToCart() {
    final selectedItems = _wishlist.where((item) => item.isSelected).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items to move to bag.')),
      );
      return;
    }

    print("🛒 MOVING TO CART - SELECTED ITEMS: ${selectedItems.length}");

    setState(() {
      _wishlist.removeWhere((item) => item.isSelected);
      _selectAll = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedItems.length} items moved to Bag!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addToBag(WishlistItem item) {
    print("🛍️ ADDING SINGLE ITEM TO BAG: ${item.brandName}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.brandName} added to bag!')),
    );
    // Bag కు యాడ్ చేసిన తర్వాత Wishlist నుండి రిమూవ్ చేయవచ్చు
    _removeItem(item); 
  }

  String _getDisplayText(String? subProduct, String? product, String? design) {
    String displayText = '';
    
    if (subProduct != null && subProduct.isNotEmpty && subProduct != 'null') {
      displayText = subProduct;
    } 
    else if (product != null && product.isNotEmpty && product != 'null') {
      displayText = product;
    }
    
    if (design != null && design.isNotEmpty && design != 'null' && displayText.isNotEmpty) {
      displayText = '$displayText ($design)';
    }
    else if (design != null && design.isNotEmpty && design != 'null' && displayText.isEmpty) {
      displayText = design;
    }
    
    return displayText;
  }

  Future<void> fetchWishlistItems() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobile = prefs.getString('mobile_number');

      if (mobile == null || mobile.isEmpty) {
        print("❌ ERROR: No mobile number found in SharedPreferences");
        setState(() => isLoading = false);
        return;
      }

      print("📱 FETCHING WISHLIST - Mobile: $mobile");
      final response = await http.post(
        Uri.parse("${baseUrl}whislist_display.php"),
        body: {
          "phone": mobile,
          "token": token,
        },
      );

      print("📊 API RESPONSE STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data["response"] == "success" && data["total_data"] != null) {
          List<dynamic> list = data["total_data"];
          print("🔄 PROCESSING ${list.length} ITEMS FROM API");

          setState(() {
            _wishlist.clear();
            _wishlist.addAll(
              list.map(
                (item) {
                  String displayText = _getDisplayText(
                    item["sub_product"]?.toString(),
                    item["product"]?.toString(),
                    item["design"]?.toString(),
                  );
                  
                  return WishlistItem(
                    brandName: item["name"] ?? "",
                    imageUrl: item["image_url"] ?? "",
                    gross: item["gross"]?.toString() ?? "",
                    net: item["net"]?.toString() ?? "",
                    stone: item["stone"]?.toString() ?? "",
                    tag: item["barcode"]?.toString() ?? "",
                    isSelected: false,
                    product: item["product"]?.toString(),
                    subProduct: item["sub_product"]?.toString(),
                    design: item["design"]?.toString(),
                    displayText: displayText,
                  );
                },
              ),
            );
          });
          print("✅ WISHLIST LOADED SUCCESSFULLY: ${_wishlist.length} items");
        } else {
          print("⚠️ WARNING: API returned no data or failed response");
        }
      } else {
        print("❌ ERROR: API request failed with status ${response.statusCode}");
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("❌ EXCEPTION in fetchWishlistItems(): $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🌟 addToWishlist ఫంక్షన్ - ఇది API ద్వారా ADD/REMOVE చేస్తుంది
  Future<void> addToWishlist(Offer offer, {bool isRemove = false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobile = prefs.getString('mobile_number');

      if (mobile == null || mobile.isEmpty) {
        print("❌ ERROR: No mobile number found");
        return;
      }

      print("🌐 Calling API for Whitelist ${isRemove ? 'REMOVE' : 'ADD'} - Tag: ${offer.tagNumber}");

      final response = await http.post(
        Uri.parse("${baseUrl}whislist.php"),
        body: {
          "phone": mobile,
          "barcode": offer.tagNumber,
          "id": offer.discountedPrice, // 'id' ఫీల్డ్
          "token": token,
          "action": isRemove ? "REMOVE" : "ADD"
        },
      );

      final data = json.decode(response.body);
      String message = data["message"] ?? (isRemove ? "Removed from Wishlist" : "Added to Wishlist");

      // ఈ స్క్రీన్ లో Offer మోడల్ ఉపయోగించబడనప్పటికీ, మీరు setState ని ఉపయోగించవచ్చు
      // Offer మోడల్ యొక్క 'whish' స్థితిని అప్డేట్ చేయాల్సిన అవసరం లేదు.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e) {
      print("⚠️ ERROR in addToWishlist(): $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update wishlist status: $e")),
      );
    }
  }

  void _navigateToDetailScreen(BuildContext context, WishlistItem item) {
    // WishlistItem ను Offer మోడల్‌గా మార్చడం (Mapping WishlistItem to Offer)
    final offer = Offer(
      imagePath: item.imageUrl,
      title: item.displayText ?? item.brandName,
      tagNumber: item.tag,
      grossWeight: item.gross,
      netWeight: item.net,
      description: '', 
      stone: '',
      discountedPrice: '',
      whish: '',
      originalPrice: '',
      // Add other required fields if necessary
    );

    print("➡️ NAVIGATING to Detail Screen for Tag: ${item.tag}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JewelryDetailScreen(
          offer: offer,
          tagNumber: item.tag,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print("🚀 WISHLIST SCREEN INITIALIZED");
    fetchWishlistItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Wishlist', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: null,

      // RIGHT SIDE: Select All button here
      actions: [
        if (_wishlist.isNotEmpty)
          TextButton(
            onPressed: _toggleSelectAll,
            child: Text(
              _selectAll ? 'Deselect All' : 'Select All',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      
      ),
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlist.isEmpty
              ? Center(
                  child: Text(
                    "Your Wishlist is Empty.",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: _wishlist.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemBuilder: (context, index) {
                      final item = _wishlist[index];
                      return WishlistProductCard(
                        item: item,
                        onRemove: () => _removeItem(item), // ✅ _removeItem కాల్ అవుతుంది
                        onAddToBag: () => _addToBag(item),
                        onToggleSelect: (value) => _toggleSelection(item, value),
                        onTap: () => _navigateToDetailScreen(context, item),
                      );
                    },
                  ),
                ),

      bottomNavigationBar: Container(
        height: 70.h,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: ElevatedButton(
          onPressed: _selectedCount > 0 ? _moveSelectedToCart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedCount > 0 ? AppTheme.primaryColor : Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
          child: Text(
            _selectedCount > 0
                ? 'Add $_selectedCount Selected Item(s) to Bag'
                : 'Select Items to Add to Bag',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------

class WishlistProductCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToBag;
  final Function(bool?) onToggleSelect;
  final VoidCallback? onTap; 

  const WishlistProductCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onAddToBag,
    required this.onToggleSelect,
    this.onTap,
  });

  Widget _buildJewelryDetail(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ మొత్తం కార్డ్ కంటైనర్‌ను GestureDetector తో చుట్టాము
    return GestureDetector(
      onTap: onTap, 
      onLongPress: () => onToggleSelect(!item.isSelected), // Long Press తో సెలెక్ట్
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: item.isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: item.isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE AREA
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                            ),
                          ),
                  ),

                  // SELECTION OVERLAY
                  if (item.isSelected)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                    ),

                  // CHECKBOX (top left)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      color: Colors.transparent, 
                      child: Checkbox( 
                        value: item.isSelected,
                        onChanged: (value) => onToggleSelect(value),
                        activeColor: AppTheme.primaryColor,
                        checkColor: Colors.white,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DETAILS & BUTTONS
            Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.displayText != null && item.displayText!.isNotEmpty)
                    Text(
                      item.displayText!,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 12.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildJewelryDetail('Gross Wt.', item.gross),
                      _buildJewelryDetail('Net Wt.', item.net),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildJewelryDetail('Stone Wt.', item.stone),
                      _buildJewelryDetail('Tag', item.tag, color: AppTheme.primaryColor),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRemove, // ✅ Remove button click calls onRemove
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade300, width: 1.5),
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Remove',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAddToBag,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
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
}