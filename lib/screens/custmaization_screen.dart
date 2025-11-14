import 'dart:io';
import 'package:caravelle/caravelle_home_screen_naves/custom_size.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

// --- Theme Colors ---
const Color _kPrimaryColor = AppTheme.primaryColor;
const Color _kAccentColor = Color(0xFF4DB6AC);
const Color _kBackgroundColor = Colors.white;
const Color _kTextColor = Colors.black87;
const Color _kHintColor = Colors.grey;

class CustomizationScreen extends StatefulWidget {
  final String? initialImagePath;

  const CustomizationScreen({super.key, this.initialImagePath});

  @override
  _CustomizationScreenState createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final _lengthController = TextEditingController();
  final _clarityController = TextEditingController();
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _remarksController = TextEditingController();
  final _quantityController = TextEditingController();

  String _selectedGold = '';
  String _selectedCategory = '';
  String _selectedGoldColor = '';
  String _selectedCertification = '';
  String _selectedStone = '';
  String _selectedClarity = '';
  String _selectedColor = '';

  final List<String> _goldOptions = ['9K', '14K', '18K', '22K'];
  final List<String> _categoryOptions = ['CZ', 'Plain', 'Lab diamond'];
  
  final List<Map<String, dynamic>> _goldColorOptions = [
    {'name': 'Yellow', 'color': Colors.yellow, 'icon': Icons.lens},
    {'name': 'Rose', 'color': Color(0xFFFFC0CB), 'icon': Icons.lens},
    {'name': 'White', 'color': Colors.white, 'icon': Icons.lens},
    {'name': 'Y+W', 'color': null, 'icon': Icons.brightness_1, 'isMixed': true, 'colors': [Colors.yellow, Colors.white]},
    {'name': 'R+W', 'color': null, 'icon': Icons.brightness_1, 'isMixed': true, 'colors': [Color(0xFFFFC0CB), Colors.white]},
    {'name': 'Y+R', 'color': null, 'icon': Icons.brightness_1, 'isMixed': true, 'colors': [Colors.yellow, Color(0xFFFFC0CB)]},
  ];

  final List<String> _clarityOptions = ['VVS-VS', 'VVS1', 'VVS2', 'VS1', 'VS2'];
  final List<String> _colorOptions = ['D', 'E', 'F'];

