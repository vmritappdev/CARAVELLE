import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';

// --- 1. Data Model for Cart Item ---
class CartItem {
  final String name;
  final String imageUrl; // Asset image path
  final String? options; // e.g., "Select Planter: Kyoto, Color: Mocca"
  final double oldPrice;
  final double currentPrice;
  int quantity;

  CartItem({
    required this.name,
    required this.imageUrl,
    this.options,
    required this.oldPrice,
    required this.currentPrice,
    this.quantity = 1,
  });
}

// --- Sample Cart Data ---
final List<CartItem> dummyCart = [
  CartItem(
    name: 'Indoor Plant Combo with Gropot - Stylish & Easy Ca...',
    imageUrl: 'assets/images/cara4.png', // Replace with your image path
    oldPrice: 1199,
    currentPrice: 699,
  ),
  CartItem(
    name: 'Snake Plant - Golden Hahnii',
    imageUrl: 'assets/images/cara4.png', // Replace with your image path
    options: 'Select Planter: Kyoto, Color: Mocca',
    oldPrice: 599,
    currentPrice: 349,
  ),
];

// --------------------------------------------------------------------------
// --- 2. Main Cart Screen Widget ---
// --------------------------------------------------------------------------
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _cartItems = dummyCart;

  double get _totalAmount {
    return _cartItems.fold(
        0.0, (sum, item) => sum + (item.currentPrice * item.quantity));
  }

  void _updateQuantity(CartItem item, int change) {
    setState(() {
      final newQuantity = item.quantity + change;
      if (newQuantity >= 1) {
        item.quantity = newQuantity;
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} removed from cart.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Cart', style: TextStyle(color: Colors.black)),
        centerTitle: false,
       
      ),
      
      body: Column(
        children: [
          // Top Banner (Guaranteed Replacement)
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '14 days guaranteed replacement, if damaged',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10),
              children: [
                // Delivery Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Deliver to: ',
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        'Sai Surya,',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          // Handle Change address
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                        ),
                        child: const Text('CHANGE', style: TextStyle(color: Colors.black, fontSize: 12)),
                      )
                    ],
                  ),
                ),

                const Divider(height: 20, thickness: 1),

                // Order Summary Header
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Cart Items List
                ..._cartItems.map((item) => CartItemCard(
                      item: item,
                      onQuantityChange: _updateQuantity,
                      onDelete: _removeItem,
                    )),

                // Apply Coupon Section
               
              ],
            ),
          ),
        ],
      ),
      
      // Fixed Bottom Navigation Bar (Checkout)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
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
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${_totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Incl. of all taxes',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Checkout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('CHECKOUT',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- 3. Custom Cart Item Card Widget ---
// --------------------------------------------------------------------------
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(CartItem, int) onQuantityChange;
  final Function(CartItem) onDelete;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.grey);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details and Actions Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                if (item.options != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.options!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 8),

                // Price Section
                Row(
                  children: [
                    Text(
                      '₹${item.oldPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${item.currentPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quantity Selector and Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityButton(Icons.remove, () => onQuantityChange(item, -1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildQuantityButton(Icons.add, () => onQuantityChange(item, 1)),
                        ],
                      ),
                    ),

                    // Delete Icon
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                      onPressed: () => onDelete(item),
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

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// --- 4. Coupon Selector Widget ---
// --------------------------------------------------------------------------
class CouponSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text(
                  'Select Coupon',
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade700),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'OR',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}