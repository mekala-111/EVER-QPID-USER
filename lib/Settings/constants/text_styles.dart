import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle getTextStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
}) {
  // Use the family names google_fonts actually registers — string labels like
  // 'Noto Sans Telugu' never match and Flutter still logs the missing-glyphs warning.
  final telugu = GoogleFonts.notoSansTelugu();
  final noto = GoogleFonts.notoSans();
  return GoogleFonts.poppins(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
  ).copyWith(
    fontFamilyFallback: [
      if (telugu.fontFamily != null) telugu.fontFamily!,
      if (noto.fontFamily != null) noto.fontFamily!,
    ],
  );
}
