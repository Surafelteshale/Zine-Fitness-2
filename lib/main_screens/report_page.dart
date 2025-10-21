import 'package:flutter/material.dart';
import 'package:zine_fitness/minor_screens/payment_detail.dart';
import 'package:zine_fitness/minor_screens/user_detail.dart';
import '../utilities/colors.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // from colors.dart
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'Report',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Container(
          color: Colors.white10,
          child: Column(
            children: [
              _buildReportCard(
                icon: Icons.monetization_on,
                title: "የክፍያ መጠን",
                subtitle: "የዚህ ወር የክፍያ መጠን:",
                value: "4000 ብር",
                buttonText: "ሁሉንም ይመልከቱ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentDetail(),
                    ),
                  );
                },
              ),
              _buildReportCard(
                icon: Icons.person_pin,
                title: "የተጠቃሚ መጠን",
                subtitle: "የዚህ ወር አዲስ የተጠቃሚ መጠን:",
                value: "8 ተጠቃሚ",
                // extraSubtitle: "ጠቅላላ ተጠቃሚ:",
                // extraValue: "160 ተጠቃሚ",
                buttonText: "ሁሉንም ይመልከቱ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserDetail(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    String? extraSubtitle,
    String? extraValue,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 300, // 👈 fixed height to make the box smaller
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Subtitle + Value
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.iconGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),

          const Spacer(),

          // Button pinned at bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onTap,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.background,
                      fontWeight: FontWeight.w600,
                    ),
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
