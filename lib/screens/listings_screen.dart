import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'booking_screen.dart';

/// Used for both "Explore" (museums/heritage/tours) and "Stays" (hotels).
class ListingsScreen extends StatelessWidget {
  final bool hotels;
  const ListingsScreen({super.key, required this.hotels});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ListingsProvider>();
    final items = p.filtered(hotels: hotels);
    return Responsive.center(CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Max price: \$${p.maxPrice.round()}${hotels ? ' / night' : ''}'),
          Slider(value: p.maxPrice, min: 10, max: 1000, divisions: 99,
              onChanged: (v) => p.setFilters(price: v)),
          Wrap(spacing: 12, runSpacing: 8, children: [
            DropdownMenu<String?>(
              label: const Text('Location'), initialSelection: p.city,
              dropdownMenuEntries: [const DropdownMenuEntry(value: null, label: 'All'),
                for (final c in p.cities) DropdownMenuEntry(value: c, label: c)],
              onSelected: (v) => p.setFilters(cityValue: v, clearCity: v == null),
            ),
            for (final r in [0.0, 3.5, 4.0, 4.5])
              ChoiceChip(label: Text(r == 0 ? 'Any rating' : '$r★+'),
                  selected: p.minRating == r, onSelected: (_) => p.setFilters(rating: r)),
          ]),
        ]),
      )),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.85),
          itemCount: items.length,
          itemBuilder: (_, i) => ListingCard(l: items[i]),
        ),
      ),
    ]));
  }
}

class ListingCard extends StatelessWidget {
  final Listing l;
  const ListingCard({super.key, required this.l});
  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(listing: l))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: SizedBox(width: double.infinity,
                child: Image.network(l.image, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported))))),
            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
              Text('${l.city} • ${l.kind}'),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star, size: 16, color: Colors.amber), Text(' ${l.rating}'),
                const Spacer(),
                Text('\$${l.price.round()}${l.isHotel ? '/night' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ])),
          ]),
        ),
      );
}
