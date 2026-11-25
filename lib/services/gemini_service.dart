import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

/// NOTE: for production, call Gemini from a Cloud Function (or Firebase AI Logic)
/// so the API key never ships inside the client bundle.
class GeminiService {
  final _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: const String.fromEnvironment('GEMINI_KEY'),
    generationConfig: GenerationConfig(responseMimeType: 'application/json', temperature: 0.7),
    systemInstruction: Content.system(
        'You are an expert travel planner. Reply ONLY with JSON: '
        '{"summary":str,"total":num,"days":[{"day":int,"items":[{"title":str,'
        '"type":"stay|ticket|activity|food","cost":num,"note":str}]}]}. '
        'The total MUST NOT exceed the budget. Prefer items from the provided catalog '
        'and use their real prices; add free/cheap activities if useful.'),
  );

  Future<Map<String, dynamic>> planTrip({
    required double budget, required int days, required String city,
    required String interests, required List<Listing> catalog,
  }) async {
    final prompt = 'Budget: \$$budget USD total, $days days in $city. Interests: $interests.\n'
        'Catalog: ${jsonEncode(catalog.where((l) => l.city == city).map((l) => l.toAi()).toList())}';
    final res = await _model.generateContent([Content.text(prompt)]);
    return jsonDecode(res.text ?? '{}') as Map<String, dynamic>;
  }
}
