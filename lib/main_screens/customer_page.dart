// lib/main_screens/customer_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zine_fitness/minor_screens/search_page.dart';
import 'package:zine_fitness/widgets/user_list.dart';
import '../minor_screens/filter_page.dart';
import '../providers/user_provider.dart';
import '../providers/filter_provider.dart';
import '../utilities/colors.dart';
import '../widgets/user_model.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  int selectedCategory = 0; // 0 = All, 1 = Paid, 2 = Unpaid

  @override
  void initState() {
    super.initState();
    // Start the user stream once when this page is created (if not started elsewhere)
    final up = context.read<UserProvider>();
    up.startListening();
  }

  void openFilter() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterPage()));
    // FilterPage writes back to provider, and provider notifies -> rebuild
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final filterProv = context.watch<FilterProvider>();

    // compute filtered results for counts (same logic as in UserList)
    final filtered = userProv.users.where((u) {
      final genderOk = filterProv.gender == null || (u.gender?.toLowerCase() == filterProv.gender?.toLowerCase());
      final categoryOk = filterProv.category == null || (u.category?.toLowerCase() == filterProv.category?.toLowerCase());
      final ageOk = filterProv.ageGroup == null || _ageMatches(u.age, filterProv.ageGroup);
      return genderOk && categoryOk && ageOk;
    }).toList();

    final totalCount = filtered.length;
    final paidCount = filtered.where((u) => u.status == true).length;
    final unpaidCount = filtered.where((u) => u.status == false).length;

    final screenHeight = MediaQuery.of(context).size.height;

    // determine filterStatus for UserList (we still pass selectedCategory so UserList can filter by payment tab)
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Zine Fitness', style: AppTextStyles.appBarTitle.copyWith(fontSize: 28)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.fieldFill,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [ BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0,3)) ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Row(children: [ Icon(Icons.search, color: AppColors.iconGrey), const SizedBox(width: 8), Text('ሰው ፈልግ', style: TextStyle(color: AppColors.iconGrey, fontSize: 16)) ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: openFilter,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.filter_list, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      categoryChip('ሁሉም', totalCount, 0),
                      categoryChip('የከፈለ', paidCount, 1),
                      categoryChip('ያልከፈለ', unpaidCount, 2),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: screenHeight * 0.8,
              width: double.infinity,
              color: AppColors.fieldFill,
              child: Column(
                children: [
                  Expanded(
                    // Pass selectedCategory so the UserList can filter by paid/unpaid tab,
                    // but UserList itself will also apply advanced filters from FilterProvider
                    child: UserListWrapper(selectedTab: selectedCategory),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryChip(String label, int count, int index) {
    final bool isSelected = selectedCategory == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.fieldFill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '$label ', style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16)),
              TextSpan(text: '($count)', style: TextStyle(color: isSelected ? Colors.white70 : Colors.black54, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

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
}

/// A small wrapper to adapt the previous UserList to accept the selectedTab payment filter.
/// We reuse `UserList` above (you could merge logic into a single widget).
class UserListWrapper extends StatelessWidget {
  final int selectedTab;
  const UserListWrapper({required this.selectedTab, super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final filterProv = context.watch<FilterProvider>();

    // start from full provider list and apply both advanced filters and payment tab
    var filtered = userProv.users.where((u) {
      final genderOk = filterProv.gender == null || (u.gender?.toLowerCase() == filterProv.gender?.toLowerCase());
      final categoryOk = filterProv.category == null || (u.category?.toLowerCase() == filterProv.category?.toLowerCase());
      final ageOk = filterProv.ageGroup == null || _ageMatches(u.age, filterProv.ageGroup);
      return genderOk && categoryOk && ageOk;
    }).toList();

    if (selectedTab == 1) {
      filtered = filtered.where((u) => u.status == true).toList();
    } else if (selectedTab == 2) {
      filtered = filtered.where((u) => u.status == false).toList();
    }

    if (filtered.isEmpty) {
      return const Center(child: Text("No users found.", style: TextStyle(color: AppColors.textSecondary)));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final u = filtered[index];
        return UserModel(
          userId: u.id,
          name: u.name ?? 'Unknown',
          category: u.category ?? '---',
          age: u.age ?? 0,
          paymentStatus: u.status ? 'ተከፍሏል' : 'አልተከፈለም',
          gender: u.gender ?? '---',
        );
      },
    );
  }

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
}
