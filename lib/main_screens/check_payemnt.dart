import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utilities/colors.dart';
import 'customer_page.dart';

class CheckPayment extends StatefulWidget {
  const CheckPayment({super.key});

  @override
  State<CheckPayment> createState() => _CheckPaymentState();
}

class _CheckPaymentState extends State<CheckPayment> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExpiredPayments();
  }

  Future<void> _checkExpiredPayments() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final usersSnapshot = await firestore
          .collection('User')
          .where('status', isEqualTo: true)
          .get();

      final now = DateTime.now();

      for (var userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final payments = data['payments'] ?? [];
        if (payments.isEmpty) continue;

        final lastPayment = payments.last;
        final lastPaymentTimestamp = lastPayment['date'];
        if (lastPaymentTimestamp == null) continue;

        final lastPaymentDate = (lastPaymentTimestamp as Timestamp).toDate();
        final difference = now.difference(lastPaymentDate).inDays;

        if (difference >= 30) {
          await userDoc.reference.update({'status': false});
        }
      }

      // ✅ When finished, go to CustomerPage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerPage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _errorMessage == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _checkExpiredPayments();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink(); // shouldn't reach here
  }
}
