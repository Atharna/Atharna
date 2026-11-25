import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/payment_service.dart';

class BookingScreen extends StatefulWidget {
  final Listing listing;
  const BookingScreen({super.key, required this.listing});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int adults = 1, children = 0;
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String slot = '10:00';
  bool busy = false;
  static const slots = ['09:00', '10:00', '12:00', '14:00', '16:00'];

  Listing get l => widget.listing;
  double get total => l.isHotel ? l.price : l.price * adults + l.price * 0.5 * children;

  Future<void> _book() async {
    setState(() => busy = true);
    final ok = await PaymentService().pay(total);
    if (ok) {
      final ref = await FirebaseFirestore.instance.collection('bookings').add({
        'uid': FirebaseAuth.instance.currentUser!.uid, 'listingId': l.id, 'listingName': l.name,
        'kind': l.kind, 'adults': adults, 'children': children, 'slot': slot,
        'date': Timestamp.fromDate(date), 'total': total, 'createdAt': FieldValue.serverTimestamp(),
      });
      final doc = await ref.get();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => Scaffold(appBar: AppBar(title: const Text('Your ticket')),
                body: Center(child: TicketView(Booking.fromDoc(doc))))));
      }
    } else if (mounted) {
      setState(() => busy = false);
    }
  }

  Widget _counter(String label, int v, void Function(int) set, int min) => Row(children: [
        Expanded(child: Text(label)),
        IconButton(onPressed: v > min ? () => setState(() => set(v - 1)) : null, icon: const Icon(Icons.remove_circle_outline)),
        Text('$v'),
        IconButton(onPressed: () => setState(() => set(v + 1)), icon: const Icon(Icons.add_circle_outline)),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(l.name)),
        body: Responsive.center(ListView(padding: const EdgeInsets.all(16), children: [
          ClipRRect(borderRadius: BorderRadius.circular(20),
              child: SizedBox(height: 220, child: Image.network(l.image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12)))),
          const SizedBox(height: 12),
          Text(l.description),
          const SizedBox(height: 16),
          _counter(l.isHotel ? 'Guests' : 'Adults', adults, (v) => adults = v, 1),
          _counter(l.isHotel ? 'Children (free)' : 'Children (50%)', children, (v) => children = v, 0),
          ListTile(
            contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event),
            title: Text(DateFormat.yMMMEd().format(date)),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: date,
                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => date = d);
            },
          ),
          Wrap(spacing: 8, children: [for (final s in slots)
            ChoiceChip(label: Text(s), selected: slot == s, onSelected: (_) => setState(() => slot = s))]),
          const SizedBox(height: 20),
          Text('Virtual ticket preview', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Opacity(opacity: .6, child: TicketView(Booking(id: 'PREVIEW', listingName: l.name, kind: l.kind,
              slot: slot, adults: adults, children: children, date: date, total: total))),
          const SizedBox(height: 20),
          FilledButton(onPressed: busy ? null : _book,
              child: Padding(padding: const EdgeInsets.all(14),
                  child: Text(busy ? 'Processing…' : 'Pay \$${total.toStringAsFixed(2)}'))),
        ])),
      );
}

class TicketView extends StatelessWidget {
  final Booking b;
  const TicketView(this.b, {super.key});
  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisSize: MainAxisSize.min, children: [
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.listingName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('${DateFormat.yMMMd().format(b.date)} • ${b.slot}'),
            Text('${b.adults} adult(s), ${b.children} child(ren)'),
            Text('Total: \$${b.total.toStringAsFixed(2)}'),
            Text('#${b.id}', style: Theme.of(context).textTheme.bodySmall),
          ])),
          const SizedBox(width: 16),
          Container(color: Colors.white, padding: const EdgeInsets.all(8),
              child: QrImageView(data: b.id, size: 120)),
        ])),
      );
}

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('bookings')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (_, s) {
          final docs = s.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No tickets yet'));
          return Responsive.center(ListView(padding: const EdgeInsets.all(16),
              children: [for (final d in docs) TicketView(Booking.fromDoc(d))]));
        },
      );
}
