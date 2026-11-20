import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../core/app_theme.dart';

class ProfileData {
  static const displayName = 'JohGrâce Selemani';
  static const fullName = 'Sadiki Selemani Joseph Grâce';
  static const role = 'INFORMATICIEN | PASTEUR';
  static const nationality = 'Congolaise';
  static const birth = 'Né le 2 août 2000 à Kinshasa';
  static const location = 'Goma, RDC';
  static const email = 'selemanijoseph575@gmail.com';
  static const phone = '+243 980 041 610';
  static const whatsappPhone = '+243 837 610 254';
  static const biography =
      'Étudiant en Licence en Systèmes Informatiques, option Réseaux et '
      'Télécommunications à l’ISIG-Goma, je développe un profil polyvalent '
      'dans les domaines du support informatique, de la maintenance, des '
      'systèmes informatiques et de l’audiovisuel.\n\n'
      'Mes expériences professionnelles m’ont permis de participer à '
      'l’assistance technique aux utilisateurs, à la maintenance des '
      'équipements informatiques, aux opérations sur les sites télécoms '
      'ainsi qu’à la gestion technique et médiatique d’activités.\n\n'
      'En parallèle de mon parcours informatique, je suis engagé dans le '
      'ministère chrétien et la création de contenu. Je m’intéresse '
      'particulièrement aux solutions numériques, à la technologie, à la '
      'communication et à la transmission de connaissances.\n\n'
      'Je privilégie la résolution de problèmes, l’adaptabilité, '
      'l’apprentissage continu et le travail en équipe.';

  static const education = <Education>[
    Education(
      title: 'Licence en Systèmes Informatiques',
      institution: 'ISIG-Goma',
      period: 'Novembre 2023 – aujourd’hui',
      detail:
          'Option Réseaux et Télécommunications · Formation en cours · '
          'Fin prévue : juillet 2027',
      isCurrent: true,
    ),
    Education(
      title: 'Diplôme d’État en Latin-Philo',
      institution: 'Collège Alfajiri, Bukavu',
      period: '2013 – 2019',
    ),
    Education(
      title: 'Certificat de fin d’études primaires',
      institution: 'EP 1 Ibanda, Bukavu',
      period: '2006 – 2012',
    ),
  ];

  static const certifications = <Education>[
    Education(
      title: 'Formation en sonorisation',
      institution: 'EL GHIBOR, Goma',
      period: 'Juin – septembre 2022',
    ),
    Education(
      title: 'Hikvision Access Control',
      institution: 'Certification Hikvision',
      period: 'Septembre 2024',
    ),
    Education(
      title: 'Hikvision CCTV',
      institution: 'Certification Hikvision',
      period: 'Septembre 2024',
    ),
    Education(
      title: 'Maladie à Virus Ebola (MVE)',
      institution: 'INSP RDC · Resolve to Save Lives / HealthLearn',
      period: '18 septembre 2026',
      detail: 'Certificat de formation PRÉCIS',
    ),
  ];

  static const experience = <Experience>[
    Experience(
      organization: 'Terre Sainte',
      role: 'Responsable Médias et Ingénieur de son',
      period: 'Janvier 2025 – aujourd’hui',
      responsibilities: [
        'Captation, enregistrement et mixage audio des cultes, podcasts et reportages.',
        'Supervision de la régie, du streaming et de la diffusion FM/DAB+.',
        'Maintenance préventive et résolution des défaillances techniques.',
      ],
    ),
    Experience(
      organization: 'MD Engineering SARL',
      role: 'Stagiaire académique',
      period: '2026',
      responsibilities: [
        'Participation à la maintenance des sites télécoms.',
        'Intervention sur les installations électriques, les équipements réseau et la transmission.',
      ],
    ),
    Experience(
      organization: 'Programme conjoint JRP – DALBERG Research & AIR',
      role: 'Chercheur terrain',
      period: 'Juillet – octobre 2024',
      responsibilities: [
        'Planification et réalisation d’enquêtes quantitatives et qualitatives.',
        'Recrutement des répondants et recueil du consentement éclairé.',
        'Collecte et transmission des données au superviseur.',
      ],
    ),
    Experience(
      organization: 'CGAT-GOMA',
      role: 'IT Support',
      period: 'Juin 2023 – février 2025',
      responsibilities: [
        'Support informatique et assistance technique aux utilisateurs.',
        'Maintenance et dépannage des équipements informatiques.',
      ],
    ),
  ];

  static const technicalSkills = <String>[
    'Sécurité informatique',
    'Virtualisation',
    'Dépannage et maintenance informatique',
    'Systèmes Windows / Linux',
    'Configuration de systèmes',
    'Pack Office',
    'OBS Studio',
  ];

