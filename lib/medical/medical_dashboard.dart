import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medi/medical/analytics_reports.dart';
import 'package:medi/medical/medicine_inventory.dart';
import 'package:medi/medical/orders_management.dart';
import 'package:medi/medical/profile_settings.dart';
import 'package:medi/medical/chat_support.dart';

class MedicalDashboard extends StatefulWidget {
  const MedicalDashboard({super.key});
  @override
  _MedicalDashboardState createState() => _MedicalDashboardState();
}

class _MedicalDashboardState extends State<MedicalDashboard> {
  int _selectedIndex = 0;
  String userName = '';

  // Data
  List<Map<String, dynamic>> inventoryAlerts = [];
  List<Map<String, dynamic>> orderTrends = [];
  Map<String, dynamic> dashboardStats = {};
  Map<String, dynamic> deliveryPerformance = {};
  int unreadChatCount = 0;

  List<Widget> get _widgetOptions => [
        HomeView(
          userName,
          inventoryAlerts: inventoryAlerts,
          orderTrends: orderTrends,
          dashboardStats: dashboardStats,
          deliveryPerformance: deliveryPerformance,
          unreadChatCount: unreadChatCount,
          onRefresh: _refreshData,
        ),
        ActivityView(),
        AnalyticsView(),
        ProfileView(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserName();
    _loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshData() {
    _loadInitialData();
  }

  void _getUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      String name = user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User';
      setState(() {
        userName = name;
      });
    }
  }

  Future<void> _loadUnreadChatCount() async {
    try {
      final client = Supabase.instance.client;
      // Count active chat sessions with recent messages (simplified logic)
      final sessions = await client
          .from('chat_sessions')
          .select('id')
          .neq('status', 'resolved');

      setState(() {
        unreadChatCount = sessions.length;
      });
    } catch (e) {
      print('Error loading unread chat count: $e');
    }
  }

  Future<void> _loadInitialData() async {
    final client = Supabase.instance.client;

    try {
      // Load inventory alerts (medicines with low stock or expiring soon)
      final lowStockMedicines = await client
          .from('medicines')
          .select('*')
          .lt('stock_quantity', 10)
          .not('stock_quantity', 'is', null);

      final expiringMedicines = await client
          .from('medicines')
          .select('*')
          .lt('expiry_date', DateTime.now().add(Duration(days: 14)).toIso8601String())
          .not('expiry_date', 'is', null);

      // Combine the results and remove duplicates
      final inventoryData = [...lowStockMedicines, ...expiringMedicines];
      final seen = <String>{};
      final uniqueInventoryData = inventoryData.where((medicine) {
        final id = medicine['id'] as String;
        if (seen.contains(id)) return false;
        seen.add(id);
        return true;
      }).toList();

      // Load recent orders for trends
      final ordersData = await client
          .from('orders')
          .select('*')
          .gte('order_date', DateTime.now().subtract(Duration(days: 7)).toIso8601String())
          .order('order_date', ascending: false);

      // Load dashboard stats
      final statsData = await client
          .from('dashboard_stats')
          .select('*');

      // Load delivery performance
      final deliveriesData = await client
          .from('deliveries')
          .select('*')
          .gte('delivery_date', DateTime.now().subtract(Duration(days: 30)).toIso8601String());

      setState(() {
        inventoryAlerts = List<Map<String, dynamic>>.from(uniqueInventoryData);
        orderTrends = _processOrderTrends(ordersData);
        dashboardStats = _processDashboardStats(statsData);
        deliveryPerformance = _calculateDeliveryPerformance(deliveriesData);
      });

      // Load unread chat count
      await _loadUnreadChatCount();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  List<Map<String, dynamic>> _processOrderTrends(List<dynamic> ordersData) {
    // Group orders by day for the last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));

    final dailyOrders = <String, int>{};
    for (int i = 0; i < 7; i++) {
      final date = weekAgo.add(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      dailyOrders[dateStr] = 0;
    }

    for (final order in ordersData) {
      final orderDate = DateTime.parse(order['order_date']).toIso8601String().split('T')[0];
      if (dailyOrders.containsKey(orderDate)) {
        dailyOrders[orderDate] = (dailyOrders[orderDate] ?? 0) + 1;
      }
    }

    return dailyOrders.entries.map((e) => {'date': e.key, 'count': e.value}).toList();
  }

  Map<String, dynamic> _processDashboardStats(List<dynamic> statsData) {
    final stats = <String, dynamic>{};
    for (final stat in statsData) {
      stats[stat['stat_name']] = stat['stat_value'];
    }
    return stats;
  }

  Map<String, dynamic> _calculateDeliveryPerformance(List<dynamic> deliveriesData) {
    if (deliveriesData.isEmpty) {
      return {'on_time_rate': 0.0, 'avg_delivery_time': 0.0};
    }

    final onTimeDeliveries = deliveriesData.where((d) => d['on_time'] == true).length;
    final onTimeRate = onTimeDeliveries / deliveriesData.length;

    final totalTime = deliveriesData.fold<int>(0, (sum, d) => sum + (d['delivery_time_minutes'] as int));
    final avgTime = totalTime / deliveriesData.length;

    return {
      'on_time_rate': onTimeRate,
      'avg_delivery_time': avgTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadInitialData();
          await _loadUnreadChatCount();
        },
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF1E90FF),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicineInventoryPage()),
          );
        },
        backgroundColor: Color(0xFF1E90FF),
        tooltip: 'Add Medicine',
        child: Icon(Icons.add),
      ),
    );
  }
}

