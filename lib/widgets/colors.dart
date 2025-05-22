import 'package:flutter/material.dart';

class ColorUtils {
  // Get a consistent color based on a username
  static Color getAvatarColor(String name) {
    final List<Color> colors = [
      const Color(0xFF25D366), // WhatsApp light green
      const Color(0xFF34B7F1), // WhatsApp blue
      const Color(0xFFFFA726), // Orange
      const Color(0xFFAB47BC), // Purple
    ];

    // Simple hash function to get consistent colors
    int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
  }

  // Get progress bar color based on username
  static Color getProgressColor(String name) {
    final List<Color> colors = [
      const Color(0xFF25D366), // WhatsApp light green
      const Color(0xFF34B7F1), // WhatsApp blue
      const Color(0xFFFFA726), // Orange
      const Color(0xFFAB47BC), // Purple
    ];

    int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
  }

  // WhatsApp theme colors for easy access
  static const Color whatsappLightGreen = Color(0xFF25D366);
  static const Color whatsappDarkGreen = Color(0xFF075E54);
  static const Color whatsappSecondaryText = Color(0xFF667781);
  static const Color whatsappTextColor = Color(0xFF1F2C34);
  static const Color whatsappLightBackground = Color.fromARGB(255, 255, 255, 255);
  static const Color whatsappDivider = Color(0xFFDCE6E7);
}