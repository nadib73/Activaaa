import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Simple Line Chart (untuk Dependence & Screen Time) ─────────────────────
class SimpleLineChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxValue;

  const SimpleLineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.maxValue = 100,
  });

  @override
  State<SimpleLineChart> createState() => _SimpleLineChartState();
}

class _SimpleLineChartState extends State<SimpleLineChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Tentukan indeks yang ditampilkan (default: data terakhir)
    final displayIndex = _selectedIndex ?? (widget.values.isNotEmpty ? widget.values.length - 1 : null);
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Area
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 120,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanUpdate: (details) => _handleTouch(details.localPosition, constraints.maxWidth),
                      onTapDown: (details) => _handleTouch(details.localPosition, constraints.maxWidth),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _LineChartPainter(
                          values: widget.values,
                          color: widget.color,
                          maxValue: widget.maxValue,
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Side Info Panel (Keterangan Skor)
            if (displayIndex != null)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.values[displayIndex].toStringAsFixed(1)}',
                      style: TextStyle(color: widget.color, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      widget.labels[displayIndex],
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              )
            else
              const Expanded(flex: 1, child: SizedBox()),
          ],
        ),
        const SizedBox(height: 12),
        // X-Axis Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.labels.map((l) => Text(l, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10))).toList(),
        ),
      ],
    );
  }

  void _handleTouch(Offset localPosition, double maxWidth) {
    if (widget.values.length < 2) return;
    
    final stepX = maxWidth / (widget.values.length - 1);
    int index = (localPosition.dx / stepX).round().clamp(0, widget.values.length - 1);
    
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double maxValue;
  final int? selectedIndex;

  _LineChartPainter({
    required this.values,
    required this.color,
    required this.maxValue,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final stepX = size.width / (values.length - 1);

    // Draw grid line for selected index
    if (selectedIndex != null) {
      final x = selectedIndex! * stepX;
      final gridPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxValue * size.height).clamp(0, size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = color;
    final bgPaint = Paint()..color = Colors.white;
    final selectedDotPaint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxValue * size.height).clamp(0, size.height);
      
      final isSelected = i == selectedIndex;
      final radius = isSelected ? 6.0 : 4.0;

      if (isSelected) {
        final highlightPaint = Paint()..color = color.withValues(alpha: 0.2);
        canvas.drawCircle(Offset(x, y), radius + 4, highlightPaint);
      }

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
      canvas.drawCircle(Offset(x, y), radius - 2, bgPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => 
    oldDelegate.selectedIndex != selectedIndex || oldDelegate.values != values;
}

// ── Generic Bar Chart (untuk Sosmed & Sleep) ────────────────────────────────
class GenericBarChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxValue;

  const GenericBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    required this.maxValue,
  });

  @override
  State<GenericBarChart> createState() => _GenericBarChartState();
}

class _GenericBarChartState extends State<GenericBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Default tampilkan data terakhir
    final displayIndex = _selectedIndex ?? (widget.values.isNotEmpty ? widget.values.length - 1 : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Area
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.values.length, (i) {
                final hFactor = (widget.values[i] / widget.maxValue).clamp(0.1, 1.0);
                final isSelected = i == _selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _selectedIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? widget.color.withValues(alpha: 0.3) : widget.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: isSelected ? Border.all(color: widget.color, width: 1.5) : null,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: hFactor,
                              widthFactor: 0.6,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: isSelected ? [BoxShadow(color: widget.color.withValues(alpha: 0.4), blurRadius: 8)] : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(widget.labels[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Side Info Panel
        if (displayIndex != null)
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.values[displayIndex].toInt()}',
                  style: TextStyle(color: widget.color, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  widget.labels[displayIndex],
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          )
        else
          const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }
}

// ── Donut Chart (untuk Kategori Rendah/Sedang/Tinggi) ────────────────────────
class DonutChartWidget extends StatelessWidget {
  final int low;
  final int medium;
  final int high;

  const DonutChartWidget({super.key, required this.low, required this.medium, required this.high});

  @override
  Widget build(BuildContext context) {
    final total = low + medium + high;
    if (total == 0) return const Center(child: Text('No data'));

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _DonutPainter(low: low, medium: medium, high: high),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$total',
                  style: const TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'Total',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(AppColors.teal, 'Rendah', low),
              const SizedBox(height: 10),
              _legendItem(AppColors.amber, 'Sedang', medium),
              const SizedBox(height: 10),
              _legendItem(AppColors.red, 'Tinggi', high),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        const Text(
          'x',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int low, medium, high;
  _DonutPainter({required this.low, required this.medium, required this.high});

  @override
  void paint(Canvas canvas, Size size) {
    final total = low + medium + high;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    void drawSegment(int count, Color color) {
      if (count == 0) return;
      final sweepAngle = (count / total) * 2 * math.pi;
      paint.color = color;
      
      // Draw shadow/background for segment
      final bgPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      canvas.drawCircle(center, radius - 8, bgPaint);

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 8), startAngle + 0.05, sweepAngle - 0.1, false, paint);
      startAngle += sweepAngle;
    }

    drawSegment(low, AppColors.teal);
    drawSegment(medium, AppColors.amber);
    drawSegment(high, AppColors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
