import 'dart:async';
import 'dart:math' as math;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/profile_data.dart';
import '../../widgets/photo_gallery.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.onNavigateTo,
    required this.onToggleTheme,
    required this.onLogout,
    super.key,
  });

  final ValueChanged<int> onNavigateTo;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _certificates = [
    'assets/images/certifications/Screenshot_20230101-155943_WhatsApp_Original.jpg',
    'assets/images/certifications/IMG_9641.JPG',
    'assets/images/certifications/IMG_9643.jpg',
    'assets/images/certifications/IMG_9642.jpg',
  ];

  final _whoKey = GlobalKey();
  final _technologyKey = GlobalKey();
  final _educationKey = GlobalKey();
  final _certificationsKey = GlobalKey();
  final _ministryKey = GlobalKey();
  final _creationKey = GlobalKey();
  final _worldKey = GlobalKey();
  final _contactKey = GlobalKey();

  List<GlobalKey> get _sectionKeys => [
    _whoKey,
    _technologyKey,
    _educationKey,
    _certificationsKey,
    _ministryKey,
    _creationKey,
    _worldKey,
    _contactKey,
  ];

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  void _selectSection(int index) {
    unawaited(_scrollTo(_sectionKeys[index]));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return ColoredBox(
      color: _PortfolioColors.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(
              onSelectSection: _selectSection,
              onOpenFamily: () => widget.onNavigateTo(1),
              onToggleTheme: widget.onToggleTheme,
              onLogout: widget.onLogout,
            ),
            _PortfolioSection(
              sectionKey: _whoKey,
              number: '01',
              title: 'WHO I AM',
              child: _WhoIAmSection(
                onOpenContact: () {
                  widget.onNavigateTo(2);
                },
              ),
            ),
            _PortfolioSection(
              sectionKey: _technologyKey,
              number: '02',
              title: 'TECHNOLOGY',
              child: const _TechnologySection(),
            ),
            _PortfolioSection(
              sectionKey: _educationKey,
              number: '03',
              title: 'EDUCATION',
              child: const _EducationSection(),
            ),
            _PortfolioSection(
              sectionKey: _certificationsKey,
              number: '04',
              title: 'CERTIFICATIONS & DISTINCTIONS',
              child: _CertificationSection(certificates: _certificates),
            ),
            _PortfolioSection(
              sectionKey: _ministryKey,
              number: '05',
              title: 'MINISTRY',
              child: const _MinistrySection(),
            ),
            _PortfolioSection(
              sectionKey: _creationKey,
              number: '06',
              title: 'CREATION',
              child: const _CreationSection(),
            ),
            _PortfolioSection(
              sectionKey: _worldKey,
              number: '07',
              title: 'MY WORLD',
              child: _MyWorldSection(
                onManageFamily: () => widget.onNavigateTo(1),
              ),
            ),
            _PortfolioSection(
              sectionKey: _contactKey,
              number: '08',
              title: 'CONTACT',
              compact: true,
              child: _ContactSection(
                onOpenContact: () => widget.onNavigateTo(2),
              ),
            ),
            SizedBox(height: math.max(28.0, screenHeight * 0.035).toDouble()),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onSelectSection,
    required this.onOpenFamily,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final ValueChanged<int> onSelectSection;
  final VoidCallback onOpenFamily;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final heroHeight = math.max(screenSize.height, 700.0).toDouble();
    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/johgrace/img_2093.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.25, 0),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB3000000),
                  Color(0x16000000),
                  Color(0x30000000),
                  Color(0xF2000000),
                ],
                stops: [0, 0.32, 0.57, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenSize.width < 600 ? 22 : 52,
                14,
                screenSize.width < 600 ? 22 : 52,
                screenSize.width < 600 ? 44 : 58,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroTopBar(
                    onOpenFamily: onOpenFamily,
                    onToggleTheme: onToggleTheme,
                    onLogout: onLogout,
                  ),
                  const SizedBox(height: 17),
                  _HeroNavigation(onSelectSection: onSelectSection),
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 850),
                    curve: Curves.easeOutCubic,
                    builder: (context, opacity, child) => Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - opacity)),
                        child: child,
                      ),
                    ),
                    child: _HeroIntroduction(
                      screenWidth: screenSize.width,
                      onExplore: () => onSelectSection(0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTopBar extends StatelessWidget {
  const _HeroTopBar({
    required this.onOpenFamily,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final VoidCallback onOpenFamily;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final wide = MediaQuery.sizeOf(context).width >= 520;
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: _PortfolioColors.gold),
            shape: BoxShape.circle,
          ),
          child: const Text(
            'JS',
            style: TextStyle(
              color: _PortfolioColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Text(
            'JOHGRÂCE SELEMANI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        if (wide)
          TextButton(
            onPressed: onOpenFamily,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Ma famille'),
          )
        else
          IconButton(
            tooltip: 'Ma famille',
            onPressed: onOpenFamily,
            color: Colors.white,
            icon: const Icon(Icons.people_outline_rounded, size: 20),
          ),
        IconButton(
          tooltip: isDarkMode
              ? 'Activer le thème clair'
              : 'Activer le thème sombre',
          onPressed: onToggleTheme,
          color: Colors.white,
          icon: Icon(
            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 19,
          ),
        ),
        IconButton(
          tooltip: 'Se déconnecter',
          onPressed: onLogout,
          color: Colors.white,
          icon: const Icon(Icons.logout_rounded, size: 19),
        ),
      ],
    );
  }
}

class _HeroNavigation extends StatelessWidget {
  const _HeroNavigation({required this.onSelectSection});

  final ValueChanged<int> onSelectSection;

  static const _labels = [
    '01  WHO I AM',
    '02  TECHNOLOGY',
    '03  EDUCATION',
    '04  CERTIFICATIONS',
    '05  MINISTRY',
    '06  CREATION',
    '07  MY WORLD',
    '08  CONTACT',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < _labels.length; index++)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TextButton(
                onPressed: () => onSelectSection(index),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.78),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.15,
                  ),
                ),
                child: Text(_labels[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroIntroduction extends StatelessWidget {
  const _HeroIntroduction({required this.screenWidth, required this.onExplore});

  final double screenWidth;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1020),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PORTFOLIO PERSONNEL  /  GOMA, RDC',
            style: TextStyle(
              color: _PortfolioColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'JOHGRÂCE\nSELEMANI',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth < 600 ? 49 : 88,
              height: 0.92,
              fontWeight: FontWeight.w800,
              letterSpacing: screenWidth < 600 ? -1.5 : -3.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ProfileData.fullName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: screenWidth < 600 ? 11 : 13,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 19),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _HeroDiscipline('INFORMATIQUE'),
              _HeroDiscipline('MINISTÈRE CHRÉTIEN'),
              _HeroDiscipline('CRÉATION DE CONTENU'),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: _PortfolioColors.gold,
                size: 17,
              ),
              const SizedBox(width: 5),
              const Text(
                'GOMA, RDC',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 20),
              TextButton.icon(
                onPressed: onExplore,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.south_rounded, size: 16),
                label: const Text(
                  'DÉCOUVRIR MON PARCOURS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroDiscipline extends StatelessWidget {
  const _HeroDiscipline(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
        borderRadius: BorderRadius.circular(2),
        color: Colors.black.withValues(alpha: 0.18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _PortfolioSection extends StatelessWidget {
  const _PortfolioSection({
    required this.sectionKey,
    required this.number,
    required this.title,
    required this.child,
    this.compact = false,
  });

  final GlobalKey sectionKey;
  final String number;
  final String title;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width < 600
        ? 23.0
        : 54.0;
    return Container(
      key: sectionKey,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        compact ? 50 : 76,
        horizontalPadding,
        compact ? 50 : 76,
      ),
      decoration: BoxDecoration(
        color: compact ? const Color(0xFF0D0D0D) : _PortfolioColors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.09)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$number.',
                    style: const TextStyle(
                      color: _PortfolioColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.7,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.sizeOf(context).width < 600
                            ? 23
                            : 32,
                        height: 1.12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Container(
                    width: 42,
                    height: 1,
                    color: _PortfolioColors.gold.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _WhoIAmSection extends StatelessWidget {
  const _WhoIAmSection({required this.onOpenContact});

  final VoidCallback onOpenContact;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 820;
    final portrait = ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Image.asset(
        'assets/images/johgrace/photo_output.jpg',
        width: wide ? 330 : double.infinity,
        height: wide ? 400 : 330,
        fit: BoxFit.cover,
        alignment: const Alignment(0, 0.18),
      ),
    );
    final introduction = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallLabel('IDENTITÉ & PARCOURS'),
        const SizedBox(height: 15),
        Text(
          'Un parcours guidé par la curiosité, le service et la transmission.',
          style: TextStyle(
            color: Colors.white,
            fontSize: wide ? 29 : 24,
            height: 1.22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 17),
        Text(
          ProfileData.biography,
          style: const TextStyle(
            color: _PortfolioColors.muted,
            fontSize: 14,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 23),
        OutlinedButton.icon(
          onPressed: onOpenContact,
          style: OutlinedButton.styleFrom(
            foregroundColor: _PortfolioColors.gold,
            side: BorderSide(
              color: _PortfolioColors.gold.withValues(alpha: 0.7),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
          ),
          icon: const Icon(Icons.arrow_outward_rounded, size: 16),
          label: const Text('ENTRER EN CONTACT'),
        ),
      ],
    );
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 330, child: portrait),
          const SizedBox(width: 58),
          Expanded(child: introduction),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [portrait, const SizedBox(height: 27), introduction],
    );
  }
}

class _TechnologySection extends StatelessWidget {
  const _TechnologySection();

  @override
  Widget build(BuildContext context) {
    final technicalExperience = ProfileData.experience
        .where(
          (experience) =>
              experience.organization != 'Terre Sainte' &&
              experience.organization !=
                  'Programme conjoint JRP – DALBERG Research & AIR',
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialLead(
          'Explorer, comprendre et rendre la technologie utile au quotidien.',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final imageWidth = constraints.maxWidth >= 820
                ? constraints.maxWidth * 0.36
                : constraints.maxWidth;
            final image = ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                'assets/images/johgrace/img_7016.jpg',
                width: imageWidth,
                height: 360,
                fit: BoxFit.cover,
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SmallLabel('COMPÉTENCES'),
                const SizedBox(height: 13),
                _SkillList(skills: ProfileData.technicalSkills),
                const SizedBox(height: 25),
                const _SmallLabel('EXPÉRIENCES TECHNIQUES'),
                const SizedBox(height: 8),
                for (final experience in technicalExperience)
                  _ExperienceEntry(experience: experience),
              ],
            );
            if (constraints.maxWidth < 820) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [image, const SizedBox(height: 27), details],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                const SizedBox(width: 42),
                Expanded(child: details),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SkillList extends StatelessWidget {
  const _SkillList({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final skill in skills)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF38352E)),
              color: const Color(0xFF121212),
            ),
            child: Text(
              skill,
              style: const TextStyle(
                color: _PortfolioColors.paper,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

class _ExperienceEntry extends StatelessWidget {
  const _ExperienceEntry({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.white.withValues(alpha: 0.04),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 13),
        iconColor: _PortfolioColors.gold,
        collapsedIconColor: _PortfolioColors.muted,
        title: Text(
          experience.role,
          style: const TextStyle(
            color: _PortfolioColors.paper,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${experience.organization} · ${experience.period}',
            style: const TextStyle(color: _PortfolioColors.muted, fontSize: 11),
          ),
        ),
        children: [
          for (final responsibility in experience.responsibilities)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      color: _PortfolioColors.gold,
                      size: 5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      responsibility,
                      style: const TextStyle(
                        color: _PortfolioColors.muted,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EducationSection extends StatelessWidget {
  const _EducationSection();

  @override
  Widget build(BuildContext context) {
    final current = ProfileData.education.first;
    final earlierStudies = ProfileData.education.skip(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialLead(
          'Une formation en cours, tournée vers les réseaux et les télécommunications.',
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final logo = Container(
              width: wide ? 166 : 130,
              height: wide ? 185 : 150,
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Image.asset(
                'assets/images/isig/logo_isig.jpg',
                fit: BoxFit.contain,
                semanticLabel: 'Logo de l’ISIG-GOMA',
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SmallLabel('PARCOURS ACADÉMIQUE'),
                const SizedBox(height: 12),
                Text(
                  current.institution,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wide ? 23 : 19,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  current.title,
                  style: const TextStyle(
                    color: _PortfolioColors.gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Option Réseaux et Télécommunications',
                  style: TextStyle(color: _PortfolioColors.paper, fontSize: 14),
                ),
                const SizedBox(height: 7),
                Text(
                  current.period,
                  style: const TextStyle(
                    color: _PortfolioColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: _PortfolioColors.gold),
                  ),
                  child: const Text(
                    'Formation en cours',
                    style: TextStyle(
                      color: _PortfolioColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Logo : ISIG-GOMA · Wikimedia Commons · CC BY-SA 4.0',
                  style: TextStyle(
                    color: _PortfolioColors.muted,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            );
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: logo),
                  const SizedBox(height: 24),
                  details,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                logo,
                const SizedBox(width: 42),
                Expanded(child: details),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        const Divider(color: Color(0xFF32302B)),
        const SizedBox(height: 17),
        const _SmallLabel('FORMATIONS PRÉCÉDENTES'),
        const SizedBox(height: 14),
        for (final study in earlierStudies)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle_outlined,
                  color: _PortfolioColors.gold,
                  size: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        study.title,
                        style: const TextStyle(
                          color: _PortfolioColors.paper,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${study.institution} · ${study.period}',
                        style: const TextStyle(
                          color: _PortfolioColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CertificationSection extends StatelessWidget {
  const _CertificationSection({required this.certificates});

  final List<String> certificates;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialLead(
          'Brevets, attestations et certificats présentés tels quels.',
        ),
        const SizedBox(height: 10),
        Text(
          '${certificates.length} documents · Touchez une image pour l’agrandir',
          style: const TextStyle(color: _PortfolioColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 570
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: certificates.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.38,
              ),
              itemBuilder: (context, index) => _CertificateCard(
                assetPath: certificates[index],
                index: index,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.assetPath, required this.index});

  final String assetPath;
  final int index;

  String get _label => 'Document ${(index + 1).toString().padLeft(2, '0')}';

  Future<void> _open(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog(
        backgroundColor: _PortfolioColors.surface,
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: screen.width * 0.96,
          height: screen.height * 0.9,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 7, 7, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _label,
                        style: const TextStyle(
                          color: _PortfolioColors.paper,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fermer le document',
                      onPressed: () => Navigator.of(context).pop(),
                      color: _PortfolioColors.paper,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: InteractiveViewer(
                    minScale: 0.75,
                    maxScale: 5,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Text(
                              'Ce document ne peut pas être affiché.',
                              style: TextStyle(color: _PortfolioColors.paper),
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ouvrir $_label',
      child: Material(
        color: const Color(0xFF141414),
        child: InkWell(
          onTap: () => _open(context),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(11),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: _PortfolioColors.muted,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xE6000000)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.open_in_full_rounded,
                        color: _PortfolioColors.gold,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinistrySection extends StatelessWidget {
  const _MinistrySection();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final stories = [
      (
        'assets/images/johgrace/f9b95cb8_5b90_41d1_ba7a_064f554114ff.png',
        'PRÉDICATION',
      ),
      (
        'assets/images/johgrace/56bb2e81_be93_456e_939d_f16dbb6a8ed2.jpg',
        'ENSEIGNEMENT',
      ),
      ('assets/images/johgrace/img_5793.jpg', 'SERVICE'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialLead(
          'La foi, la parole et le service font partie de mon engagement.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Je m’investis dans le ministère chrétien à travers la prédication, '
          'l’enseignement et le partage de la foi.',
          style: TextStyle(
            color: _PortfolioColors.muted,
            fontSize: 14,
            height: 1.75,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = wide ? 3 : 1;
            final width = (constraints.maxWidth - 14 * (columns - 1)) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final story in stories)
                  SizedBox(
                    width: width,
                    child: _StoryPhoto(
                      imagePath: story.$1,
                      title: story.$2,
                      height: wide ? 320 : 275,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CreationSection extends StatelessWidget {
  const _CreationSection();

  @override
  Widget build(BuildContext context) {
    final mediaExperience = ProfileData.experience.first;
    final wide = MediaQuery.sizeOf(context).width >= 760;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialLead(
          'Des images, du son et des récits pour faire vivre les idées.',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = 16.0;
            final width = wide
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: width,
                  child: _StoryPhoto(
                    imagePath: 'assets/images/johgrace/0d9a7029_original.jpg',
                    title: 'IMAGE & PRISE DE PAROLE',
                    height: wide ? 430 : 330,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _StoryPhoto(
                    imagePath: 'assets/images/johgrace/img_7016.jpg',
                    title: 'AUDIOVISUEL & MÉDIAS',
                    height: wide ? 430 : 330,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 23),
        Text(
          mediaExperience.role,
          style: const TextStyle(
            color: _PortfolioColors.paper,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${mediaExperience.organization} · ${mediaExperience.period}',
          style: const TextStyle(
            color: _PortfolioColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          mediaExperience.responsibilities.join(' '),
          style: const TextStyle(
            color: _PortfolioColors.muted,
            fontSize: 13,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _StoryPhoto extends StatelessWidget {
  const _StoryPhoto({
    required this.imagePath,
    required this.title,
    required this.height,
  });

  final String imagePath;
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000000)],
                  stops: [0.48, 1],
                ),
              ),
            ),
            Positioned(
              left: 17,
              right: 17,
              bottom: 17,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyWorldSection extends StatelessWidget {
  const _MyWorldSection({required this.onManageFamily});

  final VoidCallback onManageFamily;

  @override
  Widget build(BuildContext context) {
    final family = ProfileData.family
        .where((member) => member.relation != 'Moi-même')
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialLead(
          'Les personnes qui donnent du sens à mon histoire.',
        ),
        const SizedBox(height: 11),
        const Text(
          'Quelques portraits de ma famille. La galerie et les outils de gestion '
          'des membres restent disponibles dans l’espace familial.',
          style: TextStyle(
            color: _PortfolioColors.muted,
            fontSize: 13,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 650
                ? 3
                : 2;
            final gap = 14.0;
            final cardWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: 22,
              children: [
                for (final member in family)
                  SizedBox(
                    width: cardWidth,
                    child: _FamilyPortrait(member: member),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        OutlinedButton.icon(
          onPressed: onManageFamily,
          style: OutlinedButton.styleFrom(
            foregroundColor: _PortfolioColors.gold,
            side: BorderSide(
              color: _PortfolioColors.gold.withValues(alpha: 0.7),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
          ),
          icon: const Icon(Icons.people_outline_rounded, size: 17),
          label: const Text('GÉRER LES MEMBRES DE MA FAMILLE'),
        ),
      ],
    );
  }
}

class _FamilyPortrait extends StatelessWidget {
  const _FamilyPortrait({required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageHeight = width < 600 ? 190.0 : 255.0;
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoThumbnail(
            personName: member.name,
            photos: member.photos,
            index: 0,
            width: constraints.maxWidth,
            height: imageHeight,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 10),
          Text(
            member.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _PortfolioColors.paper,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            member.relation.toUpperCase(),
            style: const TextStyle(
              color: _PortfolioColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.onOpenContact});

  final VoidCallback onOpenContact;

  @override
  Widget build(BuildContext context) {
    final featuredSocials = ProfileData.socialLinks
        .where((link) => link.label == 'YouTube' || link.label == 'TikTok')
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialLead(
          'Pour un projet, une collaboration ou un échange.',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final contactDetails = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactDetail(
                  icon: Icons.phone_outlined,
                  label: 'TÉLÉPHONE',
                  value: ProfileData.phone,
                  onTap: onOpenContact,
                ),
                const SizedBox(height: 15),
                _ContactDetail(
                  icon: Icons.mail_outline_rounded,
                  label: 'E-MAIL',
                  value: ProfileData.email,
                  onTap: onOpenContact,
                ),
                const SizedBox(height: 15),
                _ContactDetail(
                  icon: Icons.location_on_outlined,
                  label: 'LOCALISATION',
                  value: ProfileData.location,
                  onTap: onOpenContact,
                ),
              ],
            );
            final socials = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SmallLabel('RÉSEAUX'),
                const SizedBox(height: 10),
                for (final link in featuredSocials)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SocialLinkRow(link: link, onTap: onOpenContact),
                  ),
              ],
            );
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [contactDetails, const SizedBox(height: 25), socials],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: contactDetails),
                const SizedBox(width: 70),
                SizedBox(width: 245, child: socials),
              ],
            );
          },
        ),
        const SizedBox(height: 25),
        FilledButton.icon(
          onPressed: onOpenContact,
          style: FilledButton.styleFrom(
            backgroundColor: _PortfolioColors.gold,
            foregroundColor: _PortfolioColors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          icon: const Icon(Icons.arrow_outward_rounded, size: 16),
          label: const Text('OUVRIR LA PAGE CONTACT'),
        ),
        const SizedBox(height: 38),
        const Divider(color: Color(0xFF34312B)),
        const SizedBox(height: 14),
        const Text(
          'JOHGRÂCE SELEMANI  ·  GOMA, RDC',
          style: TextStyle(
            color: _PortfolioColors.muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _ContactDetail extends StatelessWidget {
  const _ContactDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(icon, color: _PortfolioColors.gold, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _PortfolioColors.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: _PortfolioColors.paper,
                      fontSize: 14,
                    ),
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

class _SocialLinkRow extends StatelessWidget {
  const _SocialLinkRow({required this.link, required this.onTap});

  final SocialLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _PortfolioColors.paper,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        alignment: Alignment.centerLeft,
        backgroundColor: const Color(0xFF151515),
      ),
      child: Row(
        children: [
          FaIcon(link.icon, color: _PortfolioColors.gold, size: 15),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.label, style: const TextStyle(fontSize: 12)),
                Text(
                  link.detail,
                  style: const TextStyle(
                    color: _PortfolioColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.north_east_rounded,
            color: _PortfolioColors.gold,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _EditorialLead extends StatelessWidget {
  const _EditorialLead(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _PortfolioColors.paper,
        fontSize: 19,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _PortfolioColors.gold,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
      ),
    );
  }
}

abstract final class _PortfolioColors {
  static const black = Color(0xFF080808);
  static const surface = Color(0xFF111111);
  static const paper = Color(0xFFEDEAE2);
  static const muted = Color(0xFFA8A49B);
  static const gold = Color(0xFFD7B66D);
}
