import 'package:material_ui/material_ui.dart';

import '../../data/profile_data.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/section_heading.dart';

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 740 ? 2 : 1;
              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
                children: [
                  SectionHeading(
                    eyebrow: 'Mes racines',
                    title: 'Ma famille',
                    trailing: Icon(
                      Icons.favorite_rounded,
                      color: scheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Les personnes qui partagent mon histoire et '
                    'm’accompagnent au quotidien.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 21),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.diversity_3_outlined,
                          color: scheme.onPrimary,
                          size: 34,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MON CERCLE',
                                style: TextStyle(
                                  color: scheme.onPrimary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${ProfileData.family.length} membres de ma famille',
                                style: TextStyle(
                                  color: scheme.onPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 19),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ProfileData.family.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.75,
                    ),
                    itemBuilder: (context, index) =>
                        _FamilyCard(member: ProfileData.family[index]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PhotoThumbnail(
              personName: member.name,
              photos: member.photos,
              index: 0,
              width: 82,
              height: 118,
              borderRadius: BorderRadius.circular(15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.relation.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.secondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    member.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.profession,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 5),
                  TextButton.icon(
                    onPressed: () => showPhotoGallery(
                      context,
                      personName: member.name,
                      photos: member.photos,
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: Text('${member.photos.length} photos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
