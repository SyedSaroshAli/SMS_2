import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  /// Optional overrides — pass your screen's own launch functions here.
  /// When null, the widget launches URLs directly via url_launcher.
  final VoidCallback? onWebsiteTap;
  final VoidCallback? onPhoneTap;

  const AppFooter({super.key, this.onWebsiteTap, this.onPhoneTap});

  static const String _website = 'https://www.kisoftwaressolutions.com';
  static const String _websiteDisplay = 'www.kisoftwaressolutions.com';
  static const String _phone = '+92 3197617561';
  static const String _phoneTel = 'tel:+923197617561';

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final textColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final linkColor = isDark ? Colors.blue[300]! : Colors.blue[700]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: isDark ? Colors.grey[900] : Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onWebsiteTap ?? () => _launch(_website),
                child: Text(
                  _websiteDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: linkColor,
                    decoration: TextDecoration.underline,
                    decorationColor: linkColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('|', style: TextStyle(color: textColor, fontSize: 12)),
              ),
              GestureDetector(
                onTap: onPhoneTap ?? () => _launch(_phoneTel),
                child: Text(
                  _phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: linkColor,
                    decoration: TextDecoration.underline,
                    decorationColor: linkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
