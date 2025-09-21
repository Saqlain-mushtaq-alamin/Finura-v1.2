import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget {
  Future<String> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // App version
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // App Version Section
            FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasData) {
                  return ListTile(
                    leading: Icon(Icons.info, color: Colors.green[800]),
                    title: Text('App Version'),
                    subtitle: Text(snapshot.data!),
                  );
                } else {
                  return const ListTile(
                    title: Text('App Version'),
                    subtitle: Text('Unknown'),
                  );
                }
              },
            ),

            const Divider(),

            // Developer Info Section
            ListTile(
              leading: Icon(Icons.person, color: Colors.green[800]),
              title: const Text('Developer'),
              subtitle: const Text('Saqlain Mushtaq Al Amin'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.green[800]),
              title: const Text('Contact Email'),
              subtitle: const Text('saqlainmushtaqal@gamil.com'),
              onTap: () {
                // Open email client (email app)
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.green[800]),
              title: const Text('Website'),
              subtitle: const Text(''),
              onTap: () {
                // Open the website in the browser
              },
            ),

            const Divider(),

            // Licenses Section (If needed)
            ListTile(
              leading: Icon(Icons.verified_user, color: Colors.green[800]),
              title: const Text('Licenses'),
              onTap: () {
                // Navigate to the Licenses page or show licenses dialog
              },
            ),

            const Divider(),

            // Privacy Policy Section
            ListTile(
              leading: Icon(Icons.security, color: Colors.green[800]),
              title: const Text('Privacy Policy'),
              onTap: () {
                // Navigate to the Privacy Policy page
              },
            ),

            // Terms of Service Section
            ListTile(
              leading: Icon(Icons.description, color: Colors.green[800]),
              title: const Text('Terms of Service'),
              onTap: () {
                // Navigate to the Terms of Service page
              },
            ),

            const Divider(),

            // Rate the App Section
            ListTile(
              leading: Icon(Icons.star, color: Colors.green[800]),
              title: const Text('Rate the App'),
              onTap: () {
                // Open app store page for rating (can use a package like 'url_launcher')
              },
            ),
          ],
        ),
      ),
    );
  }
}
