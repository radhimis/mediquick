import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedUserType;

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    SupabaseClientManager.client.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn && mounted) {
        final user = event.session?.user;
        if (user != null) {
          final existingProfile = await SupabaseClientManager.client
              .from('profiles')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();
          if (existingProfile == null) {
            await SupabaseClientManager.client.from('profiles').insert({
              'id': user.id,
              'name': user.userMetadata?['name'] ?? 'Google User',
              'user_type': _selectedUserType ?? 'User',
            });
          }
          _navigateToDashboard();
        }
      }
    });
    // If already signed in, navigate
    if (SupabaseClientManager.client.auth.currentUser != null) {
      _navigateToDashboard();
    }
  }

  Future<void> _navigateToDashboard() async {
    final user = SupabaseClientManager.client.auth.currentUser;
    if (user != null) {
      final profile = await SupabaseClientManager.client
          .from('profiles')
          .select('user_type')
          .eq('id', user.id)
          .single();
      final userType = profile['user_type'] as String;
      if (userType == 'User') {
        Navigator.pushReplacementNamed(context, '/user-dashboard');
      } else if (userType == 'Medical') {
        Navigator.pushReplacementNamed(context, '/medical-dashboard');
      } else if (userType == 'Doctor') {
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
      }
    }
  }

  Future<void> _login() async {
    try {
      final response = await SupabaseClientManager.client.auth
          .signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (response.user != null) {
        // Check if profile exists, if not, create it
        final existingProfile = await SupabaseClientManager.client
            .from('profiles')
            .select('id')
            .eq('id', response.user!.id)
            .maybeSingle();
        if (existingProfile == null) {
          // Insert profile
          await SupabaseClientManager.client.from('profiles').insert({
            'id': response.user!.id,
            'name': response.user!.userMetadata?['name'] ?? 'User',
            'user_type':
                response.user!.userMetadata?['user_type'] ??
                _selectedUserType ??
                'User',
          });
        }
        await _navigateToDashboard();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a user type before signing in with Google.',
          ),
        ),
      );
      return;
    }
    try {
      await SupabaseClientManager.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'medi://login-callback',
      );
      // Navigation and profile creation handled by auth state listener
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 800),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFF1F8E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons.local_hospital,
                            size: 80,
                            color: Color(0xFF1E90FF),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'MediQuick',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E90FF),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your quick medicine delivery solution',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedUserType,
                          items: [
                            DropdownMenuItem(
                              value: 'User',
                              child: Text('User'),
                            ),
                            DropdownMenuItem(
                              value: 'Medical',
                              child: Text('Medical'),
                            ),
                            DropdownMenuItem(
                              value: 'Doctor',
                              child: Text('Doctor'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Type of User',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.work),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1E90FF),
                            padding: EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Login'),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? "),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text('Sign Up'),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text('Forgot Password?'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: Icon(Icons.login),
                          label: Text('Sign in with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
