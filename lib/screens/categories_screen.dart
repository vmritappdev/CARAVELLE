
import 'package:caravelle/dashboard_naves/goldshop_offer.dart';

import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoriesScreen extends StatefulWidget {
const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, String>> mainCategories = [
    {'name': 'Chains', 'icon': 'assets/images/cara3.png'},
    {'name': 'Rings', 'icon': 'assets/images/cara4.png'},
    {'name': 'Bracelets', 'icon': 'assets/images/cara2.png'},
    {'name': 'Bangles', 'icon': 'assets/images/bangle.png'},
    {'name': 'Necklace', 'icon': 'assets/images/cara3.png'},
    {'name': 'Nose Pin', 'icon': 'assets/images/cara4.png'},
    {'name': 'Earrings', 'icon': 'assets/images/cara3.png'},
  ];

  // CHANGED SUBCATEGORIES - CZ JEWELRY, PLAIN JEWELRY, LAB DIAMOND JEWELRY
  final Map<String, List<String>> subCategories = {
    'Chains': ['All', 'CZ Jewelry', 'Plain Jewelry', 'Lab Diamond Jewelry'],
    'Rings': ['All', 'CZ Jewelry', 'Plain Jewelry', 'Lab Diamond Jewelry'],
    'Bracelets': ['All', 'CZ Jewelry', 'Plain Jewelry', 'Lab Diamond Jewelry'],
    'Bangles': ['All', 'CZ Jewelry', 'Plain Jewelry', 'Lab Diamond Jewelry'],
    'Necklace': ['All', 'CZ Jewelry', 'Plain Jewelry', 'Lab Diamond Jewelry'],
    'Nose Pin': ['All', 'CZ Jewelry', 'Plain Jewelry', 'Lab Diamond Jewelry'],
    'Earrings': ['All', 'CZ Jewelry', 'Plain Jewelry', 'Lab Diamond Jewelry'],
  };

  // PRODUCT NAMES FOR NEW CATEGORIES - 20 ITEMS EACH
  final Map<String, List<String>> productNames = {
    'CZ Jewelry': [
      'CZ Gold Chain', 'CZ Diamond Chain', 'CZ Platinum Chain', 'CZ Silver Chain',
      'CZ Gold Ring', 'CZ Diamond Ring', 'CZ Platinum Ring', 'CZ Silver Ring',
      'CZ Gold Bracelet', 'CZ Diamond Bracelet', 'CZ Platinum Bracelet', 'CZ Silver Bracelet',
      'CZ Gold Bangle', 'CZ Diamond Bangle', 'CZ Platinum Bangle', 'CZ Silver Bangle',
      'CZ Gold Necklace', 'CZ Diamond Necklace', 'CZ Platinum Necklace', 'CZ Silver Necklace'
    ],
    'Plain Jewelry': [
      'Plain Gold Chain', 'Plain Silver Chain', 'Plain Platinum Chain', 'Simple Gold Chain',
      'Plain Gold Ring', 'Plain Silver Ring', 'Plain Platinum Ring', 'Simple Gold Ring',
      'Plain Gold Bracelet', 'Plain Silver Bracelet', 'Plain Platinum Bracelet', 'Simple Gold Bracelet',
      'Plain Gold Bangle', 'Plain Silver Bangle', 'Plain Platinum Bangle', 'Simple Gold Bangle',
      'Plain Gold Necklace', 'Plain Silver Necklace', 'Plain Platinum Necklace', 'Simple Gold Necklace'
    ],
    'Lab Diamond Jewelry': [
      'Lab Diamond Gold Chain', 'Lab Diamond Silver Chain', 'Lab Diamond Platinum Chain', 'Lab Diamond Rope Chain',
      'Lab Diamond Gold Ring', 'Lab Diamond Silver Ring', 'Lab Diamond Platinum Ring', 'Lab Diamond Solitaire',
      'Lab Diamond Gold Bracelet', 'Lab Diamond Silver Bracelet', 'Lab Diamond Platinum Bracelet', 'Lab Diamond Tennis',
      'Lab Diamond Gold Bangle', 'Lab Diamond Silver Bangle', 'Lab Diamond Platinum Bangle', 'Lab Diamond Stackable',
      'Lab Diamond Gold Necklace', 'Lab Diamond Silver Necklace', 'Lab Diamond Platinum Necklace', 'Lab Diamond Pendant'
    ],
  };

  String selectedCategory = 'Chains';
  String selectedSubCategory = 'All';
  bool isLoading = false;

  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  Future<void> loadCategory(String category) async {
    setState(() {
      isLoading = true;
      selectedCategory = category;
      selectedSubCategory = 'All';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: !isSearching
            ?  Text(
                "All Categories",
                style: TextStyle(fontWeight: FontWeight.bold, color:AppTheme.primaryColor,fontSize: 18.sp),
              )
            : TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search categories...",
                  hintStyle: TextStyle(color: AppTheme.primaryColor),
                  border: InputBorder.none,
                ),
                style:  TextStyle(color: Colors.black, fontSize: 16.sp),
                onChanged: (value) {},
              ),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: AppTheme.primaryColor),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchController.clear();
                });
              },
            ),
        ],
      ),

      body: Row(
        children: [
          // LEFT SIDE MENU
          Container(
            width: 100.w,
            color: const Color.fromARGB(255, 235, 232, 232),
            child: ListView.builder(
              itemCount: mainCategories.length,
              itemBuilder: (context, index) {
                final category = mainCategories[index]['name']!;
                final icon = mainCategories[index]['icon']!;
                final isSelected = category == selectedCategory;
                return GestureDetector(
                  onTap: () => loadCategory(category),
                  child: Container(
                    color: isSelected ? Colors.white : Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(icon, fit: BoxFit.contain),
                          ),
                        ),
                         SizedBox(height: 6.h),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade800,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // RIGHT SIDE CONTENT
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SUBCATEGORIES HORIZONTAL SCROLL - NEW CATEGORIES
                        SizedBox(
                          height: 45.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: subCategories[selectedCategory]!.length,
                            itemBuilder: (context, index) {
                              final sub = subCategories[selectedCategory]![index];
                              final isSelected = sub == selectedSubCategory;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSubCategory = sub;
                                  });
                                },
                                child: Container(
                                  margin:  EdgeInsets.only(right: 10.r),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sub,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                         SizedBox(height: 20.h),

                        // WHITE BOXES WITH 20 ITEMS - NEW CATEGORIES
                        _buildWhiteBoxesGrid(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // WHITE BOXES WITH 20 ITEMS - NEW CATEGORIES
  Widget _buildWhiteBoxesGrid() {
    List<String> productsToShow = [];
    
    if (selectedSubCategory == 'All') {
      // Show 20 products from all new subcategories
      for (var sub in subCategories[selectedCategory]!) {
        if (sub != 'All' && productNames.containsKey(sub)) {
          productsToShow.addAll(productNames[sub]!);
        }
      }
      productsToShow = productsToShow.take(20).toList();
    } else {
      // Show 20 products from selected new subcategory
      productsToShow = (productNames[selectedSubCategory] ?? []).take(20).toList();
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns for smaller boxes
        childAspectRatio: 1.0, // Square boxes
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: productsToShow.length,
      itemBuilder: (context, index) {
        final productName = productsToShow[index];
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoldShopOffersScreen(subProducts: '',fetchApiType: '',),
              ),
            );
          },
          child: Container(
            // WHITE BOX - SMALL SIZE
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  productName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11, // Smaller font for small boxes
                    color: Colors.black,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}