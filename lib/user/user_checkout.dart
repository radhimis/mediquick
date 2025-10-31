import 'package:flutter/material.dart';
import 'user_routes.dart';

class UserCheckoutPage extends StatefulWidget {
  const UserCheckoutPage({super.key});

  @override
  State<UserCheckoutPage> createState() => _UserCheckoutPageState();
}

class _UserCheckoutPageState extends State<UserCheckoutPage> {
  String selectedAddress = 'Home';
  String selectedPayment = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 24),
                  onPressed: () {
                    Navigator.pop(context); // go back to cart page
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'TOTAL',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Rs.185.00',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '2 Items in your cart',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Delivery Address
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildAddressTile(
              title: 'Home',
              phone: '(205) 555-024',
              address: '1786 Wheeler Bridge',
            ),
            const SizedBox(height: 10),
            _buildAddressTile(
              title: 'Office',
              phone: '(205) 555-024',
              address: '1786 w Dallas St underfield',
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.add, size: 18, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  'Add Address',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Method
            const Text(
              'Payment method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildPaymentTile(icon: Icons.money, label: 'Cash on Delivery'),

            const Spacer(),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.userSuccessOrder, // go to Thank You page
                  );
                },
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTile({
    required String title,
    required String phone,
    required String address,
  }) {
    return InkWell(
      onTap: () => setState(() => selectedAddress = title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedAddress == title
                ? Colors.blue
                : Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: title,
              groupValue: selectedAddress,
              activeColor: Colors.blue,
              onChanged: (value) => setState(() => selectedAddress = value!),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    phone,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    address,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile({required IconData icon, required String label}) {
    return InkWell(
      onTap: () => setState(() => selectedPayment = label),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPayment == label
                ? Colors.blue
                : Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Radio<String>(
              value: label,
              groupValue: selectedPayment,
              activeColor: Colors.blue,
              onChanged: (value) => setState(() => selectedPayment = value!),
            ),
          ],
        ),
      ),
    );
  }
}
