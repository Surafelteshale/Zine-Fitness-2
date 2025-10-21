import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utilities/colors.dart';
import '../widgets/user_model.dart'; // keep this import

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Automatically focus the text field when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    // Listen for changes in the search bar
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Firestore stream for all users
  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserStream() {
    return FirebaseFirestore.instance
        .collection('User')
        .orderBy('registrationDate', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('ፈልግ', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "ሰው ፈልግ...",
                      hintStyle: AppTextStyles.hintTextStyle,
                      prefixIcon: Icon(Icons.search, color: AppColors.iconGrey),
                      filled: true,
                      fillColor: AppColors.fieldFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus(); // close keyboard
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("ፈልግ", style: AppTextStyles.buttonText),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(
              child: Text("ሰው ፈልግ 🔍",
                  style: AppTextStyles.placeholderText),
            )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getUserStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading users."));
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No users found."));
                }

                // Filter users by name (case-insensitive)
                final filteredUsers = snapshot.data!.docs.where((doc) {
                  final name =
                  (doc.data()['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      "የሚመስሉ ሰዎች አልተገኙም ⚠️",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData = filteredUsers[index].data();
                    final String name = userData['name'] ?? 'Unknown';
                    final String id = userData['id'] ?? 'Unknown';
                    final String category =
                        userData['category'] ?? '---';
                    final int age = userData['age'] != null
                        ? userData['age'] as int
                        : 0;
                    final String gender =
                        userData['gender'] ?? '---';

                    // Determine payment status
                    final bool isPaid = userData['status'] ?? false;
                    String paymentStatus = isPaid ? 'ተከፍሏል' : 'አልተከፈለም';


                    return UserModel(
                      userId: id,
                      name: name,
                      category: category,
                      age: age,
                      paymentStatus: paymentStatus,
                      gender: gender,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
