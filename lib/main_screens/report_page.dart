import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndCreateNextMonth();
  }

  Future<void> _checkAndCreateNextMonth() async {
    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('MonthlyStats')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final latestDoc = querySnapshot.docs.first;
      final data = latestDoc.data() as Map<String, dynamic>;
      final Timestamp createdAtTimestamp = data['createdAt'];
      final createdAt = createdAtTimestamp.toDate();
      final now = DateTime.now();

      // Calculate difference in minutes for testing (replace with inDays for production)
      final difference = now.difference(createdAt).inMinutes;

      if (difference >= 3) { // For testing: 3 minutes
        // Compute next month/year
        int year = createdAt.year;
        int month = createdAt.month + 1;
        if (month > 12) {
          month = 1;
          year += 1;
        }
        final newDocId = '$year-${month.toString().padLeft(2, '0')}';

        // Create empty structure
        final emptyData = {
          "createdAt": Timestamp.fromDate(now),
          "income": 0,
          "newUsers": 0,
          "newUsersList": <String>[],
          "payments": <Map<String, dynamic>>[],
        };

        await firestore.collection('MonthlyStats').doc(newDocId).set(emptyData);
      }
    } catch (e) {
      debugPrint("Error checking/creating next month: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('MonthlyStats')
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final doc = snapshot.data!.docs.first;
          final data = doc.data() as Map<String, dynamic>;

          final payments = List<Map<String, dynamic>>.from(data['payments'] ?? []);
          final totalIncome =
          payments.fold<num>(0, (sum, p) => sum + (p['amount'] ?? 0)).toInt();
          final newUsers = data['newUsers'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              children: [
                _buildReportCard(
                  icon: Icons.monetization_on,
                  title: "የክፍያ መጠን",
                  subtitle: "የዚህ ወር የክፍያ መጠን:",
                  value: "$totalIncome ብር",
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
                  value: "$newUsers ተጠቃሚ",
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
          );
        },
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
      height: 300,
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
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.iconGrey),
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
          Padding(
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
        ],
      ),
    );
  }
}
