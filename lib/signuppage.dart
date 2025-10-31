import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String? _role; // 'patient' | 'doctor' | 'medical'
  bool _showPass = false;
  bool _showConfirm = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) return;

    if (_role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account type')),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Privacy')),
      );
      return;
    }

    // For now: emulate success and return data to previous screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _role,
      });
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Role picker
                  _Labeled(
                    label: 'Account Type',
                    child: DropdownButtonFormField<String>(
                      value: _role,
                      items: const [
                        DropdownMenuItem(value: 'patient', child: Text('Patient')),
                        DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                        DropdownMenuItem(value: 'medical', child: Text('Medical / Pharmacy')),
                      ],
                      decoration: _inputDecoration(context, hint: 'Select role'),
                      onChanged: (v) => setState(() => _role = v),
                      validator: (v) => (v == null || v.isEmpty) ? 'Select your role' : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  _Labeled(
                    label: 'Full Name',
                    child: TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(context, hint: 'Full Name', icon: Icons.person_outline),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Name is required';
                        if (t.length < 2) return 'Enter a valid name';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _Labeled(
                    label: 'Email',
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(context, hint: 'name@example.com', icon: Icons.email_outlined),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
                        if (t.isEmpty) return 'Email is required';
                        if (!emailRegex.hasMatch(t)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Password
                  _Labeled(
                    label: 'Password',
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPass,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        context,
                        hint: 'Minimum 6 characters',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          tooltip: _showPass ? 'Hide' : 'Show',
                          icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
                          onPressed: () => setState(() => _showPass = !_showPass),
                        ),
                      ),
                      validator: (v) {
                        final t = v ?? '';
                        if (t.isEmpty) return 'Password is required';
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
                      controller: _confirmPassController,
                      obscureText: !_showConfirm,
                      decoration: _inputDecoration(
                        context,
                        hint: 'Re-enter password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          tooltip: _showConfirm ? 'Hide' : 'Show',
                          icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
                          onPressed: () => setState(() => _showConfirm = !_showConfirm),
                        ),
                      ),
                      validator: (v) {
                        if ((v ?? '').isEmpty) return 'Please confirm password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Terms
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                        activeColor: cs.primary, // will be 0xFF0017A8 via theme
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms & Privacy Policy',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Sign up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,     // 0xFF0017A8 via theme
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Back to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(fontSize: 15, color: Colors.black87)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Sign in', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {required String hint, IconData? icon, Widget? suffixIcon}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.black45) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary.withOpacity(0.2)), // themed border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.6),      // themed border
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
