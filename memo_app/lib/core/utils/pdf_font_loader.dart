import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service for loading Arabic fonts for PDF generation
///
/// This service handles loading Cairo font TTF files from assets
/// and provides them for use in PDF documents with proper Arabic text rendering.
///
/// Without custom fonts, Arabic text renders as boxes (████) in PDFs.
class PdfFontLoader {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _semiBoldFont;

  static bool _isInitialized = false;

  /// Load all required fonts for PDF generation
  ///
  /// Call this once before generating PDFs.
  /// Returns true if fonts loaded successfully, false if font files are missing.
  ///
  /// Example:
  /// ```dart
  /// final fontsLoaded = await PdfFontLoader.loadFonts();
  /// if (!fontsLoaded) {
  ///   // Fallback: Use default fonts (Arabic will show as boxes)
  /// }
  /// ```
  static Future<bool> loadFonts() async {
    if (_isInitialized) {
      return true; // Already loaded
    }

    try {
      // Load Cairo Regular font
      final regularFontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      _regularFont = pw.Font.ttf(regularFontData);

      // Load Cairo Bold font
      final boldFontData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      _boldFont = pw.Font.ttf(boldFontData);

      // Load Cairo SemiBold font (optional - fallback to Bold if missing)
      try {
        final semiBoldFontData = await rootBundle.load('assets/fonts/Cairo-SemiBold.ttf');
        _semiBoldFont = pw.Font.ttf(semiBoldFontData);
      } catch (_) {
        _semiBoldFont = _boldFont; // Fallback to bold
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      // Font files not found in assets
      print('⚠️ PDF Font Loading Error: Cairo font files not found in assets/fonts/');
      print('   Download fonts from: https://fonts.google.com/specimen/Cairo');
      print('   Required files: Cairo-Regular.ttf, Cairo-Bold.ttf');
      print('   Arabic text in PDFs will render as boxes (████) until fonts are added.');
      return false;
    }
  }

  /// Get the regular Cairo font for PDF
  ///
  /// Returns null if fonts haven't been loaded yet.
  /// Call [loadFonts()] first.
  static pw.Font? get regularFont => _regularFont;

  /// Get the bold Cairo font for PDF
  ///
  /// Returns null if fonts haven't been loaded yet.
  /// Call [loadFonts()] first.
  static pw.Font? get boldFont => _boldFont;

  /// Get the semi-bold Cairo font for PDF
  ///
  /// Returns null if fonts haven't been loaded yet.
  /// Call [loadFonts()] first.
  static pw.Font? get semiBoldFont => _semiBoldFont;

  /// Get a PDF theme with Cairo fonts configured
  ///
  /// Returns a theme with proper Arabic font support.
  /// If fonts aren't loaded, returns a theme with default fonts (Arabic will show as boxes).
  ///
  /// Example:
  /// ```dart
  /// await PdfFontLoader.loadFonts();
  /// final theme = PdfFontLoader.getArabicTheme();
  ///
  /// pdf.addPage(
  ///   pw.MultiPage(
  ///     theme: theme,
  ///     // ...
  ///   ),
  /// );
  /// ```
  static pw.ThemeData getArabicTheme() {
    if (_regularFont != null && _boldFont != null) {
      return pw.ThemeData.withFont(
        base: _regularFont!,
        bold: _boldFont!,
      );
    } else {
      // Return default theme (Arabic will render as boxes)
      return pw.ThemeData.base();
    }
  }

  /// Check if fonts are loaded and ready
  static bool get isReady => _isInitialized && _regularFont != null;

  /// Reset fonts (useful for testing)
  static void reset() {
    _regularFont = null;
    _boldFont = null;
    _semiBoldFont = null;
    _isInitialized = false;
  }
}
