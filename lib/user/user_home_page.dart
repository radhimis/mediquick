import 'package:flutter/material.dart';
import 'user_routes.dart';

class UserHomePage extends StatelessWidget {
  final List<Category> categories = [
    Category('Dental', Colors.pink.shade100, Icons.medical_services_outlined),
    Category(
      'Wellness',
      Colors.green.shade100,
      Icons.self_improvement_outlined,
    ),
    Category('Homeo', Colors.orange.shade100, Icons.home_outlined),
    Category('Eye care', Colors.blue.shade100, Icons.remove_red_eye_outlined),
  ];

  final List<Product> products = [
    Product('Accu-check Active', 'Test Strip', 112),
    Product('Accu-check Active', 'Test Strip', 112),
    Product('Accu-check Active', 'Test Strip', 112),
    Product('Accu-check Active', 'Test Strip', 112),
  ];

  UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF4C6FFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, AppRoutes.userHomePage);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.userBilling);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.userOrders);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.userProfile);
              break;
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C6FFF),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 23,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?fit=crop&w=200&q=80',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Hi, Rahul',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Welcome to MediQuick!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.notifications_none, color: Colors.white),
                          SizedBox(width: 18),
                          Icon(Icons.email_outlined, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ✅ Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      hintText: 'Search Medicine & Healthcare products',
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Top Categories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 18),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Container(
                        width: 235,
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat.icon, size: 38, color: Colors.black54),
                            const SizedBox(height: 10),
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Deals of the Day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'More',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4C6FFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 210,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final Color color;
  final IconData icon;

  Category(this.name, this.color, this.icon);
}

class Product {
  final String name;
  final String subtitle;
  final double price;

  Product(this.name, this.subtitle, this.price);
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 105,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.local_pharmacy,
                size: 40,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            product.subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            'Rs.${product.price}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
