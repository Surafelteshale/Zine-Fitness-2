import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class UpdateUser extends StatefulWidget {
  final String userId;
  const UpdateUser({super.key, required this.userId});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _educationLevelController = TextEditingController();
  final TextEditingController _healthStatusController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;
  bool _isDataLoading = true;

  final List<String> _categories = ['ብረት', 'ኤሮቢክስ', 'Personanl', 'ቴኳንዶ እና ኪክ ቦክስ'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _selectedCategory = data['category'];
        _weightController.text = data['weight']?.toString() ?? '';
        _heightController.text = data['height']?.toString() ?? '';
        _bloodTypeController.text = data['bloodType'] ?? '';
        _addressController.text = data['address'] ?? '';
        _educationLevelController.text = data['educationLevel'] ?? '';
        _healthStatusController.text = data['healthStatus'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    } finally {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('User').doc(widget.userId).update({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'category': _selectedCategory,
        'weight': _weightController.text.trim(),
        'height': _heightController.text.trim(),
        'bloodType': _bloodTypeController.text.trim(),
        'address': _addressController.text.trim(),
        'educationLevel': _educationLevelController.text.trim(),
        'healthStatus': _healthStatusController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ተጠቃሚ በተሳካ ሁኔታ ተስተካክሏል!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ተጠቃሚን ማስተካከል አልተሳካም: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("እርግጠኛ ነዎት ይህን ተጠቃሚ መሰረዝ ይፈልጋሉ?"),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await FirebaseFirestore.instance.collection('User').doc(widget.userId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ተጠቃሚ በተሳካ ሁኔታ ተሰርዟል።')),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ተጠቃሚን መሰረዝ አልተሳካም: $e')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Yes"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("አስተካክል", style: AppTextStyles.appBarTitle),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 1,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField("ስም", _nameController),
              _buildTextField("ዕድሜ", _ageController, keyboardType: TextInputType.number),
              _buildDropdownField(),
              _buildTextField("ክብደት (በኪ.ግ)", _weightController),
              _buildTextField("ቁመት (በሜትር)", _heightController),
              _buildTextField("የደም ዓይነት", _bloodTypeController),
              _buildTextField("አድራሻ", _addressController),
              _buildTextField("የትምህርት ደረጃ", _educationLevelController),
              _buildTextField("የጤና ሁኔታ", _healthStatusController),
              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveUserData,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save", style: AppTextStyles.buttonText),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showDeleteDialog(context),
                  child: const Text(
                    "Delete ተጠቃሚውን",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "$label አስገባ",
              hintStyle: AppTextStyles.hintTextStyle,
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
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ክፍል", style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.fieldFill,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
