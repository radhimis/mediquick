import 'package:flutter/material.dart';
import 'tracking_page.dart'; // Import tracking page

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final orders = [
      _Order(
        id: 'MDQ1001',
        date: '13 Sep 2025',
        total: 180.00,
        status: 'Delivered',
        estimatedDelivery: '13 Sep 2025',
        step: 3, // Delivered
      ),
      _Order(
        id: 'MDQ1002',
        date: '14 Sep 2025',
        total: 420.00,
        status: 'Out for delivery',
        estimatedDelivery: '15 Sep 2025',
        step: 2, // Out for delivery
      ),
      _Order(
        id: 'MDQ1003',
        date: '14 Sep 2025',
        total: 260.00,
        status: 'Packed',
        estimatedDelivery: '15 Sep 2025',
        step: 1, // Packed
      ),
    ];

    Color chipColor(String s) {
      switch (s) {
        case 'Delivered':
          return Colors.green.shade600;
        case 'Out for delivery':
          return cs.primary;
        case 'Packed':
          return Colors.orange.shade700;
        default:
          return Colors.grey.shade700;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final o = orders[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withOpacity(0.12)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(Icons.local_shipping_rounded, color: cs.primary),
              ),
              title: Text(
                'Order ${o.id}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${o.date} • ₹${o.total.toStringAsFixed(2)}'),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor(o.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: chipColor(o.status).withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      o.status,
                      style: TextStyle(
                        color: chipColor(o.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Navigate dynamically to tracking page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackingPage(
                            orderId: o.id,
                            estimatedDelivery: o.estimatedDelivery,
                            currentStep: o.step,
                          ),
                        ),
                      );
                    },
                    child: const Text('Track'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Order {
  final String id;
  final String date;
  final double total;
  final String status;
  final String estimatedDelivery;
  final int step;

  _Order({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.estimatedDelivery,
    required this.step,
  });
}
