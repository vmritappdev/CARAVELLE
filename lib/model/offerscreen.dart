class Offer {
  final String imagePath;
  final String title;
  final String originalPrice;
  final String discountedPrice;
  final String description;
  final String? grossWeight;
  final String? netWeight;
  final String? size;
  
 final String? status;
final String? subproduct;

 String? whish;
 String? cart;
  // New fields for jewelry details
  final String? tagNumber;
  final String? stoneType;
  final String? pureSize;
  final String? length;
  final String? pieces;
  
  final String? subProductName;

  Offer({
    required this.imagePath,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.description,
     this.whish,
     this.cart,
    
    this.grossWeight,
    this.netWeight,
    this.size,
    this.status,
    // New fields
    this.tagNumber,
    this.stoneType,
    this.pureSize,
    this.length,
    this.pieces,
    this.subProductName,
    this.subproduct,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'imagePath': imagePath,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'description': description,
        
        'grossWeight': grossWeight,
        'netWeight': netWeight,
        'size': size,
        // New fields in JSON
        'tagNumber': tagNumber,
        'stoneType': stoneType,
        'pureSize': pureSize,
        'length': length,
        'pieces': pieces,
        'subProductName': subProductName,
      };

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        title: json['title'],
        imagePath: json['imagePath'],
        originalPrice: json['originalPrice'],
        discountedPrice: json['discountedPrice'],

        whish: (json['whislist'] ?? "").toString().toUpperCase(),
        cart: (json['cart'] ?? "").toString().toUpperCase(),
        
        description: json['description'],
        grossWeight: json['grossWeight'],
        netWeight: json['netWeight'],
        size: json['size'],
        // New fields from JSON
        tagNumber: json['tagNumber'],
        stoneType: json['stoneType'],
        pureSize: json['pureSize'],
        length: json['length'],
        pieces: json['pieces'],
        subProductName: json['subProductName'],
      );
}