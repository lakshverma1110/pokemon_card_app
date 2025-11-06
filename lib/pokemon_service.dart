import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class PokemonService {
  // Pokémon TCG API endpoint
  static const String apiUrl =
      'https://api.pokemontcg.io/v2/cards?pageSize=20';

  // Provided API key (user-provided)
  // NOTE: If you plan to publish this app, move the key to secure storage or
  // environment variables. For local/testing purposes the key is inlined per request.
  static const String apiKey = 'd2e653f4-4977-4ba9-b4ac-9dd0d787efbe';

  static Future<List<dynamic>> fetchCards() async {
    try {
      final uri = Uri.parse(apiUrl);
      developer.log('Fetching cards from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'X-Api-Key': apiKey,
          'Accept': 'application/json',
        },
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        developer.log('Response body length: ${response.body.length}');
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // API v2 returns the card list under the 'data' key
        final cards = data['data'] as List<dynamic>?;
        if (cards == null) {
          developer.log('Warning: No cards found in response data');
          return [];
        }
        
        developer.log('Successfully fetched ${cards.length} cards');
        return cards;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('API key invalid or unauthorized. Please check your API key.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        developer.log('Error response body: ${response.body}');
        throw Exception(
            'Failed to load Pokémon cards (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      developer.log('Error in fetchCards: $e', error: e);
      // Re-throw with more user-friendly message but preserve original error
      throw Exception('Unable to load Pokémon cards. Please check your internet connection and try again. (Error: $e)');
    }
  }
}
