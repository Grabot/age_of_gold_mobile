import 'package:flutter/material.dart';

class OAuthButtons {
  static Widget buildOAuthButton(
    BuildContext context, {
    required String logoPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.15;
    final maxButtonSize = 100.0;
    final minButtonSize = 50.0;

    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: buttonSize.clamp(minButtonSize, maxButtonSize),
        child: Column(
          children: [
            Container(
              width: buttonSize.clamp(minButtonSize, maxButtonSize),
              height: buttonSize.clamp(minButtonSize, maxButtonSize),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  logoPath,
                  width: buttonSize.clamp(minButtonSize, maxButtonSize) * 0.8,
                  height: buttonSize.clamp(minButtonSize, maxButtonSize) * 0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Responsive font size
                color: const Color(0xff939393),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildOAuthButtonsRow(
    BuildContext context, {
    required List<Map<String, String>> buttons,
    required Function(String) onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children:
            buttons.map((button) {
              return buildOAuthButton(
                context,
                logoPath: button['logoPath']!,
                label: button['label']!,
                onPressed: () => onPressed(button['provider']!),
              );
            }).toList(),
      ),
    );
  }
}
