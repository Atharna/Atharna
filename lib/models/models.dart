import 'package:cloud_firestore/cloud_firestore.dart';

/// Museums, heritage sites, tours and hotels share one model (kind differentiates).
class Listing {
  final String id, name, city, kind, image, description;
  final double price, rating; // price = per ticket, or per night for hotels
  const Listing({required this.id, required this.name, required this.city, required this.kind,
      required this.image, required this.description, required this.price, required this.rating});

  bool get isHotel => kind == 'hotel';

  factory Listing.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Listing(id: d.id, name: m['name'], city: m['city'], kind: m['kind'],
        image: m['image'] ?? '', description: m['description'] ?? '',
        price: (m['price'] as num).toDouble(), rating: (m['rating'] as num).toDouble());
  }
  Map<String, dynamic> toAi() => {'name': name, 'kind': kind, 'city': city, 'price': price, 'rating': rating};
}

class Booking {
  final String id, listingName, slot, kind;
  final int adults, children;
  final DateTime date;
  final double total;
  const Booking({required this.id, required this.listingName, required this.kind, required this.slot,
      required this.adults, required this.children, required this.date, required this.total});

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Booking(id: d.id, listingName: m['listingName'], kind: m['kind'], slot: m['slot'],
        adults: m['adults'], children: m['children'], date: (m['date'] as Timestamp).toDate(),
        total: (m['total'] as num).toDouble());
  }
}
