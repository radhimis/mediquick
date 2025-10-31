import 'package:flutter/material.dart';
import '../app_router.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_Order> _allOrders = [
    _Order(id: 'MDQ1002', date: '14 Sep 2025', total: 420.00, status: 'Out for delivery'),
    _Order(id: 'MDQ1003', date: '14 Sep 2025', total: 260.00, status: 'Packed'),
    _Order(id: 'MDQ1001', date: '13 Sep 2025', total: 180.00, status: 'Delivered'),
    _Order(id: 'MDQ099', date: '12 Sep 2025', total: 95.00, status: 'Delivered'),
    _Order(id: 'MDQ098', date: '11 Sep 2025', total: 310.00, status: 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {}); // Refresh on tab change
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Order> _getFilteredOrders() {
    switch (_tabController.index) {
      case 0:
        return _allOrders.where((o) => o.status == 'Packed' || o.status == 'Out for delivery').toList();
      case 1:
        return _allOrders.where((o) => o.status == 'Delivered').toList();
      case 2:
        return _allOrders.where((o) => o.status == 'Cancelled').toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: cs.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              labelColor: cs.primary,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Active"),
                Tab(text: "Delivered"),
                Tab(text: "Cancelled"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (index) {
          final filteredOrders = _getFilteredOrders();
          return filteredOrders.isEmpty
              ? _EmptyState(cs: cs)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, i) => _OrderCard(order: filteredOrders[i]),
                );
        }),
      ),
    );
  }
}

class _Order {
  final String id;
  final String date;
  final double total;
  final String status;

  _Order({required this.id, required this.date, required this.total, required this.status});
}

class _OrderCard extends StatelessWidget {
  final _Order order;
  const _OrderCard({required this.order});

  Color _getStatusColor(String status, ColorScheme cs) {
    switch (status) {
      case 'Delivered':
        return Colors.green.shade600;
      case 'Out for delivery':
        return cs.primary;
      case 'Packed':
        return Colors.orange.shade700;
      case 'Cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(order.status, cs);
    final bool isActive = order.status == 'Packed' || order.status == 'Out for delivery';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Order ${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(99)),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    order.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            )
          ]),
          const SizedBox(height: 6),
          Text("${order.date} • Total: ₹${order.total.toStringAsFixed(2)}", style: TextStyle(color: Colors.grey.shade600)),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                // Implement view details navigation if needed
              },
              child: const Text("View Details"),
            ),
            const SizedBox(width: 8),
            if (isActive)
              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.tracking),
                child: const Text("Track Order"),
              ),
          ])
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_long_outlined, size: 90, color: cs.primary.withOpacity(0.4)),
        const SizedBox(height: 20),
        Text("No orders here", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
        const SizedBox(height: 6),
        Text("Your orders will appear in this section.", style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Implement shop now navigation if desired
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Shop Now"),
        )
      ]),
    );
  }
}
