import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  int _paymentIndex = 0; // 0: Card, 1: UPI, 2: COD

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _placeOrder() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed (mock). Navigating to tracking...')),
    );
    // TODO: Navigate to tracking page if implemented
    // Navigator.pushNamed(context, '/tracking');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Checkout'), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shipping Address',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(controller: _nameCtrl, label: 'Full name', icon: Icons.person, validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _phoneCtrl, label: 'Phone number', icon: Icons.phone, keyboard: TextInputType.phone, validator: (v) => (v == null || v.trim().length < 10) ? 'Enter a valid phone number' : null),
                          const SizedBox(height: 12),
                          _buildTextField(controller: _addressCtrl, label: 'Address (House no, Street)', icon: Icons.home, validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your address' : null),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(controller: _cityCtrl, label: 'City', icon: Icons.location_city, validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your city' : null),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(controller: _pinCtrl, label: 'PIN code', icon: Icons.pin_drop, keyboard: TextInputType.number, validator: (v) => (v == null || v.trim().length < 6) ? 'Enter a valid PIN code' : null),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _paymentOption(index: 0, title: 'Card (Credit/Debit)', icon: Icons.credit_card_rounded),
                          _paymentOption(index: 1, title: 'UPI', icon: Icons.account_balance_wallet_rounded),
                          _paymentOption(index: 2, title: 'Cash on Delivery', icon: Icons.money_rounded),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('₹180.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _placeOrder,
                    child: const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _paymentOption({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _paymentIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _paymentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? theme.colorScheme.primary : Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
