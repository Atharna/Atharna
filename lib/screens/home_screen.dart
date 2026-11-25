import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import 'booking_screen.dart';
import 'listings_screen.dart';
import 'planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  static const _dest = [
    (Icons.museum_outlined, 'Explore'), (Icons.hotel_outlined, 'Stays'),
    (Icons.auto_awesome, 'AI Planner'), (Icons.confirmation_number_outlined, 'Tickets'),
  ];
  final _pages = const [ListingsScreen(hotels: false), ListingsScreen(hotels: true), PlannerScreen(), MyTicketsScreen()];

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    return Scaffold(
      appBar: AppBar(title: const Text('اثرنا'), actions: [
        IconButton(icon: const Icon(Icons.brightness_6), onPressed: () => context.read<ThemeProvider>().toggle(context)),
        IconButton(icon: const Icon(Icons.logout), onPressed: AuthService().signOut),
      ]),
      body: Row(children: [
        if (desktop)
          NavigationRail(
            selectedIndex: _i, labelType: NavigationRailLabelType.all,
            onDestinationSelected: (v) => setState(() => _i = v),
            destinations: [for (final d in _dest) NavigationRailDestination(icon: Icon(d.$1), label: Text(d.$2))],
          ),
        Expanded(child: _pages[_i]),
      ]),
      bottomNavigationBar: desktop ? null : NavigationBar(
        selectedIndex: _i, onDestinationSelected: (v) => setState(() => _i = v),
        destinations: [for (final d in _dest) NavigationDestination(icon: Icon(d.$1), label: d.$2)],
      ),
    );
  }
}
