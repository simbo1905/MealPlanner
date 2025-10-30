import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AttributionScreen extends StatelessWidget {
  const AttributionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attribution'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recipe Dataset',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'This application uses recipe data from:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Original Source: Epicurious.com (Condé Nast)'),
            const Text('• Dataset: Joseph Martinez (recipe-dataset)'),
            const Text('• License: CC BY-SA 3.0'),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('https://creativecommons.org/licenses/by-sa/3.0/');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text(
                'View License Details',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.',
            ),
          ],
        ),
      ),
    );
  }
}
