import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerInsightsPage extends StatefulWidget {
  @override
  _CustomerInsightsPageState createState() => _CustomerInsightsPageState();
}

class _CustomerInsightsPageState extends State<CustomerInsightsPage> {
  List<Map<String, dynamic>> customerData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      final client = Supabase.instance.client;
      final orders = await client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);

      // Group by customer
      final Map<String, Map<String, dynamic>> customerMap = {};

      for (final order in orders) {
        final customerName = order['customer_name'];
        if (!customerMap.containsKey(customerName)) {
          customerMap[customerName] = {
            'name': customerName,
            'total_orders': 0,
            'total_spent': 0.0,
            'last_order': order['created_at'],
            'orders': [],
          };
        }
        customerMap[customerName]!['total_orders'] += 1;
        customerMap[customerName]!['total_spent'] += order['total_amount'];
        customerMap[customerName]!['orders'].add(order);
      }

      setState(() {
        customerData = customerMap.values.toList()
          ..sort((a, b) => b['total_spent'].compareTo(a['total_spent']));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customer data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Insights'),
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Customers by Spending',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: customerData.isEmpty
                        ? Center(child: Text('No customer data available'))
                        : ListView.builder(
                            itemCount: customerData.length,
                            itemBuilder: (context, index) {
                              final customer = customerData[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(customer['name']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Total Orders: ${customer['total_orders']}'),
                                      Text('Total Spent: ₹${customer['total_spent'].toStringAsFixed(2)}'),
                                      Text('Last Order: ${DateTime.parse(customer['last_order']).toLocal().toString().split(' ')[0]}'),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () => _showCustomerOrders(customer['orders']),
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

  void _showCustomerOrders(List<dynamic> orders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer Orders'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order #${order['id']}'),
                subtitle: Text('₹${order['total_amount']} - ${DateTime.parse(order['created_at']).toLocal().toString().split(' ')[0]}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
