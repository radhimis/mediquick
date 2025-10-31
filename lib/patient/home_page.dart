import 'package:flutter/material.dart';
import '../app_router.dart';
import 'scan_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Mock recent orders
  final List<Map<String, dynamic>> _recentOrders = [
    {'id': 'MDQ101', 'status': 'Delivered', 'itemCount': 2},
    {'id': 'MDQ100', 'status': 'Cancelled', 'itemCount': 1},
    {'id': 'MDQ099', 'status': 'Delivered', 'itemCount': 5},
  ];

  // Mock nearby stores data
  final List<Map<String, String>> _nearbyStores = [
    {"name": "City Medics", "address": "123 Main St"},
    {"name": "Health Plus Pharmacy", "address": "45 Park Ave"},
    {"name": "WellCare Pharmacy", "address": "78 Oak Dr"},
    {"name": "MediQuick Store", "address": "22 Elm St"},
    {"name": "Care Point Pharmacy", "address": "36 Maple Rd"},
  ];

  final String _userName = "John Doe";
  int _unreadNotifications = 3;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
        _buildHomeContent(),
        const ScanPage(),
        const OrdersPage(),
        const ProfilePage(),
      ];

  Widget _buildHomeContent() {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.document_scanner_outlined,
                color: cs.primary,
                title: "Upload Rx",
                subtitle: "Scan & order",
                onTap: () => _onTabSelected(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.local_hospital_outlined,
                color: Colors.redAccent,
                title: "Nearby Store",
                subtitle: "Find easily",
                onTap: () => Navigator.pushNamed(context, AppRoutes.nearbyStore),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _QuickActionCard(
          icon: Icons.support_agent_outlined,
          color: Colors.green,
          title: "24/7 Support",
          subtitle: "Chat with pharmacist",
          onTap: () => Navigator.pushNamed(context, AppRoutes.supportChat),
          isFullWidth: true,
        ),
        const SizedBox(height: 28),
        Text(
          'Recent Orders',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_recentOrders.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No recent orders found.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Column(
              children: [
                for (var order in _recentOrders)
                  _OrderTile(
                    title: 'Order #${order['id']}',
                    subtitle: '${order['status']} • ${order['itemCount']} items',
                    onReorder: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reordering order #${order['id']}'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        Text(
          'Nearby Medical Stores',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _nearbyStores.length,
          itemBuilder: (context, index) {
            final store = _nearbyStores[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${store["name"]}')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        store["name"]!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store["address"]!,
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Welcome, $_userName 👋',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                icon: Icon(Icons.notifications_outlined, color: cs.primary),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cs.primary,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.chat);
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text("Chat"),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isFullWidth ? 2 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(subtitle,
                          style:
                              TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onReorder;

  const _OrderTile(
      {required this.title, required this.subtitle, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: cs.primary.withOpacity(0.1),
            child: Icon(Icons.local_pharmacy_outlined, color: cs.primary),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: OutlinedButton.icon(
            onPressed: onReorder,
            icon: const Icon(Icons.replay, size: 18),
            label: const Text("Reorder"),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.primary),
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ),
        const Divider(indent: 16, endIndent: 16, height: 1),
      ],
    );
  }
}
