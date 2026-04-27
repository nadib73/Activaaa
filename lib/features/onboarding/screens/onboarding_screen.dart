import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/dot_indicator.dart';
import '../../auth/screens/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 210, 220, 234),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildIconBox(),
              const Spacer(flex: 2),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildSubtitle(),
              const Spacer(flex: 2),
              const DotIndicator(totalDots: 3, activeIndex: 0),
              const Spacer(),
              _buildPrimaryButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    return SvgPicture.asset(
      'assets/images/NewLogoBiru.svg',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Kenali Gaya Hidup\nDigitalmu',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(255, 9, 9, 9),
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Analisis kebiasaan digital kamu\ndan dapatkan insight personal\nberbasis AI untuk produktivitas\nlebih baik.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(255, 8, 10, 12),
        fontSize: 15,
        height: 1.6,
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
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
          'Mulai Sekarang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
