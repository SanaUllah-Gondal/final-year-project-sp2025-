import 'package:flutter/material.dart';

class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Terms'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'At Skill-Link, we prioritize the privacy of our users. All personal data including names, addresses, and contact information are securely stored and never shared with third parties without explicit consent.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Location Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We use your location to help you find nearby electricians, plumbers, and cleaners. This data is only used while the app is active and with your permission.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'By using Skill-Link, you agree to the following terms:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              '- You are at least 18 years of age.\n'
              '- You will use the app only for lawful services.\n'
              '- You will treat all service providers with respect.\n'
              '- You agree to pay the service provider the agreed amount for their services.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Skill-Link is a platform that connects users to professionals but does not take responsibility for any disputes between users and service providers. We encourage honest reviews and fair dealings.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
