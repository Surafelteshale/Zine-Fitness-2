import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class UserInfo extends StatelessWidget {
  final String userId; // 🔹 Get from the previous screen
  const UserInfo({super.key, required this.userId});

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User') // ✅ your correct collection
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['name'] ?? 'Unknown';
          final phone = userData['phone'] ?? '—';
          final gender = userData['gender'] ?? '—';
          final age = userData['age']?.toString() ?? '—';
          final category = userData['category'] ?? '—';
          final status = userData['status'] == true ? 'ተከፍሏል' : 'አልተከፈለም';
          final payments = List<Map<String, dynamic>>.from(userData['payments'] ?? []).reversed.toList();


          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 🔹 User basic info
                Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ስልክ: $phone",
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ጾታ: $gender", style: AppTextStyles.resultText),
                        Text("ዕድሜ: $age", style: AppTextStyles.resultText),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ክፍል: $category", style: AppTextStyles.resultText),
                        Text("ክፍያ: $status", style: AppTextStyles.resultText.copyWith(
                          color: status == 'ተከፍሏል' ? Colors.green : Colors.red,
                        )),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// 🔹 Payment history title
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

                /// 🔹 Payment history list
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.fieldFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: payments.isEmpty
                        ? const Center(
                      child: Text(
                        "ክፍያ ታሪክ የለም።",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                        : ListView.separated(
                      itemCount: payments.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey[400]),
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        final displayDate =
                            payment['displayDay'] ?? '—';
                        final amount = payment['amount']?.toString() ?? '—';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                displayDate,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "$amount ብር",
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
          );
        },
      ),
    );
  }
}
