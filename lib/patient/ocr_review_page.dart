import 'package:flutter/material.dart';
import '../app_router.dart';

class OcrReviewPage extends StatefulWidget {
  const OcrReviewPage({super.key});

  @override
  State<OcrReviewPage> createState() => _OcrReviewPageState();
}

class _OcrReviewPageState extends State<OcrReviewPage> {
  final List<_Item> _items = [
    _Item(name: 'Paracetamol 500mg', qty: 1),
    _Item(name: 'Amoxicillin 250mg', qty: 1),
    _Item(name: 'Cetirizine 10mg', qty: 2),
  ];

  void _incrementQuantity(int index) => setState(() => _items[index].qty++);
  void _decrementQuantity(int index) {
    if (_items[index].qty > 1) setState(() => _items[index].qty--);
  }

  void _removeItem(int index) {
    final removedItem = _items.removeAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.name} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => setState(() => _items.insert(index, removedItem)),
        ),
      ),
    );
    setState(() {});
  }

  void _confirmAndAddToCart() {
    // Navigate to Cart page - if you want to pass items, handle via constructor arguments or shared data
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Review Prescription'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No items detected',
                            style:
                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Please try scanning again.',
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Please review the detected items. You can adjust quantities or remove items before confirming.',
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int i = 0; i < _items.length; i++)
                        Dismissible(
                          key: ValueKey(_items[i]),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _removeItem(i),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: cs.primary.withOpacity(0.1),
                                    child: Icon(Icons.medication_outlined, color: cs.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _items[i].name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                  ),
                                  _QuantityStepper(
                                    quantity: _items[i].qty,
                                    onDecrement: () => _decrementQuantity(i),
                                    onIncrement: () => _incrementQuantity(i),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${_items.length} items detected',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart_checkout),
                    onPressed: _items.isEmpty ? null : _confirmAndAddToCart,
                    label: const Text('Confirm & Add to Cart'),
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

class _Item {
  final String name;
  int qty;
  _Item({required this.name, this.qty = 1});
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove, onTap: onDecrement, color: cs.primary),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: onIncrement, color: cs.primary),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _StepperButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color.withOpacity(0.1)),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
