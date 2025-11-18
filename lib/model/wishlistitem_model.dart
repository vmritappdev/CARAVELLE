// In your wishlistitem_model.dart
class WishlistItem {
  final String brandName;
  final String imageUrl;
  final String gross;
  final String net;
  final String stone;
  final String tag;
  bool isSelected;
  final String? product;
  final String? subProduct;
  final String? design;
  String? displayText;

  WishlistItem({
    required this.brandName,
    required this.imageUrl,
    required this.gross,
    required this.net,
    required this.stone,
    required this.tag,
    required this.isSelected,
    this.product,
    this.subProduct,
    this.design,
    this.displayText,
  });
}