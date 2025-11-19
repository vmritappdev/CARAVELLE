import 'dart:convert';
import 'package:caravelle/dashboard_naves/cart_screen.dart';
import 'package:caravelle/dashboard_naves/fullscreenimage.dart';
import 'package:caravelle/model/cart.dart';
import 'package:caravelle/model/offerscreen.dart';
import 'package:caravelle/model/whishlist.dart';
import 'package:caravelle/screens/custmaization_screen.dart' hide CartScreen;
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class JewelryDetailScreen extends StatefulWidget {
  final Offer offer;
  final String? tagNumber;

  const JewelryDetailScreen({
    super.key,
    required this.offer,
    required this.tagNumber,
  });

  @override
  State<JewelryDetailScreen> createState() => _JewelryDetailScreenState();
}

class _JewelryDetailScreenState extends State<JewelryDetailScreen> {
  bool isWishlisted = false;
  bool _isSpecificationsExpanded = true;
  bool _isLoading = true;
  
  // API data state variables
  Map<String, dynamic>? _apiData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    isWishlisted = Wishlist().contains(widget.offer);
    fetchJewelryDetails();
  }

  Future<void> fetchJewelryDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await http.post(
        Uri.parse('${baseUrl}barcode_product.php'),
        body: {
          'token': token,
          'barcode': widget.tagNumber,
        },
      );

      print('🔹 API URL: ${baseUrl}barcode_product.php');
      print('🔹 Sent Barcode: ${widget.tagNumber}');
      print('🔹 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Full Response: $data');

        if (data['response'] == 'success' && data['total_count'] > 0) {
          setState(() {
            _apiData = data['total_data'][0];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Product not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network Error: $e';
        _isLoading = false;
      });
    }
  }

  // Helper method to get display product name
  String getDisplayProductName() {
    if (_apiData == null) return widget.offer.title;
    
    final product = _apiData!['product']?.toString() ?? '';
    final subProduct = _apiData!['sub_product']?.toString();
    
    if (subProduct == null || subProduct.isEmpty || subProduct == 'null') {
      return product.isNotEmpty ? product : widget.offer.title;
    } else {
      return '$product ($subProduct)';
    }
  }

  // Helper method to get design
  String getDesign() {
    if (_apiData == null) return '';
    
    final design = _apiData!['design']?.toString();
    return (design != null && design.isNotEmpty && design != 'null') 
        ? design 
        : '';
  }

  // Helper method to get image URL
  String getImageUrl() {
    if (_apiData == null) return widget.offer.imagePath;
    
    final imageUrl = _apiData!['image_url']?.toString();
    return (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null') 
        ? imageUrl 
        : widget.offer.imagePath;
  }

  // Helper method to format weight
  String formatWeight(dynamic weight) {
    if (weight == null) return "N/A";
    final weightStr = weight.toString();
    return weightStr != 'null' ? '$weightStr g' : 'N/A';
  }

  // Helper method to format pieces
  String formatPieces(dynamic pieces) {
    if (pieces == null) return "1 pc";
    final piecesStr = pieces.toString();
    return piecesStr != 'null' ? '$piecesStr pcs' : '1 pc';
  }

  void toggleWishlist() {
    setState(() {
      Wishlist().toggleItem(widget.offer);
      isWishlisted = Wishlist().contains(widget.offer);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isWishlisted ? "Added to wishlist" : "Removed from wishlist",
          ),
          backgroundColor: Colors.black,
        ),
      );
    });
  }

  void _showStoneInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Stone Information",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          "This jewelry features ${widget.offer.stoneType ?? 'precious stones'}. "
          "The stones are carefully selected for their quality and brilliance.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    
                    // Loading State
                    if (_isLoading) ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Loading product details...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                    
                    // Error State
                    else if (_errorMessage != null) ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, 
                                  color: Colors.orange, size: 40),
                              SizedBox(height: 8),
                              Text(
                                "Oops!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                             SizedBox(height: 4),
Text(
  _errorMessage!,
  style: TextStyle(
    fontSize: 13,
    color: Colors.grey[600],
  ),
  textAlign: TextAlign.center,
),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: fetchJewelryDetails,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                ),
                                child: Text(
                                  "Try Again",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                    
                    // Success State
                    else ...[
                      // Product Image
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageViewer(
                                imagePath: getImageUrl(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 250, // Reduced from 300
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: getImageUrl().startsWith('http')
                                  ? NetworkImage(getImageUrl()) as ImageProvider
                                  : AssetImage(getImageUrl()),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
                      
                      // Product Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getDisplayProductName(),
                            style: TextStyle(
                              fontSize: 20, // Reduced from 24
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                        ],
                      ),

                      SizedBox(height: 16),
                      
                      // Product Specifications
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14), // Reduced from 16
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSpecificationsExpanded = !_isSpecificationsExpanded;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Product Specifications",
                                    style: TextStyle(
                                      fontSize: 15, // Reduced from 16
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  Icon(
                                    _isSpecificationsExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppTheme.primaryColor,
                                    size: 20, // Reduced from 24
                                  ),
                                ],
                              ),
                            ),
                            if (_isSpecificationsExpanded) ...[
                              SizedBox(height: 10),
                              _buildSpecificationRow("Product", getDisplayProductName()),
                              _buildSpecificationRow("Design", getDesign()),
                              _buildSpecificationRow("Gross Weight", formatWeight(_apiData?['gross'])),
                              _buildStoneTypeWithEye(),
                              _buildSpecificationRow("Net Weight", formatWeight(_apiData?['net'])),
                              _buildSpecificationRow("Purity", _apiData?['type']?.toString() ?? "18KT"),
                              _buildSpecificationRow("Size", _apiData?['size']?.toString() ?? "Standard"),
                              _buildSpecificationRow("Pieces", formatPieces(_apiData?['pcs'])),
                            //  _buildSpecificationRow("HUID", _apiData?['huid']?.toString() ?? "N/A"),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 16),
                      
                      // Customize Button
                      Container(
                        width: double.infinity,
                        height: 48, // Reduced from 56
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomizationScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Customize This Design",
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14, // Reduced from 16
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Fixed Custom AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.primaryColor, size: 18),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.all(4),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Product Details",
                      style: TextStyle(
                        fontSize: 16, // Reduced from 18
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartScreen()),
                        );
                      },
                      child: Icon(Icons.shopping_cart_outlined,
                          color: Colors.black, size: 20),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: toggleWishlist,
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed Add to Cart Button
            if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48, // Reduced from 56
                  child: ElevatedButton(
                    onPressed: () {
                      Cart().addItem(widget.offer);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Item added to cart!",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: EdgeInsets.all(12),
                          action: SnackBarAction(
                            label: "View Cart",
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CartScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Reduced from 16
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13, // Reduced from 14
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13, // Reduced from 14
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoneTypeWithEye() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    "Stone Type",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6),
                GestureDetector(
                  onTap: _showStoneInfo,
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: AppTheme.primaryColor,
                    size: 14, // Reduced from 16
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.offer.stoneType ?? "N/A",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}