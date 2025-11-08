import 'package:caravelle/dashboard_naves/accountscreen.dart';
import 'package:caravelle/dashboard_naves/cart_screen.dart';
import 'package:caravelle/dashboard_naves/goldshop_offer.dart';
import 'package:caravelle/dashboard_naves/whislist_screen.dart';
import 'package:caravelle/screens/dashboard.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';



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
  ];

  final Map<String, List<String>> subCategories = {
    'Chains': ['All', 'Gold Chains', 'Silver Chains', 'Platinum Chains'],
    'Rings': ['All', 'Ladies Rings', 'Mens Rings', 'Children Rings'],
    'Bracelets': ['All', 'Mens Bracelets', 'Ladies Bracelets'],
    'Bangles': ['All', 'Ladies Bangles', 'Kids Bangles'],
    'Necklace': ['All', 'Gold Necklace', 'Diamond Necklace'],
    'Nose Pin': ['All', 'Gold Nose Pin', 'Diamond Nose Pin'],
  };

  String selectedCategory = 'Chains';
  String selectedSubCategory = 'All';
  bool isLoading = false;

  // 🔍 Search related variables
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  Future<void> loadCategory(String category) async {
    setState(() {
      isLoading = true;
      selectedCategory = category;
      selectedSubCategory = 'All';
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });
  }


  int selectedIndex = 1; // default Categories screen

  final List<Widget> screens = [
     DashboardScreen(),
     CategoriesScreen(),
     WishlistScreen(),
     AccountScreen(),
     CartScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ UPDATED APPBAR WITH SEARCH FEATURE
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: !isSearching
            ? const Text(
                "All Categories",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              )
            : TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search categories...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (value) {
                  // You can filter categories here if needed
                },
              ),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
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

      // ✅ BODY
      body: Row(
        children: [
          // LEFT SIDE MENU
          Container(
            width: 100,
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
                          backgroundColor:
                               Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(icon, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.teal
                                : Colors.grey.shade800,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
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
                ?  Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SUBCATEGORIES
                        SizedBox(
                          height: 45,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: subCategories[selectedCategory]!.length,
                            itemBuilder: (context, index) {
                              final sub =
                                  subCategories[selectedCategory]![index];
                              final isSelected = sub == selectedSubCategory;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSubCategory = sub;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.teal
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sub,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // GRID ITEMS
                       GridView.builder(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.8,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
  ),
  itemCount: 8,
  itemBuilder: (context, index) {
    return GestureDetector(
      onTap: () {
        // 🔹 navigate to details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoldShopOffersScreen(subProducts: '')
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade100,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                      ),
                                      child: const Center(
                                          child: Icon(Icons.image,
                                              size: 50, color: Colors.white)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "$selectedSubCategory Item ${index + 1}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
      ),
    );
  },
),

                      ],
                    ),
                  ),
          ),
        ],
      ),




/*
      // ✅ BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: "Categories"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Account"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
        ],
      ),

      */
    );
  }
}
