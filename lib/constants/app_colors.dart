import 'package:flutter/material.dart';

// ─── Brand Colors ──────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary Palette — Blush Pink
  static const Color primary = Color(0xFFE8A0BF);
  static const Color primaryDark = Color(0xFFD4739F);
  static const Color primaryLight = Color(0xFFF5CFDF);

  // Secondary — Lavender
  static const Color secondary = Color(0xFFBCA8D4);
  static const Color secondaryDark = Color(0xFF9B86C0);
  static const Color secondaryLight = Color(0xFFDDD5EC);

  // Accent — Soft Teal
  static const Color accent = Color(0xFF7EC8C8);
  static const Color accentDark = Color(0xFF5AADAD);
  static const Color accentLight = Color(0xFFB5E3E3);

  // Cycle Phase Colors
  static const Color phaseMenstrual = Color(0xFFE8A0BF);    // Blush
  static const Color phaseFollicular = Color(0xFF98D4A3);   // Sage Green
  static const Color phaseOvulation = Color(0xFF7EC8C8);    // Teal
  static const Color phaseLuteal = Color(0xFFBCA8D4);       // Lavender

  // Light Mode Surfaces
  static const Color background = Color(0xFFFFF5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8EEF3);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Dark Mode
  static const Color darkBackground = Color(0xFF1A1025);
  static const Color darkSurface = Color(0xFF2A1F35);
  static const Color darkSurfaceVariant = Color(0xFF3A2D4A);
  static const Color darkCard = Color(0xFF2F2340);

  // Text
  static const Color textPrimary = Color(0xFF2D1F3A);
  static const Color textSecondary = Color(0xFF7A6B8A);
  static const Color textHint = Color(0xFFBBAEC8);
  static const Color textOnDark = Color(0xFFF5EEF8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF6BC98A);
  static const Color warning = Color(0xFFF5C97A);
  static const Color error = Color(0xFFE87070);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8A0BF), Color(0xFFBCA8D4)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2A1F35), Color(0xFF1A1025)],
  );

  static const LinearGradient menstrualGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4739F), Color(0xFFAD4070)], // pink.shade400 → pink.shade700
  );
  static const LinearGradient follicularGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5FAD6A), Color(0xFF3D8A4A)], // darker sage green
  );
  static const LinearGradient ovulationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4AADAD), Color(0xFF2D8A8A)], // darker teal
  );
  static const LinearGradient lutealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B86C0), Color(0xFF6B5A95)], // darker lavender
  );

  static LinearGradient phaseGradient(String phase) {
    switch (phase) {
      case 'menstrual': return menstrualGradient;
      case 'follicular': return follicularGradient;
      case 'ovulation': return ovulationGradient;
      case 'luteal': return lutealGradient;
      default: return primaryGradient;
    }
  }

  static Color phaseColor(String phase) {
    switch (phase) {
      case 'menstrual': return phaseMenstrual;
      case 'follicular': return phaseFollicular;
      case 'ovulation': return phaseOvulation;
      case 'luteal': return phaseLuteal;
      default: return primary;
    }
  }
}