  static const strengths = <String>[
    'Résolution des problèmes',
    'Polyvalence technique',
    'Esprit d’analyse',
    'Autonomie et adaptabilité',
    'Travail en équipe',
  ];

  static const languages = <Language>[
    Language(name: 'Français', level: 'Courant'),
    Language(name: 'Anglais', level: 'Élémentaire'),
    Language(name: 'Swahili', level: 'Débutant'),
    Language(name: 'Lingala', level: 'Avancé'),
  ];

  static const family = <FamilyMember>[
    FamilyMember(
      name: 'Matakio Annonciate',
      relation: 'Mère',
      profession: 'Cheffe de division',
      photos: [
        'assets/images/famille/matakio_annonciate/71132ab4_2ac0_417f_8ef0_c605efb87071.jpg',
        'assets/images/famille/matakio_annonciate/1697608779583_original.jpg',
        'assets/images/famille/matakio_annonciate/1688580808015_copy_original.jpg',
      ],
    ),
    FamilyMember(
      name: 'Mitila Linda Harmonie',
      relation: 'Grande sœur',
      profession: 'Médecin',
      photos: [
        'assets/images/famille/mitila_linda_harmonie/1388f73b_a293_4876_9537_d60cdf1eedb6.jpg',
        'assets/images/famille/mitila_linda_harmonie/8810901c_ffca_403e_b5a5_89da56de28a7.jpg',
        'assets/images/famille/mitila_linda_harmonie/a2e75acd_b297_43b2_9505_ef7dafa9da17.jpg',
        'assets/images/famille/mitila_linda_harmonie/fc342e69_9084_40e6_85bd_30ff30f9babb.jpg',
      ],
    ),
    FamilyMember(
      name: 'Nyota Atosha Nadia',
      relation: 'Grande sœur',
      profession: 'Responsable financière',
      photos: [
        'assets/images/famille/nyota_atosha_nadia/img_8965.jpg',
        'assets/images/famille/nyota_atosha_nadia/img_4744.jpg',
        'assets/images/famille/nyota_atosha_nadia/e3bc16cd_7094_4d9a_b168_638bfb8035ec.jpg',
      ],
    ),
    FamilyMember(
      name: 'Aganze ILUMBA Trésor',
      relation: 'Frère',
      profession: 'Agronome',
      photos: [
        'assets/images/famille/aganze_ilumba_tresor/53d489c0_75ef_430f_9311_af3a75170971.jpg',
        'assets/images/famille/aganze_ilumba_tresor/ea415092_4bff_429e_8da4_68709ca92a09.jpg',
        'assets/images/famille/aganze_ilumba_tresor/ffbb8baa_db3c_464a_99e8_fdfb7dd9af4f.jpg',
        'assets/images/famille/aganze_ilumba_tresor/6deeb12f_aa24_4194_a297_c36da652a238.jpg',
      ],
    ),
    FamilyMember(
      name: 'Nabintu Fesa Deborah',
      relation: 'Sœur',
      profession: 'Institutrice',
      photos: [
        'assets/images/famille/nabintu_fesa_deborah/dc714554_0f08_422c_9d3a_d0e156650c64.jpg',
        'assets/images/famille/nabintu_fesa_deborah/36f4838d_f754_4a83_afa0_5a45cd7d7eee.jpg',
        'assets/images/famille/nabintu_fesa_deborah/img_7249.jpg',
        'assets/images/famille/nabintu_fesa_deborah/d8c6657d_8693_486f_9fa5_0156acc4c9c9.jpg',
      ],
    ),
    FamilyMember(
      name: fullName,
      relation: 'Moi-même',
      profession: 'Informaticien et pasteur',
      photos: [
        'assets/images/johgrace/img_7016.jpg',
        'assets/images/johgrace/img_6877.jpg',
        'assets/images/johgrace/aab5fc94_839d_4957_9c7c_076a6c0958f5.jpg',
        'assets/images/johgrace/f9b95cb8_5b90_41d1_ba7a_064f554114ff.png',
        'assets/images/johgrace/img_5793.jpg',
        'assets/images/johgrace/img_4819.jpg',
        'assets/images/johgrace/9bc58013_3c20_458e_8943_d6aef860a9b3.jpg',
        'assets/images/johgrace/img_8626.jpg',
        'assets/images/johgrace/jographic_55joe_original.jpg',
        'assets/images/johgrace/photo_output.jpg',
        'assets/images/johgrace/img_2093.jpg',
        'assets/images/johgrace/40c8cb9f_bea5_4e1b_8d5d_09786683ad2a.jpg',
        'assets/images/johgrace/a79ace56_4044_4269_818a_9dff04eed079.jpg',
        'assets/images/johgrace/56bb2e81_be93_456e_939d_f16dbb6a8ed2.jpg',
        'assets/images/johgrace/0d9a7029_original.jpg',
        'assets/images/johgrace/photo_output_1.jpg',
        'assets/images/johgrace/img_7797.jpg',
        'assets/images/johgrace/img_7031.jpg',
        'assets/images/johgrace/4dd4020a_7518_47d2_8d31_bfb3d967057c.jpg',
        'assets/images/johgrace/dsc01595_original.jpg',
        'assets/images/johgrace/ef164fa5_b0a2_4038_bc65_886588c53509.png',
      ],
    ),
  ];

