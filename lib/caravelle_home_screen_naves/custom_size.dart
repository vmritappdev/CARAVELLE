import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  @override
  _SizeSelectorState createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  final List<String> _sizeOptions = [
    '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17'
  ];

  String? _selectedSize;
  bool _isCustomSelected = false;
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _customSizeController = TextEditingController();

  Widget _buildSelectableBox(String size, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.teal : Colors.grey),
        ),
        child: Text(
          size,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._sizeOptions.map((size) {
              return _buildSelectableBox(size, _selectedSize == size, () {
                setState(() {
                  _selectedSize = size;
                  _isCustomSelected = false;
                  _sizeController.text = size;
                });
              });
            }).toList(),
            _buildSelectableBox('Custom', _isCustomSelected, () {
              setState(() {
                _isCustomSelected = true;
                _selectedSize = null;
                _sizeController.clear();
              });
            }),
          ],
        ),
        if (_isCustomSelected) ...[
          SizedBox(height: 10),
          TextField(
            controller: _customSizeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter custom size',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (value) {
              _sizeController.text = value;
            },
          ),
        ],
      ],
    );
  }
}
