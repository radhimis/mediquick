import 'package:flutter/material.dart';

// USER APP
import 'loginpage.dart';
import 'signuppage.dart';
import 'forgotpass.dart';
import 'resetpass.dart';
import 'user/user_routes.dart';
import 'user/user_home_page.dart';
import 'user/user_cart.dart';
import 'user/user_checkout.dart';
import 'user/myorders.dart';
import 'user/user_successorder.dart';
import 'user/user_profilepage.dart';
import 'user/edit_profile.dart';
import 'user/faq.dart';

// MEDICINE APP
import 'medicine/medicine_walkthrough_screen.dart';

// DOCTOR APP
import 'doctor/doctor_flow_screen.dart';

// DASHBOARD
import 'dashboard/dashboard.dart';

void main() {
  runApp(const UnifiedApp());
}

class UnifiedApp extends StatelessWidget {
  const UnifiedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unified Health App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFFA084CA),
      ),
      home: const AppSelectorScreen(), // Unified selector
      routes: {
        // Keep all your user app routes intact
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot': (context) => const ForgotPassPage(),
        '/reset': (context) => const ResetPassPage(),
        AppRoutes.userHomePage: (context) => UserHomePage(),
        AppRoutes.userCart: (context) => const UserCartPage(),
        AppRoutes.userCheckout: (context) => const UserCheckoutPage(),
        AppRoutes.userOrders: (context) => const OrdersPage(),
        AppRoutes.userSuccessOrder: (context) => const UserSuccessOrderPage(),
        AppRoutes.userProfile: (context) => const MyProfileScreen(),
        AppRoutes.editProfile: (context) => EditProfilePage(),
        AppRoutes.userFAQ: (context) => FAQPage(),
      },
    );
  }
}

// ---------------- Unified Selector ----------------
class AppSelectorScreen extends StatelessWidget {
  const AppSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Choose App Mode"),
        backgroundColor: const Color(0xFFA084CA),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Medicine Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA084CA),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicineWalkthroughScreen(),
                    ),
                  );
                },
                child: const Text("Medicine App"),
              ),
              const SizedBox(height: 20),

              // ✅ Doctor Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorFlowScreen(),
                    ),
                  );
                },
                child: const Text("Doctor App"),
              ),
              const SizedBox(height: 20),

              // ✅ Patient/User App Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/'); // Starts login page
                },
                child: const Text("Patient App"),
              ),

              const SizedBox(height: 20),

              // ✅ Dashboard Button (optional)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Dashboard(), // doctor dashboard
                    ),
                  );
                },
                child: const Text("Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}