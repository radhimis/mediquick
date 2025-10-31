import 'package:flutter/material.dart';
import 'user_routes.dart';

class BillingPage extends StatefulWidget {
  final double totalAmount;

  const BillingPage({Key? key, required this.totalAmount}) : super(key: key);

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  List<Map<String, dynamic>> items = [
    {"name": "Paracetamol 500mg", "quantity": 2, "price": 50},
    {"name": "Cough Syrup 100ml", "quantity": 1, "price": 120},
    {"name": "Vitamin C 1000mg", "quantity": 3, "price": 30},
  ];

  int getSubtotal() {
    int total = 0;
    for (var item in items) {
      total += (item["quantity"] as int) * (item["price"] as int);
    }
    return total;
  }

  int getDiscount() {
    int subtotal = getSubtotal();
    return subtotal > 300 ? (subtotal * 0.1).toInt() : 0;
  }

  int getTax() {
    int subtotal = getSubtotal() - getDiscount();
    return (subtotal * 0.05).toInt();
  }

  int getFinalTotal() {
    return widget.totalAmount.toInt(); // override with passed value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        title: const Text(
          "Billing",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        item["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text("Quantity: ${item["quantity"]}"),
                      trailing: Text(
                        "₹${item["quantity"] * item["price"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      leading: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            if (item["quantity"] > 1) {
                              item["quantity"]--;
                            } else {
                              items.removeAt(index);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          item["quantity"]++;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blue.shade100,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    summaryRow("Subtotal", "₹${getSubtotal()}"),
                    summaryRow("Discount", "- ₹${getDiscount()}"),
                    summaryRow("Tax (5% GST)", "+ ₹${getTax()}"),
                    const Divider(thickness: 1),
                    summaryRow(
                      "Final Total",
                      "₹${getFinalTotal()}",
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.userSuccessOrder);
                  setState(() {
                    items.clear();
                  });
                },
                child: const Text(
                  "Pay Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
