import 'package:flutter/material.dart';

InputDecoration buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 1)),
      ],
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
    ),
    hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
  );
}
