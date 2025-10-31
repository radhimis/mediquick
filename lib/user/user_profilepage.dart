import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_routes.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: MyProfileScreen()),
  );
}

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3C4FFF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, AppRoutes.userHomePage);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.userCart);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.userOrders);
              break;
            case 3:
              // Already on profile
              break;
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, Rahul kanjariya",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Welcome to MediQuick",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            profileTile(
              icon: Icons.edit_note,
              label: "Edit Profile",
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            profileTile(
              icon: Icons.shopping_bag_outlined,
              label: "My orders",
              onTap: () => Navigator.pushNamed(context, AppRoutes.userOrders),
            ),
            profileTile(
              icon: Icons.receipt_long_outlined,
              label: "Billing",
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.userBilling,
                arguments: {'totalAmount': 0.0}, // Replace with actual amount
              ),
            ),
            profileTile(
              icon: Icons.help_outline,
              label: "Faq",
              onTap: () => Navigator.pushNamed(context, AppRoutes.userFAQ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: onTap,
        ),
        const Divider(height: 0),
      ],
    );
  }
}
