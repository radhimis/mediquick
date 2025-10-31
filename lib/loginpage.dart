import 'package:flutter/material.dart';

// IMPORTANT: Update these imports with actual file names if needed
import 'signuppage.dart';
import 'forgotpass.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPass = false;
  String? _loginRole; // 'patient' | 'doctor' | 'medical'

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onForgot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPassPage()),
    );
  }

  void _onCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    if (_loginRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select account type')),
      );
      return;
    }

    // Demo login success logic (replace with real auth later)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Login successful 🎉')));

    Future.delayed(const Duration(milliseconds: 700), () {
      switch (_loginRole) {
        case 'patient':
          Navigator.pushReplacementNamed(context, '/userHome'); // Patient home
          break;
        case 'doctor':
          Navigator.pushReplacementNamed(
            context,
            '/doctorHome',
          ); // Doctor home stub
          break;
        case 'medical':
          Navigator.pushReplacementNamed(
            context,
            '/medicalHome',
          ); // Pharmacy home stub
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    const Text(
                      'Hello',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in to your account',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // Role picker (UI-only; later will be read from backend/claims)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account Type',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _loginRole,
                      items: const [
                        DropdownMenuItem(
                          value: 'patient',
                          child: Text('Patient'),
                        ),
                        DropdownMenuItem(
                          value: 'doctor',
                          child: Text('Doctor'),
                        ),
                        DropdownMenuItem(
                          value: 'medical',
                          child: Text('Medical / Pharmacy'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _loginRole = v),
                      decoration: _inputDecoration(
                        context,
                        hint: 'Select role',
                        icon: Icons.account_circle_outlined,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Select role' : null,
                    ),

                    const SizedBox(height: 16),

                    // Username / Email Field
                    _RoundedInputField(
                      controller: _usernameController,
                      hintText: 'Email or Username',
                      icon: Icons.person_outline,
                      obscureText: false,
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Enter email or username';
                        // Basic email check optional; keep loose for demo
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field with visibility toggle
                    _RoundedInputField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: !_showPass,
                      validator: (v) {
                        final t = v ?? '';
                        if (t.isEmpty) return 'Enter password';
                        if (t.length < 4) return 'Minimum 4 characters';
                        return null;
                      },
                      suffix: IconButton(
                        tooltip: _showPass ? 'Hide' : 'Show',
                        icon: Icon(
                          _showPass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black38,
                        ),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _onForgot,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Forgot your password?',
                          style: TextStyle(color: Colors.black38, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Sign In Button (theme-consistent)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Sign in'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Create account link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                        TextButton(
                          onPressed: _onCreate,
                          child: Text(
                            'Create',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    IconData? icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.black38) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.6),
      ),
    );
  }
}

class _RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _RoundedInputField({
    required this.hintText,
    required this.icon,
    required this.obscureText,
    required this.controller,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black38),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
