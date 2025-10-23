import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class PaymentDetail extends StatefulWidget {
  const PaymentDetail({super.key});

  @override
  State<PaymentDetail> createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  /// Helper: calculate total amount from the payments array
  int _calculateTotal(List<dynamic>? payments) {
    if (payments == null || payments.isEmpty) return 0;
    int total = 0;
    for (var payment in payments) {
      if (payment is Map && payment.containsKey('amount')) {
        total += (payment['amount'] ?? 0) is num
            ? (payment['amount'] as num).toInt()
            : 0;
      }
    }
    return total;
  }

  /// Fetch all MonthlyStats docs stream
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchAllMonths() {
    return FirebaseFirestore.instance
        .collection('MonthlyStats')
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// Get the latest (current month) document stream
  Stream<QueryDocumentSnapshot<Map<String, dynamic>>?> _fetchLatestMonth() {
    return FirebaseFirestore.instance
        .collection('MonthlyStats')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'የክፍያ ዝርዝር',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _fetchAllMonths(),
        builder: (context, allMonthsSnapshot) {
          if (allMonthsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!allMonthsSnapshot.hasData || allMonthsSnapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No payment data available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final allDocs = allMonthsSnapshot.data!;

          // --- Calculate total across all months ---
          int totalIncome = 0;
          for (var doc in allDocs) {
            totalIncome += _calculateTotal(doc.data()['payments']);
          }

          return StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
            stream: _fetchLatestMonth(),
            builder: (context, latestMonthSnapshot) {
              if (latestMonthSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final latestDoc = latestMonthSnapshot.data;
              int currentMonthIncome = 0;
              if (latestDoc != null) {
                currentMonthIncome = _calculateTotal(latestDoc.data()['payments']);
              }

              return Column(
                children: [
                  // Top summary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow("የዚህ ወር ክፍያ", "$currentMonthIncome ብር"),
                        const SizedBox(height: 12),
                        _buildSummaryRow("እስከ አሁን ጠቅላላ ክፍያ", "$totalIncome ብር"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment history title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ያለፉ ክፍያዎች',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment history list
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView.separated(
                        itemCount: allDocs.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.grey[400]),
                        itemBuilder: (context, index) {
                          final doc = allDocs[index];
                          final monthId = doc.id;
                          final monthTotal = _calculateTotal(doc.data()['payments']);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$monthId:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$monthTotal ብር',
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
          );
        },
      ),
    );
  }

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
