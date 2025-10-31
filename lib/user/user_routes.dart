import 'package:flutter/material.dart';

// ---------------- User Pages ----------------
import 'billing.dart'; // BillingPage(totalAmount: ...)
import 'edit_profile.dart'; // EditProfilePage
import 'faq.dart'; // FAQPage
import 'myorders.dart'; // OrdersPage
import 'user_cart.dart'; // UserCartPage
import 'user_checkout.dart'; // UserCheckoutPage
import 'user_home_page.dart'; // UserHomePage
import 'user_orderdetails.dart'; // ProductDetailsPage(orderId: ...)
import 'user_profilepage.dart'; // MyProfileScreen
import 'user_successorder.dart'; // UserSuccessOrderPage
import 'tracking_page.dart'; // TrackingPage(orderId, estimatedDelivery, currentStep)

// ---------------- Centralized Route Paths ----------------
class AppRoutes {
  static const userHomePage = '/userHome';
  static const userCart = '/userCart';
  static const userCheckout = '/userCheckout';
  static const userOrders = '/userOrders';
  static const userOrderDetails = '/userOrderDetails';
  static const userSuccessOrder = '/userSuccessOrder';
  static const userProfile = '/userProfile';
  static const editProfile = '/editProfile';
  static const userBilling = '/billing';
  static const userFAQ = '/faq';
  static const userTracking = '/tracking';
}

// ---------------- Route Generator ----------------
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.userHomePage:
      return MaterialPageRoute(builder: (_) => UserHomePage());

    case AppRoutes.userCart:
      return MaterialPageRoute(builder: (_) => const UserCartPage());

    case AppRoutes.userCheckout:
      return MaterialPageRoute(builder: (_) => const UserCheckoutPage());

    case AppRoutes.userOrders:
      return MaterialPageRoute(builder: (_) => const OrdersPage());

    case AppRoutes.userOrderDetails:
      final args = settings.arguments as Map<String, dynamic>?;
      final orderId = args?['orderId'] ?? '0000';
      return MaterialPageRoute(
        builder: (_) => ProductDetailsPage(orderId: orderId),
      );

    case AppRoutes.userSuccessOrder:
      return MaterialPageRoute(builder: (_) => const UserSuccessOrderPage());

    case AppRoutes.userProfile:
      return MaterialPageRoute(builder: (_) => const MyProfileScreen());

    case AppRoutes.editProfile:
      return MaterialPageRoute(builder: (_) => EditProfilePage());

    case AppRoutes.userBilling:
      final args = settings.arguments as Map<String, dynamic>?;
      final totalAmount = args?['totalAmount'] ?? 0.0;
      return MaterialPageRoute(
        builder: (_) => BillingPage(totalAmount: totalAmount),
      );

    case AppRoutes.userFAQ:
      return MaterialPageRoute(builder: (_) => FAQPage());

    case AppRoutes.userTracking:
      final args = settings.arguments as Map<String, dynamic>?;
      final orderId = args?['orderId'] ?? '0000';
      final estimatedDelivery = args?['estimatedDelivery'] ?? 'N/A';
      final currentStep = args?['currentStep'] ?? 0;
      return MaterialPageRoute(
        builder: (_) => TrackingPage(
          orderId: orderId,
          estimatedDelivery: estimatedDelivery,
          currentStep: currentStep,
        ),
      );

    default:
      return onUnknownRoute(settings);
  }
}

// ---------------- Fallback for Unknown Routes ----------------
Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) => Scaffold(
      body: Center(
        child: Text(
          "404 - Page Not Found: ${settings.name}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
