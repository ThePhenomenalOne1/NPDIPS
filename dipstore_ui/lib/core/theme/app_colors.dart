import 'package:flutter/material.dart';

class AppColors {
  // ✨ MODERN SIMPLIFIED PALETTE ✨
  // Primary: Deep Blue (Professional, Clean)
  static const primary = Color(0xFF1E3A8A);        // Deep Blue
  static const primaryDark = Color(0xFF1E40AF);    // Slightly Lighter
  static const primaryLight = Color(0xFF3B82F6);   // Bright Blue (accents)

  // Accent: Vibrant Orange (Energy, CTA)
  static const accent = Color(0xFFF97316);         // Modern Orange
  static const accentLight = Color(0xFFFEBCAA);    // Light Orange (hover states)

  // Backgrounds (Cleaner, More Minimal)
  static const bgLight = Color(0xFFFAFAFA);        // Almost White
  static const bgDark = Color(0xFF0F172A);         // Deep Blue-Black

  // Surfaces (Pure & Clean)
  static const surfaceLight = Color(0xFFFFFFFF);   // Pure White
  static const surfaceDark = Color(0xFF1E293B);    // Dark Slate

  // Typography (High Contrast, Clear)
  static const textMainLight = Color(0xFF0F172A);  // Almost Black
  static const textSubLight = Color(0xFF64748B);   // Medium Gray
  static const textMainDark = Color(0xFFF1F5F9);   // Almost White
  static const textSubDark = Color(0xFFCBD5E1);    // Light Gray

  // Borders & Dividers (Subtle)
  static const borderLight = Color(0xFFE2E8F0);    // Light Gray
  static const borderDark = Color(0xFF334155);     // Dark Gray

  // Semantic Colors (Unchanged - Good for Alerts)
  static const success = Color(0xFF10B981);        // Green
  static const error = Color(0xFFEF4444);          // Red
  static const warning = Color(0xFFFBBF24);        // Amber (brighter)
  static const info = Color(0xFF0EA5E9);           // Sky Blue

  // Legacy Support
  static const kGold = Color(0xFFF97316);          // Orange (modern replacement)

  // Splash Gradient (Updated)
  static const splashTop = Color(0xFF3B82F6);      // Blue
  static const splashBottom = Color(0xFF1E3A8A);   // Deep Blue
}
