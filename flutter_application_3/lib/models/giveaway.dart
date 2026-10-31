class Giveaway {
  const Giveaway({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.instructions,
    required this.platforms,
    required this.type,
    required this.worth,
    required this.endDate,
    required this.openGiveawayUrl,
  });

  final int id;
  final String title;
  final String thumbnail;
  final String description;
  final String instructions;
  final String platforms;
  final String type;
  final String worth;
  final String endDate;
  final String openGiveawayUrl;

  factory Giveaway.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final id = idValue is int ? idValue : int.tryParse('$idValue');
    final title = json['title'];
    if (id == null || title is! String || title.trim().isEmpty) {
      throw const FormatException('Giveaway is missing a valid id or title.');
    }

    String stringValue(String key, [String fallback = '']) {
      final value = json[key];
      return value is String && value != 'N/A' ? value : fallback;
    }

    return Giveaway(
      id: id,
      title: title,
      thumbnail: stringValue('thumbnail'),
      description: stringValue('description', 'No description available.'),
      instructions: stringValue('instructions'),
      platforms: stringValue('platforms', 'Unspecified'),
      type: stringValue('type', 'Giveaway'),
      worth: stringValue('worth', 'Free'),
      endDate: stringValue('end_date', 'While supplies last'),
      openGiveawayUrl: stringValue(
        'open_giveaway_url',
        stringValue('open_giveaway'),
      ),
    );
  }
}
