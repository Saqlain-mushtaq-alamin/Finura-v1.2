import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:finura_frontend/views/defoult/payment.dart';
import 'package:finura_frontend/views/helpPage/help.dart';
import 'package:finura_frontend/views/loninPage/login.dart';
import 'package:finura_frontend/views/setting/P&S.dart';
import 'package:finura_frontend/views/setting/about.dart';
import 'package:flutter/material.dart';

import 'dart:io'; // Required for FileImage

class SettingsPage extends StatefulWidget {
  final String userId;

  const SettingsPage({super.key, required this.userId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final db = await FinuraLocalDbHelper().database;
    final result = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [widget.userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      setState(() {
        userData = result.first;
      });
    }
  }

  // This function returns the appropriate ImageProvider based on the path
  ImageProvider _buildImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('/')) {
      return FileImage(File(path));
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return const AssetImage(
        'assets/default_user/fallback.jpg',
      ); // Fallback image
    }
  }

  Widget _buildUserProfile() {
    if (userData == null) return const SizedBox(height: 80); // Placeholder

    String? userPhotoPath = userData!['user_photo'];

    // Use _buildImageProvider to load the appropriate image
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: _buildImageProvider(userPhotoPath ?? ''),
      ),
      title: Text(
        '${userData!['first_name']} ${userData!['last_name']}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(userData!['email']),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          // Navigate to edit profile
        },
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 164, 245, 171),
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 100,

              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 25, 8.0, 8.0),

                //padding: const EdgeInsets.all(8.0),
                child: _buildUserProfile(),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildSettingOption(
                    icon: Icons.account_circle,
                    title: 'Account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentPage(), // Navigate to PaymentPage
                        ),
                      );
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentPage(), // Navigate to PaymentPage
                        ),
                      );
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.settings,
                    title: 'App Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentPage(), // Navigate to PaymentPage
                        ),
                      );
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.storage,
                    title: 'Data Management',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentPage(), // Navigate to PaymentPage
                        ),
                      );
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.support_agent,
                    title: 'Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GetHelpPage()),
                      );
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.shield,
                    title: 'Privacy & Security',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PrivacyAndSecuritySettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
