import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import '../services/gemini_service.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  double budget = 800;
  int days = 3;
  String? city;
  final interests = TextEditingController(text: 'history, museums, local food');
  Map<String, dynamic>? plan;
  bool loading = false;

  Future<void> _generate() async {
    final all = context.read<ListingsProvider>();
    setState(() => loading = true);
    try {
      plan = await GeminiService().planTrip(budget: budget, days: days,
          city: city ?? all.cities.first, interests: interests.text, catalog: all.all);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI error: $e')));
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cities = context.watch<ListingsProvider>().cities;
    final icons = {'stay': Icons.hotel, 'ticket': Icons.confirmation_number, 'food': Icons.restaurant, 'activity': Icons.hiking};
    return Responsive.center(ListView(padding: const EdgeInsets.all(16), children: [
      Text('Total budget: \$${budget.round()}', style: Theme.of(context).textTheme.titleMedium),
      Slider(value: budget, min: 100, max: 5000, divisions: 49, onChanged: (v) => setState(() => budget = v)),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
            value: city ?? (cities.isEmpty ? null : cities.first),
            decoration: const InputDecoration(labelText: 'Destination'),
            items: [for (final c in cities) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => city = v)),
        const SizedBox(width: 12),
        DropdownButton<int>(value: days, items: [for (var d = 1; d <= 10; d++) DropdownMenuItem(value: d, child: Text('$d days'))],
            onChanged: (v) => setState(() => days = v!)),
      ]),
      const SizedBox(height: 12),
      TextField(controller: interests, decoration: const InputDecoration(labelText: 'Interests')),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: loading ? null : _generate, icon: const Icon(Icons.auto_awesome),
          label: Text(loading ? 'Planning…' : 'Plan my trip with AI')),
      if (plan != null) ...[
        const SizedBox(height: 16),
        Card(child: ListTile(title: Text(plan!['summary'] ?? ''),
            subtitle: Text('Estimated total: \$${plan!['total']}'))),
        for (final d in (plan!['days'] as List? ?? []))
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Day ${d['day']}', style: Theme.of(context).textTheme.titleMedium),
            for (final it in (d['items'] as List))
              ListTile(dense: true, leading: Icon(icons[it['type']] ?? Icons.place),
                  title: Text(it['title']), subtitle: Text(it['note'] ?? ''), trailing: Text('\$${it['cost']}')),
          ]))),
      ],
    ]));
  }
}
