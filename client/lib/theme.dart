import 'package:flutter/material.dart';

const Color kAccent = Color(0xFF10B981);
const Color kAccentSoft = Color(0xFFE7F7F0);
const Color kAccentInk = Color(0xFF047857);
const Color kInk = Color(0xFF0F1A16);
const Color kInk2 = Color(0xFF4B5C55);
const Color kInk3 = Color(0xFF8A9C94);
const Color kBg = Color(0xFFFFFFFF);
const Color kSurface = Color(0xFFF9FAFB);
const Color kSurface2 = Color(0xFFF1F5F3);
const Color kLine = Color(0xFFE4EDE9);

TextStyle kHeading(double size, {Color color = kInk}) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w800,
    letterSpacing: size * -0.03,
    color: color,
    height: 1.08);

TextStyle kBody(double size, {Color color = kInk2, FontWeight weight = FontWeight.w500}) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.5);

TextStyle kMono(double size, {Color color = kInk3}) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    fontFamily: 'monospace',
    color: color);

TextStyle kLabel() => kMono(11.5).copyWith(letterSpacing: 1.2, color: kInk3);
