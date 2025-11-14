import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductGalleryWidget extends StatefulWidget {
  const ProductGalleryWidget({Key? key}) : super(key: key);

  @override
  State<ProductGalleryWidget> createState() => _ProductGalleryWidgetState();
}

class _ProductGalleryWidgetState extends State<ProductGalleryWidget> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
  final url = Uri.parse('$baseUrl/catalogue_products.php');
  
  try {
    print("🔹 API CALL STARTED");
    print("🌐 URL: $url");
    print("📦 BODY: { token: $token }");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'token': token},
    );

    print("📩 STATUS CODE: ${response.statusCode}");
    print("📜 RAW RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ DECODED DATA: $data");

      if (data is Map<String, dynamic> && data.containsKey('total_data')) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(data['total_data']);
          _isLoading = false;
        });
        print("🟢 PRODUCTS FETCHED: ${_products.length}");
      } else {
        print("⚠️ total_data key not found in response");
        setState(() => _isLoading = false);
      }
    } else {
      print("❌ API FAILED with Status Code: ${response.statusCode}");
      setState(() => _isLoading = false);
    }
  } catch (e) {
    print("🔥 ERROR while fetching products: $e");
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Images Row inside single container
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _products.take(7).map((product) {
                  final productName = product['product']?.toString().trim() ?? '';
                  final subProduct = product['sub_product']?.toString().trim() ?? '';
                  final design = product['design']?.toString().trim() ?? '';
                  final imageUrl = product['image_url']?.toString() ?? '';

                  // Logic for text
                  String nameText =
                      (subProduct.isEmpty || subProduct.toLowerCase() == "null")
                          ? productName
                          : subProduct;
                  String designText = (design.isNotEmpty && design.toLowerCase() != "null")
                      ? " ($design)"
                      : "";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 30),
                                )
                              : Container(
                                  height: 60,
                                  width: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, size: 30),
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$nameText$designText".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // 🔹 View Catalogue Button
            Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor,
                    //  blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "View Catalogue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
             
          ],
        ),
      ),
    );
  }
}
