// libs/widgets/navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:mone/features/home/home_screen.dart';
import 'package:mone/features/profile/profile_screen.dart';

class NavigationWrapper extends StatefulWidget {
  final int selectedPageIndex;

  const NavigationWrapper({super.key, this.selectedPageIndex = 0});

  @override
  State<NavigationWrapper> createState() => NavigationWrapperState();
}

class NavigationWrapperState extends State<NavigationWrapper> {
  late int _selectedPageIndex;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex;
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
