import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnalisisData {
  final int number;
  final String day;
  final String month;
  final int dep;
  final String category;
  final double confidence;
  final String? note;
  final Color? noteColor;

  const AnalisisData({
    required this.number,
    required this.day,
    required this.month,
    required this.dep,
    required this.category,
    required this.confidence,
    this.note,
    this.noteColor,
  });
}

/// Extension untuk convert MlResultModel → AnalisisData
extension AnalisisDataConverter on AnalisisData {
  static AnalisisData fromMlResult(dynamic mlResult) {
    final isHighRisk = mlResult.category.toLowerCase() == 'tinggi';
    return AnalisisData(
      number: mlResult.dependenceInt,
      day: mlResult.dayStr,
      month: mlResult.monthStr,
      dep: mlResult.dependenceInt,
      category: mlResult.category,
      confidence: mlResult.confidence,
      note: mlResult.riskLevel,
      noteColor: isHighRisk ? AppColors.red : AppColors.teal,
    );
  }
}
