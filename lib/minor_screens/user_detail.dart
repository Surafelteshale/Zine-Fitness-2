import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utilities/colors.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({super.key});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'የተጠቃሚ ዝርዝር',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 🔥 Use StreamBuilder to read directly from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('MonthlyStats')
            .orderBy(FieldPath.documentId, descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("ምንም ውሂብ አልተገኘም።"),
            );
          }

          final docs = snapshot.data!.docs;

          // 🧮 Calculate total users
          int totalUsers = 0;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final newUsers = data['newUsers'];
            if (newUsers is int) totalUsers += newUsers;
            // if (newUsers is num) totalUsers += newUsers.toInt();
          }

          // 📅 Current month (latest document)
          final latestDoc = docs.last;
          final latestData = latestDoc.data() as Map<String, dynamic>;
          final currentMonthNewUsers = latestData['newUsers'] ?? 0;
          final currentMonth = latestDoc.id;

          return Column(
            children: [
              // ✅ Top summary section
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      "የዚህ ወር አዲስ ተጠቃሚዎች መጠን",
                      "$currentMonthNewUsers ሰው",
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      "እስከ አሁን ጠቅላላ ተጠቃሚዎች መጠን",
                      "$totalUsers ሰው",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'የተመዝጋቢዎች ታሪክ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ History list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey[400]),
                    itemBuilder: (context, index) {
                      final item = docs[index];
                      final data = item.data() as Map<String, dynamic>;
                      final month = item.id;
                      final count = data['newUsers'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$month:',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$count ሰው',
                              style: TextStyle(
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
          );
        },
      ),
    );
  }

  // Reusable summary row for top 20% section
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}
