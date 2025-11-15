import 'package:caravelle/model/wishlistitem_model.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';

// --- Sample Wishlist Data (This list is now correctly typed using the imported model) ---
final List<WishlistItem> dummyWishlist = [
  WishlistItem(
    brandName: 'BHRM',
    imageUrl: 'assets/images/cara4.png',
    // Assuming the imported model uses these shorter property names:
    gross: '5.45 gms',
    stone: '1.20 ct',
    net: '4.25 gms',
    tag: '₹18,500',
    isSelected: true,
  ),
  WishlistItem(
    brandName: 'GLAM ROOTS',
    imageUrl: 'assets/images/cara4.png',
    gross: '8.10 gms',
    stone: '2.50 ct',
    net: '5.60 gms',
    tag: '₹45,999',
  ),
  WishlistItem(
    brandName: 'GOSRIKI',
    imageUrl: 'assets/images/cara4.png',
    gross: '3.90 gms',
    stone: '0.80 ct',
    net: '3.10 gms',
    tag: '₹22,150',
  ),
  WishlistItem(
    brandName: 'KVS FAB',
    imageUrl: 'assets/images/cara4.png',
    gross: '12.00 gms',
    stone: '4.00 ct',
    net: '8.00 gms',
    tag: '₹85,000',
  ),
];


class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Now _wishlist is correctly initialized with the imported type
  final List<WishlistItem> _wishlist = List.from(dummyWishlist);

  int get _selectedCount => _wishlist.where((item) => item.isSelected).length;

  void _removeItem(WishlistItem item) {
    setState(() {
      _wishlist.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.brandName} removed from wishlist.')),
    );
  }

  void _toggleSelection(WishlistItem item, bool? value) {
    setState(() {
      item.isSelected = value ?? false;
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

    setState(() {
      _wishlist.removeWhere((item) => item.isSelected);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedItems.length} items moved to Bag!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addToBag(WishlistItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.brandName} added to bag!')),
    );
    _removeItem(item);
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                onPressed: () {},
              ),
              const Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: Colors.red,
                  child: Text('2', style: TextStyle(color: Colors.white, fontSize: 8)),
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GridView.builder(
          itemCount: _wishlist.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.61,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (context, index) {
            final item = _wishlist[index];
            return WishlistProductCard(
              item: item,
              onRemove: () => _removeItem(item),
              onAddToBag: () => _addToBag(item),
              onToggleSelect: (value) => _toggleSelection(item, value),
            );
          },
        ),
      ),

      // Bottom Bar for Bulk Action
      bottomNavigationBar: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedCount > 0 ? _moveSelectedToCart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedCount > 0 ? AppTheme.primaryColor : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 0,
          ),
          child: Text(
            _selectedCount > 0
                ? 'Add $_selectedCount Selected Item(s) to Cart'
                : 'Select Items to Add to Crt',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- 3. Wishlist Product Card (Make sure property names match the model) ---
// --------------------------------------------------------------------------
class WishlistProductCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToBag;
  final Function(bool?) onToggleSelect;

  const WishlistProductCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onAddToBag,
    required this.onToggleSelect,
  });

  // Helper widget to display a single jewelry tag
  Widget _buildJewelryTag(String label, String value, {bool isLarge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Checkbox Overlay
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  child: Image.asset(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: -10,
                  left: -10,
                  child: Checkbox(
  value: item.isSelected,
  onChanged: onToggleSelect,
  activeColor: AppTheme.primaryColor, // check fill color
  checkColor: Colors.white, // tick color
  side: BorderSide(
    color: const Color.fromRGBO(0, 148, 176, 1),  // border color also primary
    width: 2,
  ),
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
)

                ),
              ],
            ),
          ),
          
          // Product Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Name
                Text(
                  item.brandName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
 
                // NEW: Jewelry Tags Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gross Weight (First Line) - Using item.gross (matching provided list)
                    _buildJewelryTag('Gross', item.gross, isLarge: true),
                    // Stone Weight (First Line) - Using item.stone (matching provided list)
                    _buildJewelryTag('Stone ', item.stone, isLarge: true),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Net Weight (Second Line - Small Text) - Using item.net (matching provided list)
                    _buildJewelryTag('Net ', item.net),
                    // Tag Price (Second Line - Small Text) - Using item.tag (matching provided list)
                    _buildJewelryTag('Tag ', item.tag),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Action Buttons Row (Unchanged)
                Row(
                  children: [
                    // Remove Button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: onRemove,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.delete_outline, color: Colors.black, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Add to Bag Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAddToBag,
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          elevation: 0,
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
    );
  }
}