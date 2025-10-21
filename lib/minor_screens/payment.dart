import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class Payment extends StatefulWidget {
  final String userId;
  const Payment({super.key, required this.userId});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          _userData = doc.data();
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> _addPayment() async {
    if (_amountController.text.isEmpty || _dateController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('User').doc(widget.userId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) throw Exception("User not found");

      final data = docSnap.data()!;
      final List<dynamic> payments = data['payments'] ?? [];
      final bool currentStatus = data['status'] ?? false;

      final newPayment = {
        'amount': int.tryParse(_amountController.text) ?? 0,
        'displayDay': _dateController.text,
        'date': Timestamp.now(),
      };

      payments.add(newPayment);

      // Create an update map
      final Map<String, dynamic> updateData = {
        'payments': payments,
        'lastPaid': Timestamp.now(),
      };

      // Only update status if it's false
      if (!currentStatus) {
        updateData['status'] = true;
      }

      // Update the Firestore document
      await docRef.update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ክፍያው ተሳክቷል')),
      );

      _amountController.clear();
      _dateController.clear();
      await _fetchUserData(); // refresh data

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ስህተት ተከስቷል: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_userData == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _userData?['name'] ?? 'N/A';
    final category = _userData?['category'] ?? 'N/A';
    final status = _userData?['status'] ?? false;
    final payments = List<Map<String, dynamic>>.from(_userData?['payments'] ?? []);

    String lastPaymentDate = 'N/A';
    if (payments.isNotEmpty) {
      lastPaymentDate = payments.last['displayDay'] ?? 'N/A';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ክፍያ', style: AppTextStyles.appBarTitle),
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
                  _buildUserInfoRow("ስም፡", name),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("ክፍያ:", style: AppTextStyles.resultText),
                      const SizedBox(width: 8),
                      Text(
                        status ? "ተከፍሏል" : "አልተከፈለም",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: status ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildUserInfoRow("የመጨረሻው የተከፈለበት ቀን:", lastPaymentDate),
                  const SizedBox(height: 12),
                  _buildUserInfoRow("የተጠቃሚ ምድብ:", category),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date Field
            _buildTextField(
              controller: _dateController,
              label: "ቀን",
              hint: "ቀን ያስገቡ (e.g. 02-03-2018)",
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: 16),

            // Payment Amount
            _buildTextField(
              controller: _amountController,
              label: "የክፍያ መጠን",
              hint: "መጠን ያስገቡ",
              icon: Icons.monetization_on,
              keyboardType: TextInputType.number,
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
                onPressed: _isLoading ? null : _addPayment,
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("ክፈል", style: AppTextStyles.buttonText),
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
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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
