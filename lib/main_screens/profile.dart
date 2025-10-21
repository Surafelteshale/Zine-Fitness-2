import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zine_fitness/minor_screens/edit_profile.dart';
import 'package:zine_fitness/utilities/colors.dart';

import '../id_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final idProvider = context.read<IdProvider>();
    final currentAdminId = idProvider.getData; // current logged in admin id

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('Admin').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading profile: ${snapshot.error}"));
          }

          final allAdmins = snapshot.data!.docs;
          QueryDocumentSnapshot? currentAdmin;

          try {
            currentAdmin = allAdmins.firstWhere((doc) => doc['id'] == currentAdminId);
          } catch (e) {
            currentAdmin = null; // not found
          }

          if (currentAdmin == null) {
            return const Center(child: Text("Admin not found"));
          }


          if (currentAdmin == null) {
            return const Center(child: Text("Admin not found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: const AssetImage("images/logo2.jpg"),
                  ),
                ),
                const SizedBox(height: 15),

                // Title
                const Text(
                  "Zine Fitness",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 25),

                // Profile info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileRow(
                        label: "ስም",
                        value: currentAdmin['ስም'] ?? "",
                      ),
                      const Divider(height: 25, thickness: 1, color: Color(0xFFEDEDED)),
                      ProfileRow(
                        label: "ስልክ",
                        value: currentAdmin['ስልክ'] ?? "",
                      ),
                      const Divider(height: 25, thickness: 1, color: Color(0xFFEDEDED)),

                      // Expansion tile for all admins
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: ProfileRow(
                          label: "የተቆጣጣሪ ሰው መጠን",
                          value: allAdmins.length.toString(),
                        ),
                        children: allAdmins.map((doc) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Table(
                              border: TableBorder.all(color: const Color(0xFFEDEDED), width: 1),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFFF8F8F8)),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(doc['ስም'] ?? "", style: const TextStyle(fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(doc['ስልክ'] ?? "", style: const TextStyle(fontSize: 15)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Edit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      );
                    },
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Reusable profile row widget
class ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const ProfileRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
