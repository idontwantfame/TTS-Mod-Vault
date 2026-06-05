import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void showChangelogDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: AlertDialog(
          title: const Text('Changelog'),
          content: SizedBox(
            width: 1100,
            height: 550,
            child: FutureBuilder<String>(
              future: rootBundle.loadString('CHANGELOG.md'),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final text = snapshot.data ?? 'Could not load changelog.';
                return SingleChildScrollView(
                  child: Text(text, style: const TextStyle(fontSize: 14)),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}
