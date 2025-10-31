import 'package:flutter/material.dart';
import '../app_router.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<_CartItem> _items = [
    _CartItem(name: 'Paracetamol 500mg', price: 25.0, qty: 1),
    _CartItem(name: 'Amoxicillin 250mg', price: 120.0, qty: 1),
    _CartItem(name: 'Cetirizine 10mg', price: 15.0, qty: 2),
  ];

  void _incrementQuantity(int index) => setState(() => _items[index].qty++);
  void _decrementQuantity(int index) {
    if (_items[index].qty > 1) {
      setState(() => _items[index].qty--);
    }
  }

  void removeItem(int index) => setState(() => _items.removeAt(index));

  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.qty));

  void _proceedToCheckout() {
    Navigator.pushNamed(context, AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Cart'),
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              onPressed: () => setState(() => _items.clear()),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 100, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add items to get started',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                child: Icon(Icons.medication_outlined,
                                    color: theme.colorScheme.primary,
                                    size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              _QuantityStepper(
                                quantity: item.qty,
                                onDecrement: () => _decrementQuantity(index),
                                onIncrement: () => _incrementQuantity(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('₹${_subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _items.isEmpty ? null : _proceedToCheckout,
                    child: const Text(
                      'Proceed to Checkout',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem {
  final String name;
  final double price;
  int qty;

  _CartItem({required this.name, required this.price, this.qty = 1});
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(Icons.remove, onDecrement, theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              quantity.toString(),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _stepperButton(Icons.add, onIncrement, theme),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap, ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 18, color: theme.colorScheme.primary),
      ),
    );
  }
}
