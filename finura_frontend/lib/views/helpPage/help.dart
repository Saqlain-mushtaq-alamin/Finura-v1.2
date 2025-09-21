import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GetHelpPage extends StatefulWidget {
  @override
  _GetHelpPageState createState() => _GetHelpPageState();
}

class _GetHelpPageState extends State<GetHelpPage> {
  final TextEditingController _textController = TextEditingController();

  final String phoneNumber = '+1234567890'; // <-- Replace with your number
  final String emailAddress =
      'support@example.com'; // <-- Replace with your email

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch phone dialer')));
    }
  }

  void _sendEmail() async {
    final String message = _textController.text.trim();
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: Uri.encodeFull('subject=Help Request&body=$message'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open email app')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 116, 228),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Align(alignment: Alignment.centerLeft, child: Text('Get Help')),
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: _makePhoneCall),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 75, 114, 187), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/gif/help.gif',
              height: 400,
              width: double.infinity,
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),

            //Icon(FontAwesomeIcons.userHeadset, size: 32.0, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'How can we help you?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 35),

            // Your TextField and button go here
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(onPressed: _sendEmail, child: Text('Submit')),

            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
