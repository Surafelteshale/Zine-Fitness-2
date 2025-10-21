import 'package:flutter/material.dart';
import 'package:zine_fitness/utilities/colors.dart';

class Payment extends StatelessWidget {
  const Payment({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ክፍያ',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Section
            Container(
              height: size.height * 0.23,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoRow("ስም፡", "ሱራፌል ተሻለ"),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text("ክፍያ:", style: AppTextStyles.resultText),
                      SizedBox(width: 8),
                      Text(
                        "ያልከፈለ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildUserInfoRow("የመጨረሻው የተከፈለበት ቀን:", "12/08/2017"),
                  const SizedBox(height: 12),
                  _buildUserInfoRow("የተጠቃሚ ምድብ:", "ብረት"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date Field 1
            _buildTextField(
              label: "ቀን",
              hint: "ቀን ያስገቡ",
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: 16),

            // Payment Amount
            _buildTextField(
              label: "የክፍያ መጠን",
              hint: "መጠን ያስገቡ",
              icon: Icons.monetization_on,
            ),

            const SizedBox(height: 120),

            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // handle payment logic
                },
                child: const Text(
                  "ክፈል",
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.resultText),
        const SizedBox(width: 8),
        Text(value, style: AppTextStyles.resultText),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            hintText: hint,
            hintStyle: AppTextStyles.hintTextStyle,
            prefixIcon: Icon(icon, color: AppColors.iconGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
