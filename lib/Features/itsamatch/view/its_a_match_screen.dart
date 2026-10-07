import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';

class ItsAMatchScreen extends StatelessWidget {
  final String matchedName;
  // final String matchImage; // Combined image from your design -> Images.itsAMatch

  const ItsAMatchScreen({
    super.key,
    required this.matchedName,
    // required this.matchImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.scaffoldColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // MATCHED COMBINED IMAGE (your given asset)
                Image.asset(Images.itsAMatch, height: 350, fit: BoxFit.contain),

                const SizedBox(height: 30),

                // TITLE
                Text(
                  "It's a match, $matchedName",
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 40),

                // Say Hello Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to chat screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Say hello",
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Keep Swiping
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Keep Swiping",
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
