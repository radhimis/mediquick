import 'package:flutter/material.dart';
import 'user_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProductDetailsPage(orderId: '0000'),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final String orderId;

  const ProductDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back, color: Colors.black87),
                Row(
                  children: [
                    Icon(Icons.notifications_none, color: Colors.black87),
                    const SizedBox(width: 16),
                    Icon(Icons.shopping_bag_outlined, color: Colors.black87),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Order ID: $orderId",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              "Sugar Free Gold Low Calories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Etiam mollis metus non purus",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[200],
                child: Center(
                  child: Image.network(
                    "https://i.imgur.com/zYqE3xZ.png",
                    height: 100,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Rs.99",
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Rs.56",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add, size: 16),
                  label: Text("Add to cart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Package size", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _sizeBox("Rs.106", "500 pellets", selected: true),
                const SizedBox(width: 8),
                _sizeBox("Rs.166", "110 pellets"),
                const SizedBox(width: 8),
                _sizeBox("Rs.252", "300 pellets"),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle("Product Details"),
            _dummyText(),
            const SizedBox(height: 12),
            _sectionTitle("Ingredients"),
            _dummyText(),
            const SizedBox(height: 12),
            Row(
              children: [
                _smallText("Expiry Date", "25/12/2023"),
                const SizedBox(width: 40),
                _smallText("Brand Name", "Something"),
              ],
            ),
            const SizedBox(height: 20),
            _ratingSection(),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text("4.2", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text("05 - oct 2020", style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Erric Hoffman",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _dummyText(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "GO TO CART",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _sizeBox(String price, String quantity, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.orange[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? Colors.orange : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(quantity, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _dummyText() {
    return const Text(
      "Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi ut nisi odio. Nulla facilisi. "
      "Nunc risus massa, gravida id egestas a, pretium vel tellus. Praesent feugiat diam sit amet pulvinar finibus.",
      style: TextStyle(color: Colors.grey, fontSize: 13),
    );
  }

  Widget _smallText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _ratingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              "4.4",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.star, color: Colors.orange),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "923 Ratings and 257 Reviews",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _ratingRow(5, 67),
        _ratingRow(4, 23),
        _ratingRow(3, 7),
        _ratingRow(2, 2),
        _ratingRow(1, 2),
      ],
    );
  }

  Widget _ratingRow(int star, int percent) {
    return Row(
      children: [
        Text("$star", style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Icon(Icons.star, color: Colors.orange, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: LinearProgressIndicator(
            value: percent / 100,
            color: Colors.orange,
            backgroundColor: Colors.grey[300],
          ),
        ),
        const SizedBox(width: 8),
        Text("$percent%", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
