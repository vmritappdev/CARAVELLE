class JewelleryItem {
  final int id;
  final String name;
  final String grossPrice;
  final String netPrice;
  final String stone;
  final String purity;
  final String tag;
  final String imageAsset;
  bool isSelected;

  JewelleryItem({
    required this.id,
    required this.name,
    required this.grossPrice,
    required this.netPrice,
    required this.stone,
    required this.purity,
    required this.tag,
    required this.imageAsset,
    required this.isSelected,
  });
}