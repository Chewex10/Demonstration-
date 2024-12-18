import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard.dart';
import 'servicerequestlist.dart';
import 'analytics.dart';
import 'settings.dart';
import 'service_request_form.dart';
import '../components/service_request_provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double _iconPosition = 0.0;
  Duration _animationDuration = Duration(milliseconds: 300); // Duration for the animation

  final List<Widget> _pages = [
    DashboardPage(),
    ServiceRequestListPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Method to load initial data from the provider
  Future<void> _loadInitialData() async {
    final provider = Provider.of<ServiceRequestProvider>(context, listen: false);
    await provider.loadRequests();
  }

  void _onItemTapped(int index) {
    setState(() {
      _iconPosition = index * (MediaQuery.of(context).size.width / 4); // Assuming 4 items
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: 66, // Custom height
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              backgroundColor: Color(0xFFefefef),
              selectedItemColor: Color(0xFF575a89), // Color for selected items
              unselectedItemColor: Color(0xFF575a89), // Color for unselected items
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(fontSize: 12),
              unselectedLabelStyle: TextStyle(fontSize: 12),
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.home_outlined, 0), // Changed icon
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.build_outlined, 1), // Changed icon
                  label: 'Services',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.show_chart_outlined, 2), // Changed icon
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.settings_outlined, 3), // Changed icon
                  label: 'Settings',
                ),
              ],
            ),
          ),
          // Animated sliding indicator
          AnimatedPositioned(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            left: _iconPosition + (MediaQuery.of(context).size.width / 8 - 15), // Centers indicator under the icon
            bottom: 0,
            child: Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Color(0xFF575a89), // Color of the sliding indicator
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ServiceRequestFormPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF575a89),
        tooltip: 'Log New Service Request',
      ),
    );
  }

  // Modified _buildNavIcon method to animate color and position changes
  Widget _buildNavIcon(IconData icon, int index) {
    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(top: 10), // Add top padding for icons
      child: Icon(
        icon,
        size: _currentIndex == index ? 28 : 24, // Animates icon size on selection
        color: Color(0xFF575a89), // Changed color based on selection
      ),
    );
  }
}
