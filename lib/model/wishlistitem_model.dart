class WishlistItem {
  final String brandName;
  
  final String imageUrl;
  final String gross; // NEW: Gross Weight (e.g., "5.45 gms")
  final String stone; // NEW: Stone Weight (e.g., "1.20 ct")
  final String net; // NEW: Net Weight (e.g., "4.25 gms")
  final String tag; // NEW: Tag Price (e.g., "₹18,500")
  bool isSelected;

  WishlistItem({
    required this.brandName,
    
    required this.imageUrl,
    required this.gross,
    required this.stone,
    required this.net,
    required this.tag,
    this.isSelected = false,
  });
}