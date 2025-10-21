import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zine_fitness/auth/login.dart';
import 'package:zine_fitness/main_screens/home_page.dart';
import '../utilities/colors.dart'; // for AppColors & AppTextStyles

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // Delay before showing button
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showButton = true;
        _controller.forward();
      });
    });

    // Slide animation from bottom
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // starts off screen bottom
      end: Offset.zero, // ends in place
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // solid black background
      body: Stack(
        children: [
          /// Background image (scaled to 75%)
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.75, // 75% of screen width
              heightFactor: 0.75, // 75% of screen height
              child: Image.asset(
                "images/logo.jpg",
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// Slide-up button
          if (_showButton)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.1, // ~30% from bottom
                ),
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text(
                      "ቀጥል",
                      style: AppTextStyles.buttonText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
