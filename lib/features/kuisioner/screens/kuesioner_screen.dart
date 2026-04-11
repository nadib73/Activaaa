import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/role_option.dart';
import '../../hasil_prediksi/screens/hasil_prediksi_screen.dart';

class KuesionerScreen extends StatefulWidget {
  const KuesionerScreen({super.key});

  @override
  State<KuesionerScreen> createState() => _KuesionerScreenState();
}

class _KuesionerScreenState extends State<KuesionerScreen> {
  double _sliderValue = 5.5;
  int _selectedRoleIndex = 0;

  static const _roles = [
    'Pelajar / Mahasiswa',
    'Karyawan / Pekerja',
    'Wirausaha',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestion8(),
                    const SizedBox(height: 32),
                    _buildQuestion9(),
                  ],
                ),
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackRow(),
          const SizedBox(height: 14),
          _buildProgressBar(),
          const SizedBox(height: 6),
          _buildProgressLabel(),
        ],
      ),
    );
  }

  Widget _buildBackRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textDark,
            size: 22,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Kuesioner Gaya Hidup',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: 8 / 12,
        backgroundColor: Colors.grey.shade200,
        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
        minHeight: 6,
      ),
    );
  }

  Widget _buildProgressLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Jawab dengan jujur untuk hasil yang akurat',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        Text(
          '8 / 12',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Question 8 ─────────────────────────────────────────────────────────────

  Widget _buildQuestion8() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionLabel('PERTANYAAN 8'),
        const SizedBox(height: 8),
        const Text(
          'Berapa jam kamu menggunakan perangkat per hari?',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _buildSliderValue(),
        _buildSlider(),
        _buildSliderLabels(),
      ],
    );
  }

  Widget _buildSliderValue() {
    return Text(
      '${_sliderValue.toStringAsFixed(1)} jam',
      style: const TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.teal,
        inactiveTrackColor: Colors.grey.shade200,
        thumbColor: AppColors.teal,
        overlayColor: AppColors.teal.withValues(alpha: 0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        trackHeight: 6,
      ),
      child: Slider(
        value: _sliderValue,
        min: 0,
        max: 12,
        divisions: 24,
        onChanged: (v) => setState(() => _sliderValue = v),
      ),
    );
  }

  Widget _buildSliderLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '0 jam',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
        Text(
          '12 jam',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }

  // ── Question 9 ─────────────────────────────────────────────────────────────

  Widget _buildQuestion9() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionLabel('PERTANYAAN 9'),
        const SizedBox(height: 8),
        const Text(
          'Apa peran utama kamu sehari-hari?',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(
          _roles.length,
          (i) => RoleOption(
            label: _roles[i],
            isSelected: _selectedRoleIndex == i,
            onTap: () => setState(() => _selectedRoleIndex = i),
          ),
        ),
      ],
    );
  }

  // ── Bottom Button ──────────────────────────────────────────────────────────

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: AppColors.bgWhite,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HasilPrediksiScreen()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Lanjut',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildQuestionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.teal,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