  static final phoneUri = Uri(scheme: 'tel', path: '+243980041610');
  static final emailUri = Uri(scheme: 'mailto', path: email);

  static final socialLinks = <SocialLink>[
    SocialLink(
      label: 'YouTube',
      detail: '@iamjohgrace',
      uri: Uri.parse('https://youtube.com/@iamjohgrace'),
      icon: FontAwesomeIcons.youtube,
      color: const Color(0xFFFF0033),
    ),
    SocialLink(
      label: 'TikTok',
      detail: '@iamjohgrace',
      uri: Uri.parse('https://www.tiktok.com/@iamjohgrace'),
      icon: FontAwesomeIcons.tiktok,
      color: AppColors.ink,
    ),
    SocialLink(
      label: 'Facebook',
      detail: 'Profil Facebook',
      uri: Uri.parse(
        'https://www.facebook.com/share/1CSyiTfwq3/?mibextid=wwXIfr',
      ),
      icon: FontAwesomeIcons.facebookF,
      color: const Color(0xFF1877F2),
    ),
    SocialLink(
      label: 'Facebook · 2',
      detail: 'Autre lien Facebook',
      uri: Uri.parse(
        'https://www.facebook.com/share/1MTwLoSbkw/?mibextid=wwXIfr',
      ),
      icon: FontAwesomeIcons.facebookF,
      color: const Color(0xFF1877F2),
    ),
    SocialLink(
      label: 'Instagram',
      detail: '@iamjohgrace',
      uri: Uri.parse('https://www.instagram.com/iamjohgrace/'),
      icon: FontAwesomeIcons.instagram,
      color: const Color(0xFFC13584),
    ),
    SocialLink(
      label: 'LinkedIn',
      detail: 'joseph-grace-selemani',
      uri: Uri.parse('https://www.linkedin.com/in/joseph-grace-selemani/'),
      icon: FontAwesomeIcons.linkedinIn,
      color: const Color(0xFF0A66C2),
    ),
    SocialLink(
      label: 'GitHub',
      detail: 'Iamjohgrace0208',
      uri: Uri.parse('https://github.com/Iamjohgrace0208'),
      icon: FontAwesomeIcons.github,
      color: AppColors.ink,
    ),
    SocialLink(
      label: 'Telegram',
      detail: '@iamjohgrace',
      uri: Uri.parse('https://t.me/iamjohgrace'),
      icon: FontAwesomeIcons.telegram,
      color: const Color(0xFF229ED9),
    ),
    SocialLink(
      label: 'Snapchat',
      detail: 'Profil Snapchat',
      uri: Uri.parse('https://snapchat.com/t/zSp8qjVe'),
      icon: FontAwesomeIcons.snapchat,
      color: const Color(0xFFFFC900),
    ),
    SocialLink(
      label: 'WhatsApp',
      detail: whatsappPhone,
      uri: Uri.parse('https://wa.me/243837610254'),
      icon: FontAwesomeIcons.whatsapp,
      color: const Color(0xFF25D366),
    ),
  ];
}

class Education {
  const Education({
    required this.title,
    required this.institution,
    required this.period,
    this.detail,
    this.isCurrent = false,
  });

  final String title;
  final String institution;
  final String period;
  final String? detail;
  final bool isCurrent;
}

class Experience {
  const Experience({
    required this.organization,
    required this.role,
    required this.period,
    required this.responsibilities,
  });

  final String organization;
  final String role;
  final String period;
  final List<String> responsibilities;
}

class Language {
  const Language({required this.name, required this.level});

  final String name;
  final String level;
}

class FamilyMember {
  const FamilyMember({
    required this.name,
    required this.relation,
    required this.profession,
    required this.photos,
  });

  final String name;
  final String relation;
  final String profession;
  final List<String> photos;
}

class SocialLink {
  const SocialLink({
    required this.label,
    required this.detail,
    required this.uri,
    required this.icon,
    required this.color,
  });

  final String label;
  final String detail;
  final Uri uri;
  final FaIconData icon;
  final Color color;
}
