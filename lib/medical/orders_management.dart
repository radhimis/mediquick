import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'add_order_page.dart';
import 'add_delivery_page.dart';

class OrdersManagementPage extends StatefulWidget {
  @override
  _OrdersManagementPageState createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage> {
  List<Map<String, dynamic>> orders = [];
  bool _isLoading = true;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final client = Supabase.instance.client;
      final data = await client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading orders: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddOrderPage()),
    );

    if (result == true) {
      _loadOrders(); // Reload the list
    }
  }

  void _addDelivery() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDeliveryPage()),
    );

    if (result == true) {
      // Delivery added successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery record added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateStatus(int id, String newStatus) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );

      _loadOrders(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (_selectedStatus == 'All') return orders;
    return orders.where((order) => order['status'] == _selectedStatus).toList();
  }

  String _generateOrderQRData(Map<String, dynamic> order) {
    // Create a JSON-like string with order details for QR code
    final qrData = {
      'orderId': order['id'],
      'customerName': order['customer_name'],
      'totalAmount': order['total_amount'],
      'status': order['status'],
      'orderDate': order['order_date'] ?? order['created_at'],
    };
    return qrData.toString();
  }

  void _showOrderQRCode(Map<String, dynamic> order) {
    final qrData = _generateOrderQRData(order);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id']} QR Code'),
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
              'Scan this QR code to view order details',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Order: ${order['customer_name']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Status: ${order['status']}'),
            Text('Total: ₹${order['total_amount']}'),
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

  void _scanOrderQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Scan Order QR Code'),
            backgroundColor: Color(0xFF1E90FF),
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  // Parse the QR data and find the order
                  _processScannedQR(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _processScannedQR(String qrData) {
    try {
      // The QR data is a string representation of a map
      // For simplicity, we'll extract the order ID from the string
      final orderIdMatch = RegExp(r'orderId: (\d+)').firstMatch(qrData);
      if (orderIdMatch != null) {
        final orderId = int.parse(orderIdMatch.group(1)!);

        // Find the order in the current list
        final order = orders.firstWhere(
          (o) => o['id'] == orderId,
          orElse: () => <String, dynamic>{},
        );

        if (order.isNotEmpty) {
          // Close the scanner
          Navigator.of(context).pop();

          // Show order details with quick actions
          _showScannedOrderDetails(order);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order not found in current list. Please refresh.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid QR code format'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing QR code: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showScannedOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id']} - ${order['customer_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order['status']}'),
            Text('Total: ₹${order['total_amount']}'),
            Text('Order Date: ${order['order_date'] != null ? DateTime.parse(order['order_date']).toLocal().toString().split(' ')[0] : 'N/A'}'),
            SizedBox(height: 16),
            Text(
              'Quick Actions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (order['status'] == 'Pending')
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _updateStatus(order['id'], 'Processing');
                  },
                  child: Text('Accept'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _updateStatus(order['id'], 'Rejected');
                  },
                  child: Text('Reject'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          if (order['status'] == 'Processing')
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateStatus(order['id'], 'Out for Delivery');
              },
              child: Text('Out for Delivery'),
            ),
          if (order['status'] == 'Out for Delivery')
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateStatus(order['id'], 'Delivered');
              },
              child: Text('Mark Delivered'),
            ),
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
        title: Text('Orders Management'),
        backgroundColor: Color(0xFF1E90FF),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: _scanOrderQR,
            tooltip: 'Scan Order QR',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addOrder,
          ),
          IconButton(
            icon: Icon(Icons.delivery_dining),
            onPressed: _addDelivery,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedStatus,
              items: ['All', 'Pending', 'Processing', 'Delivered'].map((
                status,
              ) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Card(
                          child: ExpansionTile(
                            title: Text(
                              'Order #${order['id']} - ${order['customer_name']}',
                            ),
                            subtitle: Text(
                              'Status: ${order['status']} | Total: ₹${order['total_amount']}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Customer: ${order['customer_name'] ?? 'N/A'}'),
                                    Text('Total Amount: ₹${order['total_amount'] ?? '0'}'),
                                    Text('Status: ${order['status'] ?? 'N/A'}'),
                                    Text('Order Date: ${order['order_date'] != null ? DateTime.parse(order['order_date']).toLocal().toString().split(' ')[0] : 'N/A'}'),
                                    Text('Created: ${order['created_at'] != null ? DateTime.parse(order['created_at']).toLocal().toString().split(' ')[0] : 'N/A'}'),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.qr_code),
                                          onPressed: () => _showOrderQRCode(order),
                                          tooltip: 'Show QR Code',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
