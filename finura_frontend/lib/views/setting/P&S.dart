import 'package:finura_frontend/views/defoult/payment.dart';
import 'package:flutter/material.dart';

class PrivacyAndSecuritySettingsPage extends StatelessWidget {
  // The buildSettingOption function
  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.green[800], // Customize your app bar color
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Using _buildSettingOption for Privacy & Security setting
          _buildSettingOption(
            icon: Icons.shield,
            title: 'Privacy & Security',
            onTap: () {
              // Navigate to the Privacy & Security page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentPage()),
              );
            },
          ),

          // Using _buildSettingOption for Change PIN setting
          _buildSettingOption(
            icon: Icons.lock,
            title: 'Change PIN',
            onTap: () {
              // Navigate to the Change PIN page
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => ChangePinPage(),
                  builder: (context) => PaymentPage(),
                ),
              );
            },
          ),

          // Using _buildSettingOption for View Login History
          _buildSettingOption(
            icon: Icons.history,
            title: 'View Login History',
            onTap: () {
              // Navigate to the Login History page
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => LoginHistoryPage(),
                  builder: (context) => PaymentPage(),
                ),
              );
            },
          ),

          // Using _buildSettingOption for Clear App Data
          _buildSettingOption(
            icon: Icons.delete_forever,
            title: 'Clear App Data',
            onTap: () {
              // Handle clearing app data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentPage(), // Navigate to PaymentPage
                ),
              );
            },
          ),

          // Using _buildSettingOption for Delete Account
          _buildSettingOption(
            icon: Icons.delete,
            title: 'Delete Account',
            onTap: () {
              _showDeleteConfirmationDialog(context);
            },
          ),

          // Using _buildSettingOption for Privacy Policy
          _buildSettingOption(
            icon: Icons.description,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to the Privacy Policy page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentPage(), // Navigate to PaymentPage
                ),
              );
            },
          ),

          // Using _buildSettingOption for Terms of Service
          _buildSettingOption(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              // Navigate to the Terms of Service page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentPage(), // Navigate to PaymentPage
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Method to show delete account confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("This will permanently delete your account."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dismiss the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Call your delete account method here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentPage(), // Navigate to PaymentPage
                ),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class ChangePinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change PIN')),
      body: Center(child: const Text('Change your PIN here.')),
    );
  }
}

class LoginHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login History')),
      body: Center(child: const Text('View your login history here.')),
    );
  }
}
