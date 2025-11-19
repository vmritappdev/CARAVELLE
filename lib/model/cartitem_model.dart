class CartItem {
  final String name;
  final String imageUrl;
  final String? options;

  final String grossWeight;   // API value as String
  final String netWeight;
  final String stoneWeight;

  final String tag;
  final String id;
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
