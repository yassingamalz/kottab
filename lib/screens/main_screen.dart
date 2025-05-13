import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kottab/providers/session_provider.dart';
import 'package:kottab/screens/home_screen.dart';
import 'package:kottab/screens/schedule_screen.dart';
import 'package:kottab/screens/stats_screen.dart';
import 'package:kottab/screens/surahs_screen.dart';
import 'package:kottab/widgets/sessions/add_session_modal.dart';
import 'package:kottab/widgets/splash_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  // Screen controller
  final List<Widget> _screens = const [
    HomeScreen(),
    SurahsScreen(),
    StatsScreen(),
    ScheduleScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate loading time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Get the title for app bar based on current tab
  String _getTitleForTab(int index) {
    switch (index) {
      case 0:
        return 'كتاب';
      case 1:
        return 'سور القرآن';
      case 2:
        return 'الإحصائيات';
      case 3:
        return 'جدول المراجعة';
      default:
        return 'كتاب';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleForTab(_currentIndex),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'السور',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'الإحصائيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'الجدول',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Show the add session modal
  void _showAddSessionModal(BuildContext context) {
    // Initialize a new session
    Provider.of<SessionProvider>(context, listen: false).startNewSession();

    // Show modal bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => const AddSessionModal(),
    );
  }
}