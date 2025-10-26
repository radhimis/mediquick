import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Mock loading profile data (in real app, fetch from Supabase)
      _nameController.text = 'John Doe'; // Replace with actual data
      _emailController.text = user.email ?? '';
      _phoneController.text = '9876543210'; // Replace with actual data
      _addressController.text = '123 Main St'; // Replace with actual data
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Mock update (in real app, update Supabase)
      await Future.delayed(Duration(seconds: 1));
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }
  }

  void _changePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all password fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password changed successfully')));
      _oldPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error changing password: $e')));
    }
  }

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Mock delete (in real app, delete from Supabase)
      await Supabase.instance.client.auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Settings'),
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Name'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your name'
                                : null,
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: 'Email'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your email'
                                : null,
                          ),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(labelText: 'Phone'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your phone'
                                : null,
                          ),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(labelText: 'Address'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your address'
                                : null,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            child: Text('Update Profile'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: _oldPasswordController,
                      decoration: InputDecoration(labelText: 'Old Password'),
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(labelText: 'New Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _changePassword,
                      child: Text('Change Password'),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Notification Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SwitchListTile(
                      title: Text('Enable Notifications'),
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _logout,
                      child: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _deleteAccount,
                      child: Text('Delete Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
