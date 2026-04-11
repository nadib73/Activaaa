import 'package:flutter/material.dart';

class AnalisisData {
  final int number;
  final String day;
  final String month;
  final int focus;
  final int prod;
  final int dep;
  final bool depHigh;
  final String? note;
  final Color? noteColor;

  const AnalisisData({
    required this.number,
    required this.day,
    required this.month,
    required this.focus,
    required this.prod,
    required this.dep,
    required this.depHigh,
    this.note,
    this.noteColor,
  });
}
