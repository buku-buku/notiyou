class CurrentParticipant {
  final String name;
  final ParticipantType type;
  final Partner? partner;

  const CurrentParticipant({
    required this.name,
    required this.type,
    this.partner,
  });

  bool get isChallenger => type == ParticipantType.challenger;
  bool get isSupporter => type == ParticipantType.supporter;
}

enum ParticipantType {
  challenger,
  supporter,
}

class Partner {
  final String name;
  final ParticipantType type;

  const Partner({
    required this.name,
    required this.type,
  });
}
