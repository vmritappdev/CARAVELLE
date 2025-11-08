import 'package:caravelle/dashboard_naves/cart_screen.dart';
import 'package:caravelle/dashboard_naves/fullscreenimage.dart';
import 'package:caravelle/model/cart.dart';
import 'package:caravelle/model/offerscreen.dart';
import 'package:caravelle/model/whishlist.dart';
import 'package:caravelle/screens/custmaization_screen.dart' hide CartScreen;
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class JewelryDetailScreen extends StatefulWidget {
  final Offer offer;

  const JewelryDetailScreen({super.key, required this.offer});

  @override
  State<JewelryDetailScreen> createState() => _JewelryDetailScreenState();
}

class _JewelryDetailScreenState extends State<JewelryDetailScreen> {
  bool isWishlisted = false;
  bool _isSpecificationsExpanded = true; // ✅ Default open

  @override
  void initState() {
    super.initState();
    isWishlisted = Wishlist().contains(widget.offer);
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
        title: Text("Stone Type Information"),
        content: Text(
          "This jewelry features ${widget.offer.stoneType ?? 'precious stones'}. "
          "The stones are carefully selected for their quality, brilliance, and durability.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
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
            // 🧾 Scrollable content
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60), // space for top bar
                    // Product Image
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(
                                imagePath: widget.offer.imagePath),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(widget.offer.imagePath),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    // Product Info
                    Text(
                      widget.offer.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (widget.offer.originalPrice.isNotEmpty)
                          Text(
                            widget.offer.originalPrice,
                            style: GoogleFonts.inter(
                              color: Color(0xFFA0AEC0),
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        SizedBox(width: 8),
                        Text(
                          widget.offer.discountedPrice.isNotEmpty
                              ? widget.offer.discountedPrice
                              : widget.offer.originalPrice,
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),
                    // Product Specifications (Default Open)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSpecificationsExpanded =
                                    !_isSpecificationsExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Product Specifications",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                Icon(
                                  _isSpecificationsExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          if (_isSpecificationsExpanded) ...[
                            SizedBox(height: 12),
                            _buildSpecificationRow("Gross Weight",
                                "${widget.offer.grossWeight ?? "N/A"} grams"),
                            _buildStoneTypeWithEye(),
                            _buildSpecificationRow("Net Weight",
                                "${widget.offer.netWeight ?? "N/A"} grams"),
                            _buildSpecificationRow(
                                "Pure", widget.offer.pureSize ?? "24K"),
                            _buildSpecificationRow(
                                "Size", widget.offer.size ?? "Standard"),
                            _buildSpecificationRow("Length",
                                "${widget.offer.length ?? "N/A"} inches"),
                            _buildSpecificationRow("Pieces",
                                "${widget.offer.pieces ?? "1"} piece"),
                            _buildSpecificationRow(
                                "Product Name", widget.offer.title),
                            _buildSpecificationRow("Sub Product",
                                widget.offer.subProductName ?? "Premium Jewelry"),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    // Customize Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(16),
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Customize This Design",
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔝 Fixed Custom AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
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
                        icon: Icon(Icons.arrow_back,
                            color: AppTheme.primaryColor, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Product Details",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartScreen()),
                        );
                      },
                      child: Icon(Icons.shopping_cart_outlined,
                          color: Colors.black, size: 22),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: toggleWishlist,
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isWishlisted
                            ? Colors.red
                            : AppTheme.primaryColor,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🛒 Fixed Add to Cart Button (Always Visible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
onPressed: () {
  Cart().addItem(widget.offer);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Item added successfully!",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(16),
      action: SnackBarAction(
        label: "Go to Cart",
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoneTypeWithEye() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Stone Type",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _showStoneInfo,
                child: Icon(
                  Icons.remove_red_eye_outlined,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
          Text(
            widget.offer.stoneType ?? "N/A",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
