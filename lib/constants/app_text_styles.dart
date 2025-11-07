import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading(double size,
      {Color color = Colors.black, FontWeight weight = FontWeight.bold}) =>
      GoogleFonts.firaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle subHeading(double size,
      {Color color = Colors.black, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.firaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle body(double size,
      {Color color = Colors.black, FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.firaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle button(double size,
      {Color color = Colors.white, FontWeight weight = FontWeight.bold}) =>
      GoogleFonts.firaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}
