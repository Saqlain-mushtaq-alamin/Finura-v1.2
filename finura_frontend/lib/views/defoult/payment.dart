import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment"), centerTitle: false),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            children: [
              // Image at the top
              Image.asset(
                'assets/gif/payment.gif',
                height: 500,
                width: double.infinity,
                alignment: Alignment.center,

                fit: BoxFit.cover,
              ),
              const SizedBox(height: 24),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 25),
                child: Text(
                  'Premium vibes only...',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              const SizedBox(height: 12),

              // Text below the image
              const Text(
                'Gotta drop some coins to unlock this 🔓💸',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Button with back icon
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Goes back to previous page
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Go Back"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
