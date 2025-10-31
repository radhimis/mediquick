import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_routes.dart';

class UserCartPage extends StatefulWidget {
  const UserCartPage({super.key});

  @override
  State<UserCartPage> createState() => _UserCartPageState();
}

class _UserCartPageState extends State<UserCartPage> {
  final List<CartItem> cartItems = [
    CartItem("assets/item1.png", "Sugar free gold", "Rs.25", 1),
    CartItem("assets/item2.png", "Sugar free gold", "Rs.18", 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Your cart",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.userHomePage);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  "+ Add more",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "${cartItems.length} Items in your cart",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...cartItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: cartItem(item),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            paymentSummary(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.userCheckout);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C4FFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  "Place Order",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cartItem(CartItem item) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
              image: DecorationImage(
                image: AssetImage(item.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "bottle of 500 pellets",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.price,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () {
                  setState(() {
                    if (item.quantity > 1) item.quantity--;
                  });
                },
              ),
              Text(
                "${item.quantity}",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () {
                  setState(() {
                    item.quantity++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget paymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Summary",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        summaryRow("Order Total", "Rs.228.80"),
        summaryRow("Items Discount", "-Rs.28.80"),
        summaryRow("Coupon Discount", "-Rs.15.80"),
        summaryRow("Shipping", "Free"),
        const Divider(),
        summaryRow(
          "Total",
          "Rs.185.00",
          isBold: true,
          color: const Color(0xFF3C4FFF),
        ),
      ],
    );
  }

  Widget summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String imagePath;
  final String title;
  final String price;
  int quantity;

  CartItem(this.imagePath, this.title, this.price, this.quantity);
}
