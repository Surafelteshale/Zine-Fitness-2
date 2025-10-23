import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../id_provider.dart';
import '../utilities/colors.dart';
import '../widgets/alert_dialog.dart';
import 'onboarding.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController managerCountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    final adminId = context.read<IdProvider>().getData;
    if (adminId.isEmpty) return;

    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(adminId)
          .get();

      final passwordDoc = await FirebaseFirestore.instance
          .collection('Other')
          .doc('password')
          .get();

      if (adminDoc.exists) {
        final data = adminDoc.data()!;
        nameController.text = data['ስም'] ?? '';
        phoneController.text = data['ስልክ'] ?? '';
        addressController.text = data['address'] ?? '';
        managerCountController.text = (data['managerCount'] ?? '').toString();
      }

      if (passwordDoc.exists) {
        final passData = passwordDoc.data()!;
        passwordController.text = passData['password'] ?? '';
      }
    } catch (e) {
      print("Error loading admin or password data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  clearUserId() {
    context.read<IdProvider>().clearCustomerId();
  }

  Future<void> saveProfile() async {
    final adminId = context.read<IdProvider>().getData;
    if (adminId.isEmpty) return;

    setState(() => isSaving = true);

    try {
      // Update Admin info
      await FirebaseFirestore.instance.collection('Admin').doc(adminId).update({
        'ስም': nameController.text.trim(),
        'ስልክ': phoneController.text.trim(),
      });

      // Update password field in Other/password document
      await FirebaseFirestore.instance
          .collection('Other')
          .doc('password')
          .update({
        'password': passwordController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ስኬታማ ነው")),
      );
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ስኬታማ አይደለም")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileRow(label: "ስም", controller: nameController),
            const Divider(height: 25, thickness: 1, color: AppColors.fieldFill),
            ProfileRow(label: "ስልክ", controller: phoneController),
            const Divider(height: 25, thickness: 1, color: AppColors.fieldFill),
            ProfileRow(label: "Password", controller: passwordController, obscureText: false),
            const Divider(height: 25, thickness: 1, color: AppColors.fieldFill),
            const SizedBox(height: 140),

            // Save Button with Loading Indicator
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isSaving ? null : saveProfile,
                child: isSaving
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  "Save",
                  style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.background),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  MyAlertDialog.showMyDialog(
                    context: context,
                    title: 'Log Out',
                    content: 'Are you sure to log out?',
                    tabNo: () => Navigator.pop(context),
                    tabYes: () async {
                      clearUserId();
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OnBoarding()),
                      );
                    },
                  );
                },
                child: Text(
                  "ከapplication ውጣ",
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Reusable Profile Input Field
class ProfileRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const ProfileRow({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
