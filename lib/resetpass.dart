import 'package:flutter/material.dart';

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  State<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showPass = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password successfully reset!')),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // reads 0xFF0017A8 from app theme [2][1]

    // Optional email from previous screen
    String? email;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['email'] is String) {
      email = args['email'] as String;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email != null ? 'Resetting for $email' : 'Enter your new password below',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  // New Password
                  _Labeled(
                    label: 'New Password',
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPass,
                      decoration: _inputDecoration(
                        context,
                        hint: 'Minimum 6 characters',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          tooltip: _showPass ? 'Hide' : 'Show',
                          icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
                          onPressed: () => setState(() => _showPass = !_showPass),
                        ),
                      ),
                      validator: (v) {
                        final t = v ?? '';
                        if (t.isEmpty) return 'Please enter a password';
                        if (t.length < 6) return 'Use at least 6 characters';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password
                  _Labeled(
                    label: 'Confirm Password',
                    child: TextFormField(
                      controller: _confirmController,
                      obscureText: !_showConfirm,
                      decoration: _inputDecoration(
                        context,
                        hint: 'Re-enter password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          tooltip: _showConfirm ? 'Hide' : 'Show',
                          icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
                          onPressed: () => setState(() => _showConfirm = !_showConfirm),
                        ),
                      ),
                      validator: (v) {
                        if ((v ?? '').isEmpty) return 'Please confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reset Password Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,      // themed to 0xFF0017A8 [2]
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Back to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already reset? ', style: TextStyle(fontSize: 15)),
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,            // themed link color [2]
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
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {required String hint, IconData? icon, Widget? suffix}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.black45) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary.withOpacity(0.2)), // themed border [2]
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.6),       // themed border [2]
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
