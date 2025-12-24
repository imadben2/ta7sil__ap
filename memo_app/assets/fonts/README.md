# Fonts Directory

This directory contains font files used for PDF generation with proper Arabic text rendering.

## Required Fonts for PDF Export

To fix the Arabic text rendering in PDF exports (currently showing as boxes ████), you need to add the **Cairo** font files here:

### Files Needed:
- `Cairo-Regular.ttf`
- `Cairo-Bold.ttf`
- `Cairo-SemiBold.ttf` (optional)

### Where to Download:
1. **Google Fonts:** https://fonts.google.com/specimen/Cairo
2. **Direct Download:** Download the font family ZIP file
3. Extract and copy the `.ttf` files to this directory

### After Adding Fonts:
1. Ensure the files are named exactly as specified above
2. Run `flutter pub get` to refresh assets
3. Run `flutter clean` then rebuild the app
4. The PDF export will now render Arabic text properly

### Current Usage:
- Planner Schedule PDF Export (`planner_main_screen.dart`)
- Session History PDF Export (`session_history_screen.dart`)
- BAC exam PDFs (viewer only, uses external PDFs)
- Course certificates (if implemented)

### Note:
The Cairo font is used throughout the app UI via `google_fonts` package, but PDF generation requires local `.ttf` files because the `pdf` package cannot use web fonts.
