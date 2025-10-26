import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'reset_password_page.dart';
import 'supabase_client.dart';
import 'package:medi/medical/medical_dashboard.dart';
import 'qr_code_generator_page.dart';
import 'ocr/prescription_upload_page.dart';
import 'ai/generic_alternatives_page.dart';
import 'ai/ai_demo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediQuick',
      theme: ThemeData(
        primaryColor: Color(0xFF1E90FF),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/medical-dashboard',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/reset-password': (context) => ResetPasswordPage(),
        '/medical-dashboard': (context) => MedicalDashboard(),
        '/qr-generator': (context) => QRCodeGeneratorPage(),
        '/prescription-upload': (context) => PrescriptionUploadPage(),
        '/generic-alternatives': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final medicines = args?['medicines'] as List<String>? ?? [];
          return GenericAlternativesPage(medicines: medicines);
        },
        '/ai-demo': (context) => const AIDemoPage(),
      },
    );
  }
}
