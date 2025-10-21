import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  final List<Map<String, String>> paymentHistory = const [
    {"month": "03/2018", "amount": "4000 ብር"},
    {"month": "02/2018", "amount": "4000 ብር"},
    {"month": "01/2018", "amount": "4000 ብር"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "የተጠቃሚው ዝርዝር",
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// User basic info
            Column(
              children: [
                const Text(
                  "Zine Fitness",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Phone: 123456789",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Gender: Male",
                      style: AppTextStyles.resultText,
                    ),
                    Text(
                      "Age: 32",
                      style: AppTextStyles.resultText,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Category: ብረት",
                      style: AppTextStyles.resultText,
                    ),
                    Text(
                      "Status: Paid",
                      style: AppTextStyles.resultText,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// Payment history title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "የክፍያ ታሪክ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// Payment history scrollable
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListView.separated(
                  itemCount: paymentHistory.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[400]),
                  itemBuilder: (context, index) {
                    final item = paymentHistory[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item["month"]}:',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            item["amount"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
