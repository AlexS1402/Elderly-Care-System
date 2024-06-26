import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';
import 'patient_list_screen.dart';
import 'admin_screen.dart';
import 'login_screen.dart';
import 'package:caregiver_dashboard/services/auth_service.dart';

class NavBar extends StatefulWidget {
  final Widget child;

  const NavBar({required this.child});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool _isDrawerOpen = false;
  final storage = FlutterSecureStorage();
  Map<int, bool> _hovering = {};
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  void _getUserRole() async {
    String? role = await AuthService.getUserRole();
    setState(() {
      _userRole = role;
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _onHover(int index, bool hovering) {
    setState(() {
      _hovering[index] = hovering;
    });
  }

  void _signOut() async {
    await storage.delete(key: 'jwt');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          widget.child,
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(
                color: Colors.black54,
              ),
            ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isDrawerOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: Material(
              child: Container(
                width: 250,
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 80),
                      Expanded(
                        child: ListView(
                          children: [
                            MouseRegion(
                              onEnter: (_) => _onHover(0, true),
                              onExit: (_) => _onHover(0, false),
                              child: ListTile(
                                title: Text(
                                  'Home',
                                  style: TextStyle(
                                    color: _hovering[0] == true
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                  );
                                },
                              ),
                            ),
                            if (_userRole != 'Admin') // Only show for non-admin users
                              MouseRegion(
                                onEnter: (_) => _onHover(1, true),
                                onExit: (_) => _onHover(1, false),
                                child: ListTile(
                                  title: Text(
                                    'Patient List',
                                    style: TextStyle(
                                      color: _hovering[1] == true
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PatientListScreen()),
                                    );
                                  },
                                ),
                              ),
                            if (_userRole == 'Admin') // Only show for admin users
                              MouseRegion(
                                onEnter: (_) => _onHover(2, true),
                                onExit: (_) => _onHover(2, false),
                                child: ListTile(
                                  title: Text(
                                    'Admin Page',
                                    style: TextStyle(
                                      color: _hovering[2] == true
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminScreen()),
                                    );
                                  },
                                ),
                              ),
                            MouseRegion(
                              onEnter: (_) => _onHover(3, true),
                              onExit: (_) => _onHover(3, false),
                              child: ListTile(
                                title: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: _hovering[3] == true
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                                onTap: _signOut,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: _toggleDrawer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Row(
                    children: [
                      if (!_isDrawerOpen)
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: _toggleDrawer,
                        ),
                      Spacer(),
                      Text('Elderly Care System'),
                      Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
