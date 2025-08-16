import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  // ... no changes needed here ...
  const AboutView({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch via url_launcher';
      }
    } catch (e) {
      if (Platform.isAndroid) {
        await AndroidIntent(action: 'action_view', data: url).launch();
      } else {
        debugPrint('Could not launch $url: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder to make padding and font sizes responsive
    return LayoutBuilder(
      builder: (context, constraints) {
        final double padding = (constraints.maxWidth * 0.05).clamp(16.0, 32.0);
        final double titleSize = (constraints.maxWidth * 0.12).clamp(
          40.0,
          60.0,
        );
        final double questionSize = (constraints.maxWidth * 0.05).clamp(
          18.0,
          24.0,
        );
        final double answerSize = (constraints.maxWidth * 0.04).clamp(
          15.0,
          20.0,
        );

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                Text(
                  'About',
                  style: GoogleFonts.bangers(
                    fontSize: titleSize,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Made with ❤️ by Tahir",
                  style: GoogleFonts.kalam(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                // Re-using the original QA item structure but with responsive fonts
                _qaItem(
                  "What is LoudCast?",
                  Text(
                    "LoudCast is a Neo-Brutalist style weather application that gives you real-time weather updates in a bold, minimalistic, and fun design.",
                    style: GoogleFonts.kalam(
                      fontSize: answerSize,
                      color: Colors.black,
                    ),
                  ),
                  questionSize,
                ),
                _qaItem(
                  "Developer",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi! I'm Tahir Hassan, a Flutter developer with a passion for creating bold, minimalistic apps in Neo-Brutalist style. I love experimenting with animations, Lottie integrations, and custom UI designs to make weather apps fun and interactive.",
                        style: GoogleFonts.kalam(
                          fontSize: answerSize,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () =>
                            _openUrl("https://github.com/tahirdotdev-tdd"),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FontAwesomeIcons.github, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "View my GitHub Profile",
                              style: GoogleFonts.kalam(
                                fontSize: answerSize,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openUrl("https://bit.ly/tahirhassan"),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FontAwesomeIcons.user, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "View my Portfolio",
                              style: GoogleFonts.kalam(
                                fontSize: answerSize,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  questionSize,
                ),
                // ... other qaItems ...
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _qaItem(String question, Widget answer, double questionSize) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(4, 4)),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textAlign: TextAlign.start,
            question,
            style: GoogleFonts.bangers(
              fontSize: questionSize,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          answer,
        ],
      ),
    );
  }
}
