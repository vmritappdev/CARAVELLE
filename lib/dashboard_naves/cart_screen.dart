import 'dart:convert';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String name;
  final String imageUrl;
  final String? options; 
  
  final String grossWeight; 
  final String netWeight;
  final String stoneWeight;

  final String tag; 
  final String id; // This is the unique ID (like client_id/API ID) used for cart removal.
  int quantity;

  CartItem({
    required this.name,
    required this.imageUrl,
    this.options,
    required this.grossWeight,
    required this.netWeight,
    required this.stoneWeight,
    required this.tag,
    required this.id,
    this.quantity = 1,
  });
}

// --------------------------------------------------------------------------
// --- 2. Main Cart Screen Widget with API Fetch Logic ---
// --------------------------------------------------------------------------
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = []; 
  bool isLoading = true; 
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCartItems(); 
  }

  // Helper to safely parse double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Helper function to build a descriptive text
  String _getDisplayText(String? subProduct, String? product, String? design) {
    String text = '';
    if (subProduct != null && subProduct.isNotEmpty) text += subProduct;
    if (product != null && product.isNotEmpty) text += (text.isEmpty ? product : ' - $product');
    if (design != null && design.isNotEmpty) text += (text.isEmpty ? design : ' ($design)');
    return text.isNotEmpty ? text : 'Jewelry Item';
  }

  // 🚀 API Fetching Logic
  Future<void> fetchCartItems() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobile = prefs.getString('mobile_number');

      if (mobile == null || mobile.isEmpty) {
        throw Exception("❌ ERROR: No mobile number found in SharedPreferences");
      }

      print("📱 FETCHING CART - Mobile: $mobile");

      final response = await http.post(
        Uri.parse("${baseUrl}cart_display.php"),
        body: {
          "phone": mobile,
          "token": token,
        },
      );

      print("📊 API RESPONSE STATUS: ${response.statusCode}");
      

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["response"] == "success" && data["total_data"] is List) {
          List<dynamic> list = data["total_data"];

          print("🔄 PROCESSING ${list.length} ITEMS FROM API");

          List<CartItem> fetchedItems = list.map((item) {
            String displayText = _getDisplayText(
              item["sub_product"]?.toString(),
              item["product"]?.toString(),
              item["design"]?.toString(),
            );

            return CartItem(
              id: item["id"]?.toString() ?? UniqueKey().toString(), // API ID is crucial for removal
              name: displayText,
              imageUrl: item["image_url"]?.toString().isNotEmpty == true
                  ? item["image_url"].toString()
                  : "assets/images/cara3.png",
              grossWeight: item["gross"]?.toString() ?? "0.000",
              netWeight: item["net"]?.toString() ?? "0.000",
              stoneWeight: item["stone"]?.toString() ?? "0.000",
              tag: item["barcode"]?.toString() ??
                  item["product_type"]?.toString() ??
                  "N/A",
              quantity: _parseDouble(item["qty"] ?? 1).toInt(),
            );
          }).toList();

          if (mounted) {
            setState(() {
              _cartItems = fetchedItems;
              isLoading = false;
            });
          }

          print("✅ CART LOADED SUCCESSFULLY: ${_cartItems.length} items");

        } else {
          if (mounted) {
            setState(() {
              _cartItems = [];
              isLoading = false;
              errorMessage = data["message"] ?? "Cart is empty or API response failed.";
            });
          }
          print("⚠️ WARNING: API returned no data or failed response");
        }
      } else {
        throw Exception("❌ ERROR: API request failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("❌ EXCEPTION in fetchCartItems(): $e");

      if (mounted) {
        setState(() {
          _cartItems = [];
          isLoading = false;
          errorMessage = "Failed to load cart. Please try again. Error: ${e.toString()}";
        });
      }
    }
  }

  // --- 🌟 సవరించిన addToCart ఫంక్షన్: ఇది CartItem ను తీసుకుంటుంది మరియు API ద్వారా REMOVE చేస్తుంది.
  Future<void> addToCart(CartItem item) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobile = prefs.getString('mobile_number');

      if (mobile == null || mobile.isEmpty) {
        throw Exception("❌ ERROR: No mobile number found in SharedPreferences");
      }
      
      print("🌐 Calling API for Cart REMOVE - Tag: ${item.tag}, ID: ${item.id}");

      final response = await http.post(
        Uri.parse("${baseUrl}cart.php"),
        body: {
          "phone": mobile,
          "barcode": item.tag,
          "id": item.id, 
          "token": token,
          // Quantity parameter can be added here if needed for removal/update
        },
      );

      print("🛒 Raw Cart Response: ${response.body}");

      final data = json.decode(response.body);
      String message = data["message"] ?? "Cart status updated.";
      String snackBarMessage = message;

      // ⭐⭐⭐ API కాల్ తర్వాత స్థానిక జాబితా నుండి అంశాన్ని తొలగించండి ⭐⭐⭐
      if (message.toUpperCase().contains("REMOVED")) {
        setState(() {
          _cartItems.remove(item);
        });
        snackBarMessage = "Item successfully removed from cart!";
      } else if (message.toUpperCase().contains("ADDED")) {
        snackBarMessage = "Item status update failed (API reported 'Added' instead of 'Removed').";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  snackBarMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: snackBarMessage.contains("successfully removed") ? Colors.green : Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("⚠️ Cart API Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove item: $e")),
      );
    }
  }