// Home View - Main Dashboard
class HomeView extends StatelessWidget {
  final String userName;
  final List<Map<String, dynamic>> inventoryAlerts;
  final List<Map<String, dynamic>> orderTrends;
  final Map<String, dynamic> dashboardStats;
  final Map<String, dynamic> deliveryPerformance;
  final int unreadChatCount;
  final VoidCallback onRefresh;

  const HomeView(
    this.userName, {
    super.key,
    required this.inventoryAlerts,
    required this.orderTrends,
    required this.dashboardStats,
    required this.deliveryPerformance,
    required this.unreadChatCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E90FF), Color(0xFF00BFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      Text(
                        'MediQuick',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: onRefresh,
                        icon: Icon(Icons.refresh, color: Colors.white, size: 28),
                        tooltip: 'Refresh Data',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    userName.isEmpty ? 'Welcome back!' : 'Welcome back, $userName!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'Manage your pharmacy operations efficiently',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Stats
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    dashboardStats['total_orders']?.toString() ?? '0',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    'Revenue',
                    '₹${dashboardStats['total_revenue']?.toString() ?? '0'}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickActionButton(
                  'Add Medicine',
                  Icons.add,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicineInventoryPage()),
                  ),
                ),
                _buildQuickActionButton(
                  'View Orders',
                  Icons.assignment,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrdersManagementPage()),
                  ),
                ),
                _buildQuickActionButton(
                  'Reports',
                  Icons.analytics,
                  Colors.red,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnalyticsReportsPage()),
                  ),
                ),
                _buildQuickActionButton(
                  'Settings',
                  Icons.settings,
                  Colors.teal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
                  ),
                ),
                _buildQuickActionButtonWithBadge(
                  'Chat Support',
                  Icons.chat,
                  Colors.pink,
                  unreadChatCount,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatSupportPage()),
                  ),
                ),
                _buildQuickActionButton(
                  'AI Alternatives',
                  Icons.lightbulb,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/ai-demo'),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Expiry & Stock Reminder Widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Inventory Alerts',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...inventoryAlerts.map((alert) {
                      final isExpiryAlert = alert['expiry_date'] != null;
                      final medicineName = alert['name'] ?? 'Unknown Medicine';
                      final alertMessage = isExpiryAlert
                          ? '$medicineName — expires in ${_calculateExpiryDays(alert['expiry_date'])} days'
                          : '$medicineName — only ${alert['stock_quantity']} left in stock';

                      return _buildAlertItem(alertMessage, isExpiryAlert ? Colors.red : Colors.orange);
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Order Trends Graph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Trends (This Week)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: orderTrends.map((trend) {
                          final date = trend['date'];
                          final count = trend['count']?.toDouble() ?? 0;

                          return _buildBar(date.substring(5, 10), count, Colors.blue);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Delivery Performance Meter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Delivery Performance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: deliveryPerformance['on_time_rate'] ?? 0.0,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                  ),
                                ),
                                Text(
                                  '${((deliveryPerformance['on_time_rate'] ?? 0.0) * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'On-time\nDeliveries',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.access_time,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${deliveryPerformance['avg_delivery_time']?.toStringAsFixed(0) ?? '0'} mins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'Avg Delivery\nTime',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  int _calculateExpiryDays(String expiryDate) {
    final expiry = DateTime.parse(expiryDate);
    final now = DateTime.now();
    return expiry.difference(now).inDays;
  }
}

// Activity View - Recent Activity & Alerts
class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  List<Map<String, dynamic>> activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final client = Supabase.instance.client;

      // Load recent orders
      final recentOrders = await client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false)
          .limit(3);

      // Load recent deliveries
      final recentDeliveries = await client
          .from('deliveries')
          .select('*, orders(customer_name)')
          .order('created_at', ascending: false)
          .limit(3);

      // Load recent medicine updates (assuming we have updated_at)
      final recentMedicines = await client
          .from('medicines')
          .select('*')
          .order('updated_at', ascending: false)
          .limit(3);

      // Load low stock medicines
      final lowStockMedicines = await client
          .from('medicines')
          .select('*')
          .lt('stock_quantity', 10)
          .order('stock_quantity', ascending: true)
          .limit(3);

      // Combine and sort activities
      List<Map<String, dynamic>> allActivities = [];

      for (final order in recentOrders) {
        allActivities.add({
          'type': 'order',
          'title': 'New order received',
          'description': 'Order #${order['id']} - ${order['customer_name']}',
          'timestamp': order['created_at'],
          'icon': Icons.shopping_cart,
          'color': Colors.blue,
        });
      }

      for (final delivery in recentDeliveries) {
        allActivities.add({
          'type': 'delivery',
          'title': 'Order delivered',
          'description': 'Order #${delivery['order_id']} delivered successfully',
          'timestamp': delivery['created_at'],
          'icon': Icons.check_circle,
          'color': Colors.green,
        });
      }

      for (final medicine in recentMedicines) {
        allActivities.add({
          'type': 'medicine',
          'title': 'Medicine updated',
          'description': '${medicine['name']} - ${medicine['stock_quantity']} units',
          'timestamp': medicine['updated_at'] ?? medicine['created_at'],
          'icon': Icons.medication,
          'color': Colors.green,
        });
      }

      for (final medicine in lowStockMedicines) {
        allActivities.add({
          'type': 'alert',
          'title': 'Low stock alert',
          'description': '${medicine['name']} running low (${medicine['stock_quantity']} remaining)',
          'timestamp': DateTime.now().toIso8601String(), // Current time for alerts
          'icon': Icons.warning,
          'color': Colors.orange,
        });
      }

      // Sort by timestamp descending
      allActivities.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

      // Take top 5
      setState(() {
        activities = allActivities.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading activities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : activities.isEmpty
                  ? Center(child: Text('No recent activity'))
                  : Column(
                      children: activities.map((activity) => _buildActivityItem(
                        activity['title'],
                        activity['description'],
                        _formatTimeAgo(activity['timestamp']),
                        activity['icon'],
                        activity['color'],
                      )).toList(),
                    ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Analytics View - Quick Analytics Preview
class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  _AnalyticsViewState createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  double todaysSales = 0.0;
  double weeklySales = 0.0;
  List<Map<String, dynamic>> topMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final client = Supabase.instance.client;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(Duration(days: 7));

      // Calculate today's sales
      final todayOrders = await client
          .from('orders')
          .select('total_amount')
          .gte('created_at', today.toIso8601String());

      todaysSales = todayOrders.fold(0.0, (sum, order) => sum + (order['total_amount'] as num).toDouble());

      // Calculate weekly sales
      final weekOrders = await client
          .from('orders')
          .select('total_amount')
          .gte('created_at', weekAgo.toIso8601String());

      weeklySales = weekOrders.fold(0.0, (sum, order) => sum + (order['total_amount'] as num).toDouble());

      // Get top selling medicines (this is simplified - in reality you'd need order items table)
      // For now, just show medicines with highest stock as proxy
      final medicines = await client
          .from('medicines')
          .select('*')
          .order('stock_quantity', ascending: false)
          .limit(3);

      setState(() {
        topMedicines = List<Map<String, dynamic>>.from(medicines);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading analytics data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Today\'s Sales',
                        '₹${todaysSales.toStringAsFixed(0)}',
                        Icons.today,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        'This Week',
                        '₹${weeklySales.toStringAsFixed(0)}',
                        Icons.calendar_view_week,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
          SizedBox(height: 20),
          Text(
            'Top Medicines in Stock',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _isLoading
              ? Center(child: SizedBox(height: 60, child: CircularProgressIndicator()))
              : topMedicines.isEmpty
                  ? Center(child: Text('No medicines data'))
                  : Column(
                      children: topMedicines.map((medicine) => _buildTopMedicineItem(
                        medicine['name'] ?? 'Unknown',
                        '${medicine['stock_quantity'] ?? 0} units',
                        Colors.orange,
                      )).toList(),
                    ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnalyticsReportsPage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E90FF),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text('View Full Reports'),
          ),
        ],
      ),
    );
  }
}

// Profile View - Quick Profile Info
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1E90FF),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'MediQuick Pharmacy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'License: PHARM001234',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 30),
          _buildProfileItem('Email', 'pharmacy@mediquick.com', Icons.email),
          _buildProfileItem('Phone', '+91 9876543210', Icons.phone),
          _buildProfileItem(
            'Address',
            '123 Medical Street, City',
            Icons.location_on,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E90FF),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Order Trends Chart
class OrderTrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF1E90FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    path.moveTo(0, size.height - 30);
    path.lineTo(size.width / 4, size.height - 100);
    path.lineTo(size.width / 2, size.height - 50);
    path.lineTo(size.width * 3 / 4, size.height - 70);
    path.lineTo(size.width, size.height - 10);

    canvas.drawPath(path, paint);

    // Dots
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(0, size.height - 30), 6, dotPaint);
    canvas.drawCircle(Offset(size.width / 4, size.height - 100), 6, dotPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height - 50), 6, dotPaint);
    canvas.drawCircle(Offset(size.width * 3 / 4, size.height - 70), 6, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height - 10), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Helper Widgets
Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildQuickActionButton(
  String label,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 28),
          onPressed: onTap,
        ),
      ),
      SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildQuickActionButtonWithBadge(
  String label,
  IconData icon,
  Color color,
  int badgeCount,
  VoidCallback onTap,
) {
  return Column(
    children: [
      Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.white, size: 28),
              onPressed: onTap,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildAlertItem(String message, Color color) {
  return Container(
    margin: EdgeInsets.only(bottom: 8),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border(left: BorderSide(color: color, width: 4)),
    ),
    child: Row(
      children: [
        Icon(
          color == Colors.red ? Icons.warning : Icons.info,
          color: color,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActivityItem(
  String title,
  String subtitle,
  String time,
  IconData icon,
  Color color,
) {
  return Card(
    margin: EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
    ),
  );
}

Widget _buildTopMedicineItem(String name, String units, Color color) {
  return Card(
    margin: EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(Icons.medical_services, color: Colors.white),
      ),
      title: Text(name),
      trailing: Text(units, style: TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

Widget _buildProfileItem(String label, String value, IconData icon) {
  return Card(
    margin: EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(icon, color: Color(0xFF1E90FF)),
      title: Text(label),
      subtitle: Text(value),
    ),
  );
}

Widget _buildBar(String label, double value, Color color) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        width: 30,
        height: value * 6, // Scale the height
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      Text(
        value.toInt().toString(),
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    ],
  );
}
