// lib/widgets/user_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utilities/colors.dart';
import '../providers/user_provider.dart';
import '../providers/filter_provider.dart';
import 'user_model.dart'; // your UI widget

class UserList extends StatelessWidget {
  const UserList({super.key});

  bool _ageMatches(int? age, String? ageGroup) {
    if (age == null || ageGroup == null) return true;
    switch (ageGroup) {
      case '>12':
        return age > 12;
      case '12-18':
        return age >= 12 && age <= 18;
      case '18-40':
        return age >= 18 && age <= 40;
      case '40<':
        return age > 40;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final filterProv = context.watch<FilterProvider>();

    // Full list from stream (local cache)
    final allUsers = userProv.users;

    // Apply filters locally
    final filtered = allUsers.where((u) {
      final genderOk = filterProv.gender == null || (u.gender?.toLowerCase() == filterProv.gender?.toLowerCase());
      final categoryOk = filterProv.category == null || (u.category?.toLowerCase() == filterProv.category?.toLowerCase());
      final ageOk = filterProv.ageGroup == null || _ageMatches(u.age, filterProv.ageGroup);
      return genderOk && categoryOk && ageOk;
    }).toList();

    // counts for chips: total, paid, unpaid (based on filtered users)
    final totalCount = filtered.length;
    final paidCount = filtered.where((u) => u.status == true).length;
    final unpaidCount = filtered.where((u) => u.status == false).length;

    // Optional: expose counts downwards via Inherited or return widget with header - but we will keep rendering list here.
    if (userProv.isListening == false && allUsers.isEmpty) {
      // not listening yet -> show loader
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Text("No users found.", style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final u = filtered[index];

        // Convert paymentStatus to string for your UserModel
        final paymentStatus = u.status ? 'ተከፍሏል' : 'አልተከፈለም';

        return UserModel(
          userId: u.id,
          name: u.name ?? 'Unknown',
          category: u.category ?? '---',
          age: u.age ?? 0,
          paymentStatus: paymentStatus,
          gender: u.gender ?? '---',
        );
      },
    );
  }
}
