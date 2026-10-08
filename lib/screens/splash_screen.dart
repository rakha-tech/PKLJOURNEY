import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _timer = Timer(const Duration(milliseconds: 1500), widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(light: true, showWordmark: false),
              const SizedBox(height: 18),
              Text(
                'PKLJOURNEY',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.cream,
                      fontFamily: 'serif',
                      fontSize: 21,
                      letterSpacing: 2.4,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Perjalanan hebat dimulai dari sini',
                style: TextStyle(
                  color: AppColors.cream.withOpacity(0.75),
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}