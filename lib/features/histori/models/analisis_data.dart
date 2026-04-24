import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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

/// Extension untuk convert MlResultModel → AnalisisData
extension AnalisisDataConverter on AnalisisData {
  static AnalisisData fromMlResult(dynamic mlResult) {
    return AnalisisData(
      number: mlResult.dependenceInt,
      day: mlResult.dayStr,
      month: mlResult.monthStr,
      focus: mlResult.focusInt,
      prod: mlResult.productivityInt,
      dep: mlResult.dependenceInt,
      depHigh: mlResult.highRiskFlag,
      note: mlResult.riskLabel,
      noteColor: mlResult.highRiskFlag ? AppColors.red : AppColors.teal,
    );
  }
}