  // Validation flags - ONLY FOR 3 FIELDS
  bool _showCategoryError = false;
  bool _showPurityError = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _image = XFile(widget.initialImagePath!);
    }
  }

  // --- Pick image ---
  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source', style: TextStyle(color: _kPrimaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: _kPrimaryColor),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: _kPrimaryColor),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- TextField Helper with Red Star ---
  Widget _buildTextField(
  TextEditingController controller,
  String labelText, {
  TextInputType keyboardType = TextInputType.text,
  bool required = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🖤 Label text (black)
        if (required)
          RichText(
            text: TextSpan(
              text: labelText,
              style: const TextStyle(
                color: Colors.black, // ✅ label text black
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            labelText,
            style: const TextStyle(
              color: Colors.black, // ✅ black label text
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 6),

        // ✏️ Normal text field (unchanged background)
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black), // text inside field
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.teal,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.grey.shade50, // keep default light field
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    ),
  );
}


  // --- Validate ONLY 3 Fields ---
 // --- Validate ONLY 3 Fields ---
bool _validateFields() {
  bool isValid = true;
  
  setState(() {
    _showCategoryError = false; // ❌ Boxes red color vaddu
    _showPurityError = false;   // ❌ Boxes red color vaddu
// ❌ Boxes red color vaddu
  });

  if (_selectedCategory.isEmpty || _selectedGold.isEmpty || _quantityController.text.isEmpty) {
    isValid = false;
    
    // ✅ Snack bar message matrame chalu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill all required fields'),
        backgroundColor: Colors.red,
      ),
    );
  }

  return isValid;
}

  // --- Place Custom Order ---
  void _placeOrder() {
    if (_validateFields()) {
      print('Order placed successfully!');
      // Add your order placement logic here
    }
  }

  bool _isAssetImage(String path) {
    return !path.contains('/') || path.startsWith('assets/');
  }

  // Helper method for required label with red star
  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w600,
          color: _kTextColor,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: _kBackgroundColor,
        appBar: AppBar(
          backgroundColor: _kPrimaryColor,
          elevation: 4,
          title: Text(
            'Custom Jewelry Order',
            style: TextStyle(color: _kBackgroundColor, fontWeight: FontWeight.w700, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: _kBackgroundColor),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upload Design Section - OPTIONAL (No red star)
              Text('Upload Design/Inspiration (Optional)',
                  style: TextStyle(color: _kTextColor, fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: const Color.fromARGB(255, 231, 239, 239), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: _kAccentColor),
                            SizedBox(height: 8),
                            Text('Tap to Select from Camera or Gallery',
                                style: TextStyle(color: _kHintColor)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _isAssetImage(_image!.path)
                              ? Image.asset(_image!.path, fit: BoxFit.cover)
                              : Image.file(File(_image!.path), fit: BoxFit.cover),
                        ),
                ),
              ),

              // Category selection - REQUIRED
              SizedBox(height: 24),
              _buildRequiredLabel('Type Of Jewellery'),
           
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _categoryOptions.map((category) {
                  return _buildCategoryBox(
                    category, 
                    _selectedCategory == category, 
                    _showCategoryError,
                    () {
                      setState(() {
                        _selectedCategory = category;
                        _showCategoryError = false;
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              // Gold Purity selection - REQUIRED
              _buildRequiredLabel('Purity'),
             
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _goldOptions.map((option) {
                  bool isLimitedCategory = _selectedCategory == 'CZ' || _selectedCategory == 'Plain';
                  bool isEnabled = !isLimitedCategory || option == '18K';
                  return Opacity(
                    opacity: isEnabled ? 1.0 : 0.3,
                    child: IgnorePointer(
                      ignoring: !isEnabled,
                      child: _buildSelectableBox(
                        option,
                        _selectedGold == option,
                        _showPurityError,
                        () {
                          setState(() {
                            _selectedGold = option;
                            _showPurityError = false;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              // Size Selection - OPTIONAL
             
              SizeSelector(),
              SizedBox(height: 24.h),
              _buildTextField(_sizeController, 'Custom Size (optional)'),
              SizedBox(height: 15.h),

              // Gold Color selection - OPTIONAL
              Text('Select Gold Color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              // First row - 3 boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _goldColorOptions.sublist(0, 3).map((colorOption) {
                  bool is22KSelected = _selectedGold == '22K';
                  bool isYellowColor = colorOption['name'] == 'Yellow';
                  bool isEnabled = !is22KSelected || isYellowColor;
                  return Opacity(
                    opacity: isEnabled ? 1.0 : 0.3,
                    child: IgnorePointer(
                      ignoring: !isEnabled,
                      child: _buildGoldColorBox(
                        colorOption['name'],
                        _selectedGoldColor == colorOption['name'],
                        colorOption['color'],
                        colorOption['icon'],
                        colorOption['isMixed'] ?? false,
                        colorOption['colors'],
                        () {
                          setState(() => _selectedGoldColor = colorOption['name']);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 12),
              // Second row - 3 boxes  
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _goldColorOptions.sublist(3).map((colorOption) {
                  bool is22KSelected = _selectedGold == '22K';
                  bool isYellowColor = colorOption['name'] == 'Yellow';
                  bool isEnabled = !is22KSelected || isYellowColor;
                  return Opacity(
                    opacity: isEnabled ? 1.0 : 0.3,
                    child: IgnorePointer(
                      ignoring: !isEnabled,
                      child: _buildGoldColorBox(
                        colorOption['name'],
                        _selectedGoldColor == colorOption['name'],
                        colorOption['color'],
                        colorOption['icon'],
                        colorOption['isMixed'] ?? false,
                        colorOption['colors'],
                        () {
                          setState(() => _selectedGoldColor = colorOption['name']);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Lab diamond specific sections - OPTIONAL
              if (_selectedCategory == 'Lab diamond') ...[
                SizedBox(height: 20),
                Text('Select Clarity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _clarityOptions.map((clarity) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedClarity = clarity),
                      child: Container(
                        width: 80,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedClarity == clarity ? _kPrimaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedClarity == clarity ? _kPrimaryColor : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(clarity, style: TextStyle(
                            color: _selectedClarity == clarity ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 25),
                Text('Stone Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 80,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedColor == color ? _kPrimaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedColor == color ? _kPrimaryColor : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(color, style: TextStyle(
                            color: _selectedColor == color ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 25),
                Text('Certification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['IGL', 'SGL'].map((cert) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCertification = cert),
                      child: Container(
                        width: 100,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedCertification == cert ? _kPrimaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedCertification == cert ? _kPrimaryColor : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(cert, style: TextStyle(
                            color: _selectedCertification == cert ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 25),
                Text('Color Stone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['Gem', 'Labdaimand'].map((stone) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStone = stone),
                      child: Container(
                        width: 120,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedStone == stone ? _kPrimaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedStone == stone ? _kPrimaryColor : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(stone, style: TextStyle(
                            color: _selectedStone == stone ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),
                _buildTextField(_clarityController, 'Caract'),
              ],

              // COMMON FIELDS - Only Quantity is REQUIRED
              SizedBox(height: 20),
              _buildTextField(_lengthController, 'Length (e.g., 18 cm)',),
              _buildTextField(_weightController, 'Desired Weight (e.g., 5.2g)'),
             _buildTextField(_quantityController, 'Quantity', 
  keyboardType: TextInputType.number, required: true),

              _buildTextField(_remarksController, 'Special Remarks (Stones, Engraving, etc.)'),
              
              // Order Button
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_validateFields()) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          title: Row(
                            children: [
                              Icon(Icons.help_outline, color: _kPrimaryColor, size: 24),
                              SizedBox(width: 10),
                              Text("Confirm Order", style: TextStyle(color: _kTextColor, fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          ),
                          content: Text("Are you sure you want to place this custom order?", style: TextStyle(color: _kHintColor, fontSize: 16)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(foregroundColor: Colors.grey),
                              child: Text("NO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                                      child: Padding(
                                        padding: EdgeInsets.all(30),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 80, height: 80,
                                              decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                                              child: Icon(Icons.check, color: Colors.green, size: 40),
                                            ),
                                            SizedBox(height: 20),
                                            Text("Your Order Confirmed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kTextColor)),
                                            SizedBox(height: 15),
                                            Text("Your custom jewelry order has been successfully placed.", style: TextStyle(fontSize: 16, color: _kHintColor)),
                                            SizedBox(height: 25),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _placeOrder();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _kPrimaryColor,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: _kPrimaryColor, foregroundColor: Colors.white),
                              child: Text("YES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryColor,
                  foregroundColor: _kBackgroundColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
                child: Text('PLACE CUSTOM ORDER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated methods with error highlighting
  Widget _buildCategoryBox(String text, bool selected, bool showError, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _kPrimaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: showError ? Colors.red : (selected ? _kPrimaryColor : Colors.grey.shade300),
            width: showError ? 2.0 : 2.0,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableBox(String text, bool selected, bool showError, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _kPrimaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: showError ? Colors.red : (selected ? _kPrimaryColor : Colors.grey.shade300),
            width: showError ? 2.0 : 1.5,
          ),
        ),
        child: Center(
          child: Text(text, style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          )),
        ),
      ),
    );
  }

  // Gold color box method (same as before)
  Widget _buildGoldColorBox(String text, bool selected, Color? color, IconData icon, bool isMixed, List<Color>? mixedColors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? _kPrimaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _kPrimaryColor : Colors.grey.shade300, width: 2.0),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMixed && mixedColors != null)
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: mixedColors, stops: [0.5, 0.5], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
              )
            else
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color == Colors.white ? Colors.grey.shade400 : Colors.transparent, width: 1),
                ),
                child: color == Colors.white ? Icon(Icons.lens, color: Colors.grey.shade300, size: 0) : null,
              ),
            SizedBox(height: 8),
            Text(text, style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            )),
          ],
        ),
      ),
    );
  }
}