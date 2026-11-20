import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_theme.dart';
import '../../data/profile_data.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/section_heading.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onNavigateTo, super.key});

  final ValueChanged<int> onNavigateTo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              Text(
                'PORTFOLIO PERSONNEL',
                style: TextStyle(
                  color: context.appForest,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 17),
              _ProfileCard(onNavigateTo: onNavigateTo),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onNavigateTo(1),
                    icon: const Icon(Icons.family_restroom_rounded),
                    label: const Text('Découvrir ma famille'),
                  ),
                  FilledButton.icon(
                    onPressed: () => onNavigateTo(2),
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('Me contacter'),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              const _SectionLabel(eyebrow: 'Profil', title: 'En quelques mots'),
              const SizedBox(height: 12),
              Text(
                ProfileData.biography,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 21),
              const _PersonalDetails(),
              const SizedBox(height: 27),
              const _SectionLabel(
                eyebrow: 'Parcours académique',
                title: 'Formation',
              ),
              const SizedBox(height: 14),
              ...ProfileData.education.map(
                (item) => _EducationCard(item: item),
              ),
              const SizedBox(height: 13),
              const _SectionLabel(
                eyebrow: 'Formations complémentaires',
                title: 'Certificats',
              ),
              const SizedBox(height: 14),
              ...ProfileData.certifications.map(
                (item) => _EducationCard(item: item),
              ),
              const SizedBox(height: 14),
              const _SectionLabel(
                eyebrow: 'Expérience professionnelle',
                title: 'Sur le terrain',
              ),
              const SizedBox(height: 14),
              ...ProfileData.experience.map(
                (item) => _ExperienceCard(experience: item),
              ),
              const SizedBox(height: 14),
              _SkillSection(
                title: 'Compétences techniques',
                icon: Icons.settings_suggest_outlined,
                skills: ProfileData.technicalSkills,
              ),
              const SizedBox(height: 12),
              _SkillSection(
                title: 'Atouts',
                icon: Icons.auto_awesome_outlined,
                skills: ProfileData.strengths,
              ),
              const SizedBox(height: 22),
              const _SectionLabel(eyebrow: 'Communication', title: 'Langues'),
              const SizedBox(height: 13),
              Card(
                child: Column(
                  children: ProfileData.languages
                      .map((language) => _LanguageRow(language: language))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              _PersonalGallery(member: ProfileData.family.last),
              const SizedBox(height: 24),
              const _SectionLabel(
                eyebrow: 'Réseaux sociaux',
                title: 'Me retrouver en ligne',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final link in ProfileData.socialLinks)
                    ActionChip(
                      avatar: FaIcon(link.icon, color: link.color, size: 15),
                      label: Text(link.label),
                      onPressed: () => onNavigateTo(2),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalGallery extends StatelessWidget {
  const _PersonalGallery({required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeading(
              eyebrow: 'Galerie personnelle',
              title: 'Quelques portraits',
            ),
            TextButton(
              onPressed: () => showPhotoGallery(
                context,
                personName: member.name,
                photos: member.photos,
              ),
              child: Text('${member.photos.length} photos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: member.photos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => PhotoThumbnail(
              personName: member.name,
              photos: member.photos,
              index: index,
              width: 92,
              height: 126,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onNavigateTo});

  final ValueChanged<int> onNavigateTo;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Theme.of(context).colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoThumbnail(
            personName: ProfileData.fullName,
            photos: ProfileData.family.last.photos,
            index: 0,
            width: 83,
            height: 112,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JOHGRÂCE SELEMANI',
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ProfileData.fullName,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 18,
                    height: 1.16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ProfileData.role,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 11),
                _ProfileFact(
                  icon: Icons.location_on_outlined,
                  text: ProfileData.location,
                  color: foregroundColor,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => onNavigateTo(2),
                  style: TextButton.styleFrom(
                    foregroundColor: foregroundColor,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Parlons ensemble'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFact extends StatelessWidget {
  const _ProfileFact({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text, style: TextStyle(color: color, fontSize: 11)),
        ),
      ],
    );
  }
}

class _PersonalDetails extends StatelessWidget {
  const _PersonalDetails();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(
              icon: Icons.cake_outlined,
              label: 'Naissance',
              value: ProfileData.birthday,
            ),
            const Divider(height: 22),
            _DetailRow(
              icon: Icons.flag_outlined,
              label: 'Nationalité',
              value: ProfileData.nationality,
            ),
            const Divider(height: 22),
            _DetailRow(
              icon: Icons.school_outlined,
              label: 'Formation actuelle',
              value: 'Licence en cours · fin prévue en juillet 2027',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: scheme.primary, size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SectionHeading(eyebrow: eyebrow, title: title);
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.item});

  final Education item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.isCurrent
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  item.isCurrent
                      ? Icons.school_outlined
                      : Icons.workspace_premium_outlined,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.period.toUpperCase(),
                      style: TextStyle(
                        color: scheme.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.institution,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (item.detail != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.detail!,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurface, fontSize: 11),
                      ),
                    ],
                    if (item.isCurrent) ...[
                      const SizedBox(height: 8),
                      const _StatusTag(label: 'EN COURS'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Card(
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            experience.role,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.organization,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  experience.period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          children: experience.responsibilities
              .map(
                (responsibility) => Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 5,
                          color: scheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          responsibility,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SkillSection extends StatelessWidget {
  const _SkillSection({
    required this.title,
    required this.icon,
    required this.skills,
  });

  final String title;
  final IconData icon;
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary, size: 19),
                const SizedBox(width: 9),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    final isLast = language == ProfileData.languages.last;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  language.name,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                language.level,
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!isLast) const Divider(height: 16),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}
