import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/profile_data.dart';
import '../../widgets/section_heading.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
            children: [
              const SectionHeading(
                eyebrow: 'Restons en contact',
                title: 'Me joindre',
              ),
              const SizedBox(height: 11),
              Text(
                'Pour une collaboration, une question ou simplement échanger, '
                'retrouvez-moi ici.',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      color: scheme.onPrimary,
                      size: 25,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Une conversation peut\ntout commencer.',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 23,
                        height: 1.12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Basé à Goma, République démocratique du Congo.',
                      style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PrimaryContactButton(
                      label: 'M’écrire par e-mail',
                      icon: Icons.mail_outline_rounded,
                      onPressed: () => _openLink(context, ProfileData.emailUri),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeading(
                eyebrow: 'Coordonnées',
                title: 'Contact direct',
              ),
              const SizedBox(height: 13),
              _ContactTile(
                icon: Icons.phone_outlined,
                label: 'TÉLÉPHONE',
                value: ProfileData.phone,
                onTap: () => _openLink(context, ProfileData.phoneUri),
                onCopy: () => _copyToClipboard(context, ProfileData.phone),
              ),
              const SizedBox(height: 9),
              _ContactTile(
                icon: Icons.mail_outline_rounded,
                label: 'E-MAIL',
                value: ProfileData.email,
                onTap: () => _openLink(context, ProfileData.emailUri),
                onCopy: () => _copyToClipboard(context, ProfileData.email),
              ),
              const SizedBox(height: 9),
              const _ContactTile(
                icon: Icons.location_on_outlined,
                label: 'RÉSIDENCE',
                value: ProfileData.location,
              ),
              const SizedBox(height: 25),
              const SectionHeading(
                eyebrow: 'Retrouvez-moi en ligne',
                title: 'Réseaux sociaux',
              ),
              const SizedBox(height: 13),
              ...ProfileData.socialLinks.map(
                (link) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _SocialTile(
                    link: link,
                    onTap: () => _openLink(context, link.uri),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Les liens s’ouvrent dans l’application associée si elle est '
                'installée, sinon dans le navigateur.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && (uri.scheme == 'https' || uri.scheme == 'http')) {
        opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else if (!opened && uri.scheme == 'mailto') {
        final webMail = Uri.https('mail.google.com', '/mail/', {
          'view': 'cm',
          'fs': '1',
          'to': uri.path,
        });
        opened = await launchUrl(webMail, mode: LaunchMode.externalApplication);
      }
    } on PlatformException {
      if (context.mounted) {
        _showLaunchError(context);
      }
      return;
    }

    if (!opened && context.mounted) {
      _showLaunchError(context);
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordonnée copiée dans le presse-papiers.'),
        ),
      );
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossible d’ouvrir ce lien sur cet appareil.'),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        leading: _ContactIcon(icon: icon),
        title: Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: onTap == null && onCopy == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onCopy != null)
                    IconButton(
                      tooltip: 'Copier $label',
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: scheme.primary,
                      size: 18,
                    ),
                ],
              ),
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({required this.link, required this.onTap});

  final SocialLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        leading: Container(
          width: 43,
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: link.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: FaIcon(link.icon, color: link.color, size: 19),
        ),
        title: Text(
          link.label,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          link.detail,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
        ),
        trailing: Icon(
          Icons.north_east_rounded,
          color: scheme.primary,
          size: 18,
        ),
      ),
    );
  }
}

class _ContactIcon extends StatelessWidget {
  const _ContactIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: scheme.primary, size: 20),
    );
  }
}

class _PrimaryContactButton extends StatelessWidget {
  const _PrimaryContactButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}
