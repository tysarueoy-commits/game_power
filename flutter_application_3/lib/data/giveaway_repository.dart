import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/giveaway.dart';

final giveawaysProvider = FutureProvider<List<Giveaway>>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return GiveawayRepository(client: client).fetchGiveaways();
});

class GiveawayRepository {
  GiveawayRepository({required http.Client client}) : _client = client;

  static final Uri _endpoint = Uri.https(
    'www.gamerpower.com',
    '/api/giveaways',
  );
  final http.Client _client;

  Future<List<Giveaway>> fetchGiveaways() async {
    final response = await _client.get(
      _endpoint,
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'GamerPower returned HTTP ${response.statusCode}. Please try again.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException(
        'GamerPower returned an unexpected response.',
      );
    }

    return decoded
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('A giveaway entry was invalid.');
          }
          return Giveaway.fromJson(item);
        })
        .toList(growable: false);
  }
}
