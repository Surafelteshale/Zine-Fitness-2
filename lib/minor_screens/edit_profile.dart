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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    final adminId = context.read<IdProvider>().getData; // current admin id
    if (adminId.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(adminId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nameController.text = data['ስም'] ?? '';
          phoneController.text = data['ስልክ'] ?? '';
          addressController.text = data['address'] ?? '';
          managerCountController.text = (data['managerCount'] ?? '').toString();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading admin data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  clearUserId() {
    context.read<IdProvider>().clearCustomerId();
  }

  Future<void> saveProfile() async {
    final adminId = context.read<IdProvider>().getData;
    if (adminId.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('Admin').doc(adminId).update({
        'ስም': nameController.text.trim(),
        'ስልክ': phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ስኬታማ ነው")),
      );
    } catch (e) {
      print("Error updating admin profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ስኬታማ አይደለም")),
      );
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
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
            Divider(height: 25, thickness: 1, color: AppColors.fieldFill),
            const SizedBox(height: 140),
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
                onPressed: saveProfile,
                child: Text(
                  "Save",
                  style: AppTextStyles.buttonText.copyWith(color: AppColors.background),
                ),
              ),
            ),
            const SizedBox(height: 40),
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
                        MaterialPageRoute(builder: (context) => const OnBoarding()),
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

// Reusable widget for profile row
class ProfileRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const ProfileRow({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
