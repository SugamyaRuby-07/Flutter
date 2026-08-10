import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    return Scaffold(
      // Extends the background behind the status bar and app bar
      extendBodyBehindAppBar: true,

      // Shows the slide-out menu drawer only on mobile
      drawer: isMobile
          ? const Drawer(
              backgroundColor: Colors.black87,
              child: MenuList(),
            )
          : null,

      appBar: AppBar(
        title:
            const Text("Responsive UI", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Makes app bar transparent
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Colors the menu button white
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // Matches the path defined in pubspec.yaml
            image: AssetImage("assets/mushroom.jpg"),
            fit: BoxFit.cover, // Fills the entire screen
          ),
        ),
        child: Row(
          children: [
            // Shows the menu permanently as a sidebar layout for large screens
            if (!isMobile)
              Container(
                width: 250,
                color: Colors.black.withOpacity(0.7),
                child: const SafeArea(
                  child: MenuList(),
                ),
              ),

            // Main content area
            Expanded(
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  color: Colors.black.withOpacity(
                      0.5), // Semi-transparent overlay for text legibility
                  child: Text(
                    isMobile ? "Mobile Screen" : "Large Screen",
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Static Menu List Widget
class MenuList extends StatelessWidget {
  const MenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children: const [
        ListTile(
          leading: Icon(Icons.home, color: Colors.white),
          title: Text('Home', style: TextStyle(color: Colors.white)),
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Colors.white),
          title: Text('Settings', style: TextStyle(color: Colors.white)),
        ),
        ListTile(
          leading: Icon(Icons.info, color: Colors.white),
          title: Text('About', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
