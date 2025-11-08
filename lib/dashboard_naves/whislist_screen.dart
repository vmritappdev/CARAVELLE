import 'package:caravelle/dashboard_naves/jewelery_screen.dart';
import 'package:caravelle/model/whishlist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:caravelle/model/offerscreen.dart';
import 'package:caravelle/uittility/app_theme.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Offer> wishlistedItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist(); // ✅ Load data when screen opens
  }

  Future<void> _loadWishlist() async {
    await Wishlist().loadWishlist();
    setState(() {
      wishlistedItems = Wishlist().items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'My Wishlist',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        //centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: wishlistedItems.isEmpty
          ? Center(
              child: Text(
                'Your wishlist is empty',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: wishlistedItems.length,
              itemBuilder: (context, index) {
                final item = wishlistedItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JewelryDetailScreen(offer: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                          child: Image.asset(
                            item.imagePath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Title & Price
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  item.discountedPrice,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite, color: Colors.red),
                          onPressed: () async {
                            Wishlist().toggleItem(item);
                            await _loadWishlist(); // ✅ Refresh after removing/adding
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
