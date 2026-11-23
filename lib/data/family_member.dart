class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;
  final String? imageUrl;

  String get fullName => '$prenom $postnom $nom'.trim();

  factory FamilyMember.fromJson(Map<String, dynamic> json, {Uri? baseUri}) {
    final imageUrl = json['image_url'] as String?;
    final imageUri = imageUrl == null ? null : Uri.tryParse(imageUrl);
    final imageUsesLoopbackHost =
        imageUri != null &&
        const {'localhost', '127.0.0.1', '::1'}.contains(imageUri.host);
    final resolvedImageUrl = imageUsesLoopbackHost && baseUri != null
        ? imageUri
              .replace(
                scheme: baseUri.scheme,
                host: baseUri.host,
                port: baseUri.hasPort ? baseUri.port : null,
              )
              .toString()
        : imageUrl;

    return FamilyMember(
      id: int.parse(json['id'].toString()),
      nom: json['nom'] as String,
      postnom: json['postnom'] as String,
      prenom: json['prenom'] as String,
      lieuNaissance: json['lieu_naissance'] as String,
      dateNaissance: json['date_naissance'] as String,
      parente: json['parente'] as String,
      imageUrl: resolvedImageUrl,
    );
  }

  Map<String, String> toJson() => {
    'nom': nom,
    'postnom': postnom,
    'prenom': prenom,
    'lieu_naissance': lieuNaissance,
    'date_naissance': dateNaissance,
    'parente': parente,
  };
}
