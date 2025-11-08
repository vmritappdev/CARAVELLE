class Product {
  final String id;
  final String name;          // product
  final String subProduct;    // sub_product
  final String design;        // design
  final String image;         // image_url
  final double grossWeight;   // gross
  final double netWeight;     // net
  final int stoneCount;       // stone
 // final double stoneWeight;   // stone_weight (new)
  final String tagno;         // old_tag
  final double amount; 
  final String status; 
  final int wight;            

  // Optional old fields
  final double price;
  final String category;
  final String description;
  final bool isNew;
  final bool isFeatured;
  final String productCode;

  Product({
    required this.id,
    required this.name,
    required this.subProduct,
    required this.design,
    required this.image,
    required this.grossWeight,
    required this.netWeight,
    required this.stoneCount,
   // required this.stoneWeight, // ✅ added
    required this.tagno,
    required this.wight,
    required this.amount,
    required this.status,
    this.price = 0,
    this.category = '',
    this.description = '',
    this.isNew = false,
    this.isFeatured = false,
    this.productCode = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['product'] ?? '').toString(),
      subProduct: (json['sub_product'] ?? '').toString(),
      design: (json['design'] ?? '').toString(),
      image: (json['image_url'] ?? '').toString(),
      grossWeight: double.tryParse((json['gross'] ?? '0').toString()) ?? 0,
      netWeight: double.tryParse((json['net'] ?? '0').toString()) ?? 0,
      stoneCount: double.tryParse((json['stone'] ?? '0').toString())?.round() ?? 0,
     // stoneWeight: double.tryParse((json['stone_weight'] ?? '0').toString()) ?? 0, // ✅ new
      wight: double.tryParse((json['other_wt'] ?? '0').toString())?.round() ?? 0,
      tagno: (json['old_tag'] ?? '').toString(),
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0,
      status: (json['status'] ?? 'ACTIVE').toString(),
    );
  }
}
