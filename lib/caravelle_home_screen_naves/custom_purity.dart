import 'package:flutter/material.dart';

class PuritySelector extends StatefulWidget {
  @override
  _PuritySelectorState createState() => _PuritySelectorState();
}

class _PuritySelectorState extends State<PuritySelector> {
  final List<String> _goldOptions = ['9K', '14K', '18K', '22K'];
  String? _selectedGold;
  String? _selectedCategory = 'Gold'; // Example: 'CZ' or 'Gold' or 'Silver'

  Widget _buildSelectableBox(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade400,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 👇 CZ select అయిందా అని చెక్
    bool isCZ = _selectedCategory == 'CZ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),

        // 🟡 Purity options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _goldOptions.map((option) {
            bool isEnabled = !isCZ || option == '18K'; // CZ అయితే 18K మాత్రమే enable

            return Opacity(
              opacity: isEnabled ? 1.0 : 0.3, // Dim non-enabled
              child: IgnorePointer(
                ignoring: !isEnabled, // Disable taps for others
                child: _buildSelectableBox(
                  option,
                  _selectedGold == option,
                  () {
                    setState(() => _selectedGold = option);
                  },
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 20),
        // 🔘 Demo toggle for category
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Selected Category: "),
            DropdownButton<String>(
              value: _selectedCategory,
              items: ['Gold', 'CZ', 'Silver']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                  // CZ select చేస్తే auto 18K select అవుతుంది
                  if (_selectedCategory == 'CZ') {
                    _selectedGold = '18K';
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
