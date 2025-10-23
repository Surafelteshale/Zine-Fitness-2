import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/stat_provider.dart';
import '../utilities/colors.dart'; // your AppColors & AppTextStyles

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dayController = TextEditingController(); // admin-visible day

  String _gender = 'ወንድ';
  String _category = 'ብረት';

  bool processing = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _categoryController.dispose();
    _paymentController.dispose();
    _phoneController.dispose();
    _bloodTypeController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  /// Create user in Firestore
  Future<void> createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => processing = true);

    try {
      final String id = const Uuid().v4();

      final int? age = _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim());
      final int? height = _heightController.text.trim().isEmpty
          ? null
          : int.tryParse(_heightController.text.trim());
      final double? weight = _weightController.text.trim().isEmpty
          ? null
          : double.tryParse(_weightController.text.trim());
      final double? paymentAmount = _paymentController.text.trim().isEmpty
          ? null
          : double.tryParse(_paymentController.text.trim());

      final List<Map<String, dynamic>> payments = [];
      if (paymentAmount != null) {
        payments.add({
          'amount': paymentAmount,
          'date': Timestamp.now(),
          'displayDay': _dayController.text.trim().isEmpty
              ? null
              : _dayController.text.trim(),
        });
      }

      final Map<String, dynamic> data = {
        'id': id,
        'name': _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        'gender': _gender.isEmpty ? null : _gender,
        'age': age,
        'phone': _phoneController.text.trim(),
        'category': _category,
        'bloodType': _bloodTypeController.text.trim().isEmpty
            ? null
            : _bloodTypeController.text.trim(),
        'height': height,
        'weight': weight,
        'registrationDate': FieldValue.serverTimestamp(),
        'status': true,
        'payments': payments,
        'lastPaid': paymentAmount != null ? FieldValue.serverTimestamp() : null,
      };

      // 1️⃣ Save the user
      await _firestore.collection('User').doc(id).set(data);

      // 2️⃣ Update MonthlyStats
      final monthDocId = DateTime.now().toIso8601String().substring(0, 7); // "YYYY-MM"
      final monthRef = _firestore.collection('MonthlyStats').doc(monthDocId);

      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(monthRef);

        if (!snapshot.exists) {
          // Create new month doc
          tx.set(monthRef, {
            'income': paymentAmount ?? 0,
            'newUsers': 1,
            'newUsersList': [id],
            'payments': paymentAmount != null
                ? [
              {
                'userId': id,
                'amount': paymentAmount,
                'date': Timestamp.now(),
              }
            ]
                : [],
            'createdAt': Timestamp.now(),
          });
        } else {
          // Update existing month doc
          tx.update(monthRef, {
            'income': (snapshot['income'] ?? 0) + (paymentAmount ?? 0),
            'newUsers': (snapshot['newUsers'] ?? 0) + 1,
            'newUsersList': FieldValue.arrayUnion([id]),
            if (paymentAmount != null)
              'payments': FieldValue.arrayUnion([
                {
                  'userId': id,
                  'amount': paymentAmount,
                  'date': Timestamp.now(),
                }
              ]),
          });
        }
      });

      // 3️⃣ Optional: update provider for UI
      final provider =
      Provider.of<MonthlyStatsProvider>(context, listen: false);
      await provider.refreshStats();

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('በተሳካ ሁኔታ ተመዝግቧል')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ለመመዝገብ አልተሳካም: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }



  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _categoryController.clear();
    _paymentController.clear();
    _phoneController.clear();
    _bloodTypeController.clear();
    _heightController.clear();
    _weightController.clear();
    _dayController.clear();

    setState(() {
      _gender = 'ወንድ';
      _category = 'ብረት';
    });
  }

  // UI helpers
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    bool requiredField = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          validator: (value) {
            if (!requiredField) return null;
            if (value == null || value.trim().isEmpty) return 'Required';
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.iconGrey),
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: AppColors.iconGrey),
            ),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('አዲስ ሰው መመዝገብ', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                label: 'ሙሉ ስም',
                controller: _nameController,
                hintText: 'ሙሉ ስም አስገባ',
                icon: Icons.person,
                requiredField: false,
              ),
              const SizedBox(height: 20),
              buildDropdownField(
                label: 'ጾታ',
                value: _gender,
                items: ['ወንድ', 'ሴት'],
                onChanged: (value) {
                  setState(() => _gender = value ?? _gender);
                },
                icon: Icons.wc,
              ),
              const SizedBox(height: 20),
              buildTextField(
                label: 'እድሜ',
                controller: _ageController,
                hintText: 'እድሜ አስገባ',
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              buildTextField(
                label: 'ስልክ',
                controller: _phoneController,
                hintText: 'ስልክ አስገባ',
                icon: Icons.phone,
              ),
              const SizedBox(height: 20),
              buildDropdownField(
                label: 'ምድብ',
                value: _category,
                items: ['ብረት', 'ኤሮቢክስ', 'ብረት እና ኤሮቢክስ'],
                onChanged: (value) {
                  setState(() => _category = value ?? _category);
                },
                icon: Icons.list,
              ),
              const SizedBox(height: 20),
              _category != 'ብረት'
                  ? Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      label: 'Blood Type',
                      controller: _bloodTypeController,
                      hintText: 'A+, B-, ...',
                      icon: Icons.bloodtype,
                      requiredField: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildTextField(
                      label: 'Height (cm)',
                      controller: _heightController,
                      hintText: 'Enter height',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      requiredField: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildTextField(
                      label: 'Weight (kg)',
                      controller: _weightController,
                      hintText: 'Enter weight',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                      requiredField: false,
                    ),
                  ),
                ],
              )
                  : const SizedBox(),
              const SizedBox(height: 20),
              buildTextField(
                label: 'የምዝገባ ቀን',
                controller: _dayController,
                hintText: 'ቀን አስገባ',
                icon: Icons.calendar_month,
                requiredField: false,
              ),
              const SizedBox(height: 20),
              buildTextField(
                label: 'የክፍያ መጠን',
                controller: _paymentController,
                hintText: 'የክፍያ መጠን (optional)',
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                requiredField: false,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: processing
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: createUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save', style: AppTextStyles.buttonText),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
