// lib/minor_screens/filter_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utilities/colors.dart';
import '../providers/filter_provider.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedGender;
  String? selectedAgeGroup;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    final fp = context.read<FilterProvider>();
    selectedGender = fp.gender;
    selectedAgeGroup = fp.ageGroup;
    selectedCategory = fp.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text('Filter', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), color: AppColors.textPrimary, onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(
              title: "ጾታ",
              options: ["ወንድ", "ሴት"],
              selectedValue: selectedGender,
              onChanged: (val) => setState(() => selectedGender = val),
            ),
            const SizedBox(height: 20),
            _buildFilterSection(
              title: "ዕድሜ",
              options: [">12", "12-18", "18-40", "40<"],
              selectedValue: selectedAgeGroup,
              onChanged: (val) => setState(() => selectedAgeGroup = val),
            ),
            const SizedBox(height: 20),
            _buildFilterSection(
              title: "ምድብ",
              options: ["ብረት", "ኤሮቢክስ", "ብረት እና ኤሮቢክስ"],
              selectedValue: selectedCategory,
              onChanged: (val) => setState(() => selectedCategory = val),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Save into provider and pop
                  context.read<FilterProvider>().setFilters(
                    gender: selectedGender,
                    ageGroup: selectedAgeGroup,
                    category: selectedCategory,
                  );
                  Navigator.pop(context, {
                    "gender": selectedGender,
                    "ageGroup": selectedAgeGroup,
                    "category": selectedCategory,
                  });
                },
                child: Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.background)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            GestureDetector(
              onTap: selectedValue != null ? () => onChanged(null) : null,
              child: Icon(Icons.close, color: selectedValue != null ? Colors.red : Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: options.map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: option,
                  groupValue: selectedValue,
                  activeColor: AppColors.primary,
                  onChanged: onChanged,
                ),
                Text(option, style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