// --- Quantity and Removal Methods ---

  void _updateQuantity(CartItem item, int change) {
    setState(() {
      final newQuantity = item.quantity + change;
      if (newQuantity >= 1) {
        item.quantity = newQuantity;
        // ⚠️ TODO: Call API here to update quantity on server
      }
    });
  }

// --- 🌟 సవరించిన _removeItem ఫంక్షన్ - API కాల్ చేస్తుంది ---
  void _removeItem(CartItem item) {
    // API ద్వారా రిమూవ్ చేయండి
    addToCart(item);

    // స్థానిక జాబితా నుండి తొలగింపు API కాల్ విజయవంతం అయిన తర్వాత addToCart లో జరుగుతుంది.
  }

// --- Build Method (UI) ---

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
            child: _buildCartBody(),
          ),
        ],
      ),
      
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
            // Left Column (Total Info)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cartItems.isEmpty ? 'Cart is Empty' : '${_cartItems.length} Items in Cart',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const Text(
                  'Continue to Summary',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _cartItems.isEmpty ? null : () {
                    // Handle Checkout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: Colors.grey, 
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

  // ⭐️ Widget to handle Loading, Error, and Content states
  Widget _buildCartBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                "Loading Error: $errorMessage", 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchCartItems,
                child: const Text('Try Again'),
              )
            ],
          ),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 80),
            const SizedBox(height: 10),
            const Text('Your Cart is Empty!', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            // Add buttons for browsing products if necessary
          ],
        ),
      );
    }
    
    return ListView(
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              OutlinedButton(
                onPressed: () {
                  // Handle Change Address
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                child: const Text(
                  'CHANGE',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              )
            ],
          ),
        ),

        const Divider(height: 20, thickness: 1),

        // Order Summary Header
        const Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
          child: Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        // Cart Items List
        ..._cartItems.map((item) => CartItemCard(
              item: item,
              onQuantityChange: _updateQuantity,
              onDelete: _removeItem, // ✅ _removeItem కాల్ అవుతుంది
            )),
      ],
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

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
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
                  // Use Image.network if the URL is an external link, 
                  // otherwise keep Image.asset for local assets
                  child: item.imageUrl.startsWith('assets') 
                      ? Image.asset(item.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, color: Colors.grey);
                          })
                      : Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.link_off, color: Colors.grey);
                          }),
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
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    if (item.options != null && item.options!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.options!,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 8),

                    // **Weight/Jewelry Details**
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Tag:', item.tag, isBold: true),
                          const Divider(height: 8, thickness: 0.5),
                          _buildDetailRow('Gross Weight:', '${item.grossWeight} g'),
                          _buildDetailRow('Net Weight:', '${item.netWeight} g'),
                          _buildDetailRow('Stone Weight:', '${item.stoneWeight} g'),

                        ],
                      ),
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
                              _buildQuantityButton(Icons.remove,
                                  () => onQuantityChange(item, -1)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildQuantityButton(
                                  Icons.add, () => onQuantityChange(item, 1)),
                            ],
                          ),
                        ),

                        // Delete Icon
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 24),
                          onPressed: () => onDelete(item), // ✅ onDelete కాల్ అవుతుంది
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 1, indent: 106),
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