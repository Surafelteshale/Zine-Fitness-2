import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zine_fitness/main_screens/home_page.dart';
import '../id_provider.dart';
import '../utilities/colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool processing = false;

  setUserId(uid) {
    context.read<IdProvider>().setCustomerId(uid);
  }

  /// Login function with password check
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => processing = true);

    try {
      // 🔹 Fetch stored password from Firestore
      final passwordDoc = await FirebaseFirestore.instance
          .collection('Other')
          .doc('password')
          .get();

      if (!passwordDoc.exists) {
        throw Exception("Password document not found in Firestore.");
      }

      final String storedPassword = passwordDoc['password'] ?? '';

      // 🔹 Compare entered password
      if (_passwordController.text.trim() != storedPassword) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('password ትክክል አይደለም')),
          );
        }
        return;
      }

      // 🔹 If password matches, continue with saving Admin data
      String id = const Uuid().v4();

      await FirebaseFirestore.instance.collection('Admin').doc(id).set({
        'id': id,
        'ስም': _nameController.text.trim(),
        'ስልክ': _phoneController.text.trim(),
      });

      setUserId(id);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('አልተከናወነም: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction:
          nextFocus != null ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              focusNode.unfocus();
            }
          },
          validator: (value) =>
          value == null || value.isEmpty ? 'አልተሞላም' : null,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.iconGrey),
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "መግቢያ",
                    style: AppTextStyles.appBarTitle.copyWith(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 60),

                /// Name field
                buildTextField(
                  label: "ስም",
                  controller: _nameController,
                  hintText: "ስም አስገባ",
                  icon: Icons.person,
                  focusNode: _nameFocus,
                  nextFocus: _phoneFocus,
                ),
                const SizedBox(height: 20),

                /// Phone field
                buildTextField(
                  label: "ስልክ",
                  controller: _phoneController,
                  hintText: "ስልክ አስገባ",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  focusNode: _phoneFocus,
                ),
                const SizedBox(height: 20),

                /// Password field
                buildTextField(
                  label: "password",
                  controller: _passwordController,
                  hintText: "password አስገባ",
                  icon: Icons.lock,
                  keyboardType: TextInputType.text,
                  focusNode: _passwordFocus,
                ),
                const SizedBox(height: 140),

                /// Button
                processing
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: login,
                  child:
                  const Text("ቀጥል", style: AppTextStyles.buttonText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
