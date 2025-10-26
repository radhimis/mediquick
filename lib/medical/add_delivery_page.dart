import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddDeliveryPage extends StatefulWidget {
  const AddDeliveryPage({super.key});

  @override
  _AddDeliveryPageState createState() => _AddDeliveryPageState();
}

class _AddDeliveryPageState extends State<AddDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderIdController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  bool _onTime = true;
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      final client = Supabase.instance.client;
      final orders = await client
          .from('orders')
          .select('id, customer_name, total_amount')
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _orders = List<Map<String, dynamic>>.from(orders);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading orders: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final deliveryData = {
        'order_id': int.parse(_orderIdController.text),
        'delivery_time_minutes': int.parse(_deliveryTimeController.text),
        'on_time': _onTime,
        'delivery_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await client.from('deliveries').insert(deliveryData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery record added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeliveryQRCode() {
    if (_orderIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an order first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final orderId = int.tryParse(_orderIdController.text);
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid order ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Find the selected order
    final selectedOrder = _orders.firstWhere(
      (order) => order['id'] == orderId,
      orElse: () => <String, dynamic>{},
    );

    if (selectedOrder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate delivery QR data
    final deliveryData = {
      'type': 'delivery',
      'orderId': selectedOrder['id'],
      'customerName': selectedOrder['customer_name'],
      'totalAmount': selectedOrder['total_amount'],
      'address': 'Delivery Address', // This would come from delivery form
      'deliveryTime': _deliveryTimeController.text,
      'onTime': _onTime,
    };

    final qrData = deliveryData.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery QR Code - Order #${selectedOrder['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 16),
            Text(
              'Scan this QR code for delivery tracking',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Customer: ${selectedOrder['customer_name']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Order Total: ₹${selectedOrder['total_amount']}'),
            Text('Delivery Time: ${_deliveryTimeController.text}'),
            Text('On Time: ${_onTime ? "Yes" : "No"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Delivery Record'),
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Order',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                items: _orders.map((order) {
                  return DropdownMenuItem(
                    value: order['id'].toString(),
                    child: Text(
                      'Order #${order['id']} - ${order['customer_name']} (₹${order['total_amount']})',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _orderIdController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an order';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _deliveryTimeController,
                decoration: InputDecoration(
                  labelText: 'Delivery Time (minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter delivery time';
                  }
                  final time = int.tryParse(value);
                  if (time == null || time <= 0) {
                    return 'Please enter a valid time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Delivered On Time'),
                subtitle: Text(_onTime ? 'Yes' : 'No'),
                value: _onTime,
                onChanged: (value) {
                  setState(() {
                    _onTime = value;
                  });
                },
                activeColor: Color(0xFF1E90FF),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E90FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Add Delivery Record',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _showDeliveryQRCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Show Delivery QR Code',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
