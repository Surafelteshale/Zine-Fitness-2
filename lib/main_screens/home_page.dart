import 'package:flutter/material.dart';
import 'package:zine_fitness/main_screens/customer_page.dart';
import 'package:zine_fitness/main_screens/create_user.dart';
import 'package:zine_fitness/main_screens/profile.dart';
import 'package:zine_fitness/main_screens/report_page.dart';
import 'package:zine_fitness/utilities/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _tabs = [
    const CustomerPage(),
    const CreateUser(),
    const ReportPage(),
    const Profile(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey.withOpacity(0.2),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          selectedItemColor: AppColors.primary,
          // unselectedItemColor: Colors.cyan,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'መግቢያ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'መመዝገቢያ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index){
            setState(() {
              _selectedIndex = index;
            });
          }
      ),
    );
  }
}
