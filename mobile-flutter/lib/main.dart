import 'package:flutter/material.dart';

void main() {
  runApp(const YoUnMeApp());
}

class YoUnMeApp extends StatelessWidget {
  const YoUnMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YoUnMe Dating App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080A10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2D55),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF0F121D),
          tertiary: Color(0xFFFFD700),
        ),
      ),
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    Center(child: Text("🔥 Discovery Deck & PostGIS Radar", style: TextStyle(fontSize: 18))),
    Center(child: Text("❤️ Connect & 'Likes You' Stack", style: TextStyle(fontSize: 18))),
    Center(child: Text("💬 Chat & Contact Guard Filter", style: TextStyle(fontSize: 18))),
    Center(child: Text("📞 LiveKit Cloud SFU WebRTC Calls", style: TextStyle(fontSize: 18))),
    Center(child: Text("🪙 Profile, Blue Tick & Double-Entry Ledger", style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A10).withOpacity(0.9),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF2D55), Color(0xFF9B51E0)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              "YoUnMe",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text("250", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: const Color(0xFF0F121D),
        indicatorColor: const Color(0xFFFF2D55).withOpacity(0.25),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discovery'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Connect'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.phone_outlined), selectedIcon: Icon(Icons.phone), label: 'Calls'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
