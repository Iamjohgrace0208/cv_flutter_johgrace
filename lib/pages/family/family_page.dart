import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../data/api_service.dart';
import '../../data/family_name_matcher.dart';
import '../../data/family_member.dart';
import '../../data/profile_data.dart' as profile;
import '../../widgets/photo_gallery.dart';
import '../../widgets/section_heading.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<FamilyMember> _members = const [];
  String? _error;
  bool _loading = true;
  bool _saving = false;
  bool _importingLegacyMember = false;
  int _legacyIndex = 0;
  final Map<int, _LegacyImportStatus> _legacyStatuses = {};
  final Map<int, String> _legacyErrors = {};
  final Map<int, _LegacyFormAction> _legacyDrafts = {};

  List<profile.FamilyMember> get _legacyMembers => profile.ProfileData.family;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMembers());
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    try {
      final members = await widget.apiService.getFamilyMembers();
      if (!mounted) return;
      setState(() {
        _members = members;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editMember([FamilyMember? member]) async {
    final result = await showDialog<_MemberFormResult>(
      context: context,
      builder: (_) => _FamilyMemberFormDialog(member: member),
    );
    if (result == null) return;

    setState(() => _saving = true);
    try {
      if (member == null) {
        await widget.apiService.createFamilyMember(result.values);
      } else {
        await widget.apiService.updateFamilyMember(member.id, result.values);
      }
      if (!mounted) return;
      await _loadMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(member == null ? 'Membre ajouté.' : 'Membre modifié.'),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _runLegacyImport() async {
    if (_importingLegacyMember || _legacyIndex >= _legacyMembers.length) {
      return;
    }

    setState(() => _importingLegacyMember = true);
    try {
      while (mounted && _legacyIndex < _legacyMembers.length) {
        final source = _legacyMembers[_legacyIndex];
        final action = await showDialog<_LegacyFormAction>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _LegacyMemberFormDialog(
            source: source,
            draft: _legacyDrafts[_legacyIndex],
          ),
        );
        if (!mounted || action == null || action.kind == _LegacyAction.cancel) {
          return;
        }
        if (action.kind == _LegacyAction.skip) {
          _recordLegacyResult(_LegacyImportStatus.skipped);
          continue;
        }
        _legacyDrafts[_legacyIndex] = action;

        setState(() => _saving = true);
        final List<FamilyMember> latestMembers;
        try {
          latestMembers = await widget.apiService.getFamilyMembers();
        } on ApiException catch (error) {
          if (!mounted) return;
          _recordLegacyFailure(error.message);
          return;
        } finally {
          if (mounted) setState(() => _saving = false);
        }
        if (!mounted) return;
        setState(() {
          _members = latestMembers;
          _error = null;
        });

        final nameMatch = matchFamilyNames([
          source.name,
          '${action.values['nom']} ${action.values['postnom']} '
              '${action.values['prenom']}',
        ], latestMembers);
        if (nameMatch.kind == FamilyNameMatchKind.exact) {
          _recordLegacyResult(_LegacyImportStatus.alreadyPresent);
          continue;
        }

        final confirmation = await _confirmLegacyImport(
          source,
          action,
          nameMatch,
        );
        if (!mounted || confirmation == _LegacyConfirmation.cancel) return;
        if (confirmation == _LegacyConfirmation.skip) {
          _recordLegacyResult(_LegacyImportStatus.skipped);
          continue;
        }

        Uint8List? imageBytes;
        if (action.uploadPhoto && source.photos.isNotEmpty) {
          try {
            final imageData = await rootBundle.load(source.photos.first);
            imageBytes = imageData.buffer.asUint8List(
              imageData.offsetInBytes,
              imageData.lengthInBytes,
            );
          } on FlutterError catch (error) {
            if (!mounted) return;
            _recordLegacyFailure(
              'Impossible de charger la photo principale : ${error.message}',
            );
            return;
          }
        }

        setState(() => _saving = true);
        try {
          await widget.apiService.createFamilyMember(
            action.values,
            imageBytes: imageBytes,
            imageFilename: imageBytes == null
                ? null
                : source.photos.first.split('/').last,
          );
        } on ApiException catch (error) {
          if (!mounted) return;
          _recordLegacyFailure(error.message);
          return;
        } finally {
          if (mounted) setState(() => _saving = false);
        }
        if (!mounted) return;

        _recordLegacyResult(_LegacyImportStatus.imported);
        unawaited(_loadMembers());
      }

      if (mounted) _showLegacySummary();
    } finally {
      if (mounted) setState(() => _importingLegacyMember = false);
    }
  }

  Future<_LegacyConfirmation> _confirmLegacyImport(
    profile.FamilyMember source,
    _LegacyFormAction action,
    FamilyNameMatchResult match,
  ) async {
    final isUncertain = match.kind == FamilyNameMatchKind.uncertain;
    final matchedNames = match.members
        .map((member) => member.fullName)
        .join('\n');
    final result = await showDialog<_LegacyConfirmation>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Vérifier avant l’importation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ancien profil : ${source.name}'),
              const SizedBox(height: 12),
              for (final entry in [
                ('Nom', action.values['nom']!),
                ('Postnom', action.values['postnom']!),
                ('Prénom', action.values['prenom']!),
                ('Date de naissance', action.values['date_naissance']!),
                ('Lieu de naissance', action.values['lieu_naissance']!),
                ('Lien de parenté', action.values['parente']!),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${entry.$1} : ${entry.$2}'),
                ),
              Text(
                'Photo principale : ${action.uploadPhoto ? 'envoyée' : 'non envoyée'}',
              ),
              if (isUncertain) ...[
                const SizedBox(height: 12),
                Text(
                  'Correspondance possible à vérifier manuellement :\n$matchedNames\n'
                  'Aucun doublon exact n’a été trouvé. Confirmez uniquement '
                  'si cette personne est différente.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'La profession et les autres photos restent dans les données locales.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _LegacyConfirmation.cancel),
            child: const Text('Annuler'),
          ),
          if (isUncertain)
            TextButton(
              onPressed: () => Navigator.pop(context, _LegacyConfirmation.skip),
              child: const Text('Passer'),
            ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, _LegacyConfirmation.confirm),
            child: Text(isUncertain ? 'Importer quand même' : 'Importer'),
          ),
        ],
      ),
    );
    return result ?? _LegacyConfirmation.cancel;
  }

  void _recordLegacyResult(_LegacyImportStatus status) {
    setState(() {
      _legacyStatuses[_legacyIndex] = status;
      _legacyErrors.remove(_legacyIndex);
      _legacyDrafts.remove(_legacyIndex);
      _legacyIndex++;
    });
  }

  void _recordLegacyFailure(String message) {
    setState(() {
      _legacyStatuses[_legacyIndex] = _LegacyImportStatus.failed;
      _legacyErrors[_legacyIndex] = message;
    });
    _showError(message);
  }

  void _showLegacySummary() {
    final counts = {
      _LegacyImportStatus.imported: 'Importés',
      _LegacyImportStatus.alreadyPresent: 'Déjà présents',
      _LegacyImportStatus.skipped: 'Passés',
      _LegacyImportStatus.failed: 'Échecs',
    };
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Résultat du parcours'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < _legacyMembers.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_legacyMembers[index].name} — '
                    '${_legacyStatusLabel(_legacyStatuses[index])}'
                    '${_legacyErrors[index] == null ? '' : ': ${_legacyErrors[index]}'}',
                  ),
                ),
              const SizedBox(height: 8),
              for (final entry in counts.entries)
                Text(
                  '${entry.value} : '
                  '${_legacyStatuses.values.where((status) => status == entry.key).length}',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text('Cette action supprimera ${member.fullName} de la base.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await widget.apiService.deleteFamilyMember(member.id);
      if (!mounted) return;
      await _loadMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Membre supprimé.')));
    } on ApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _editMember(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Ajouter'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: RefreshIndicator(
              onRefresh: _loadMembers,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 100),
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
                    'Les membres sont consultés et gérés depuis la base de '
                    'données via l’API.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.diversity_3_outlined,
                          color: scheme.onPrimary,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '${_members.length} membre${_members.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: scheme.onPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualiser',
                          onPressed: _loading ? null : _loadMembers,
                          color: scheme.onPrimary,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                  if (_loading && _members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(38),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null && _members.isEmpty)
                    _LoadError(message: _error!, onRetry: _loadMembers)
                  else if (_members.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.diversity_3_outlined,
                              color: scheme.secondary,
                              size: 32,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Aucun membre enregistré. Utilisez « Ajouter » '
                              'pour créer le premier.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    const SizedBox(height: 16),
                    for (final member in _members)
                      _FamilyMemberCard(
                        member: member,
                        onEdit: () => _editMember(member),
                        onDelete: () => _deleteMember(member),
                      ),
                  ],
                  const SizedBox(height: 24),
                  const SectionHeading(
                    eyebrow: 'Données locales conservées',
                    title: 'Anciens membres du portfolio',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chaque membre peut être importé séparément après votre '
                    'confirmation. Les noms, la date et le lieu de naissance '
                    'doivent être vérifiés et complétés. La profession n’est '
                    'pas prise en charge par l’API et reste dans ces données '
                    'locales ; les albums photo ne sont pas supprimés.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  if (_legacyIndex < _legacyMembers.length)
                    _LegacyProfileCard(
                      member: _legacyMembers[_legacyIndex],
                      step: _legacyIndex + 1,
                      total: _legacyMembers.length,
                      status: _legacyStatuses[_legacyIndex],
                      error: _legacyErrors[_legacyIndex],
                      onImport: _saving || _importingLegacyMember
                          ? null
                          : _runLegacyImport,
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Tous les anciens membres ont reçu un résultat. '
                        'Les imports réussis ne seront pas recommencés.',
                      ),
                    ),
                  for (var index = 0; index < _legacyIndex; index++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_legacyMembers[index].name),
                      subtitle: Text(
                        _legacyErrors[index] ??
                            _legacyStatusLabel(_legacyStatuses[index]),
                      ),
                      leading: Icon(
                        _legacyStatusIcon(_legacyStatuses[index]),
                        color:
                            _legacyStatuses[index] == _LegacyImportStatus.failed
                            ? scheme.error
                            : scheme.primary,
                      ),
                    ),
                  if (_saving)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegacyProfileCard extends StatelessWidget {
  const _LegacyProfileCard({
    required this.member,
    required this.step,
    required this.total,
    required this.status,
    required this.error,
    required this.onImport,
  });

  final profile.FamilyMember member;
  final int step;
  final int total;
  final _LegacyImportStatus? status;
  final String? error;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ancien membre $step sur $total'),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoThumbnail(
                  personName: member.name,
                  photos: member.photos,
                  index: 0,
                  width: 76,
                  height: 92,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('Lien local : ${member.relation}'),
                      Text('Profession : ${member.profession}'),
                      Text(
                        'La profession et les photos restent dans les données locales.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
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
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 17,
                        ),
                        label: Text('${member.photos.length} anciennes photos'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text('Échec — $error', style: TextStyle(color: scheme.error)),
            ],
            if (status != null && status != _LegacyImportStatus.failed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Résultat : ${_legacyStatusLabel(status)}'),
              ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: onImport,
              icon: Icon(
                status == _LegacyImportStatus.failed
                    ? Icons.refresh_rounded
                    : Icons.cloud_upload_outlined,
              ),
              label: Text(
                status == _LegacyImportStatus.failed
                    ? 'Réessayer cet import'
                    : 'Importer ce membre',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  const _FamilyMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 76,
                height: 92,
                child: member.imageUrl == null
                    ? ColoredBox(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: scheme.onSurfaceVariant,
                          size: 36,
                        ),
                      )
                    : Image.network(
                        member.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.parente.toUpperCase(),
                    style: TextStyle(
                      color: scheme.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('Né(e) le ${member.dateNaissance}'),
                  Text('Lieu : ${member.lieuNaissance}'),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text('Modifier'),
                      ),
                      TextButton.icon(
                        onPressed: onDelete,
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.error,
                        ),
                        icon: const Icon(Icons.delete_outline, size: 17),
                        label: const Text('Supprimer'),
                      ),
                    ],
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

class _FamilyMemberFormDialog extends StatefulWidget {
  const _FamilyMemberFormDialog({this.member});

  final FamilyMember? member;

  @override
  State<_FamilyMemberFormDialog> createState() =>
      _FamilyMemberFormDialogState();
}

class _FamilyMemberFormDialogState extends State<_FamilyMemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nomController = TextEditingController(
    text: widget.member?.nom ?? '',
  );
  late final _postnomController = TextEditingController(
    text: widget.member?.postnom ?? '',
  );
  late final _prenomController = TextEditingController(
    text: widget.member?.prenom ?? '',
  );
  late final _lieuController = TextEditingController(
    text: widget.member?.lieuNaissance ?? '',
  );
  late final _dateController = TextEditingController(
    text: widget.member?.dateNaissance ?? '',
  );
  late final _parenteController = TextEditingController(
    text: widget.member?.parente ?? '',
  );

  @override
  void dispose() {
    _nomController.dispose();
    _postnomController.dispose();
    _prenomController.dispose();
    _lieuController.dispose();
    _dateController.dispose();
    _parenteController.dispose();
    super.dispose();
  }

  String? _required(String? value, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ce champ est obligatoire.';
    if (text.length > maxLength) return 'Maximum $maxLength caractères.';
    return null;
  }

  String? _validateDate(String? value) {
    final requiredError = _required(value, 10);
    if (requiredError != null) return requiredError;
    final date = DateTime.tryParse(value!.trim());
    if (date == null || date.toIso8601String().substring(0, 10) != value) {
      return 'Utilisez le format AAAA-MM-JJ.';
    }
    if (date.isAfter(DateTime.now())) {
      return 'La date ne peut pas être dans le futur.';
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _MemberFormResult(
        values: {
          'nom': _nomController.text.trim(),
          'postnom': _postnomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'lieu_naissance': _lieuController.text.trim(),
          'date_naissance': _dateController.text.trim(),
          'parente': _parenteController.text.trim(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.member == null ? 'Ajouter un membre' : 'Modifier'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_nomController, 'Nom', 50),
                _field(_postnomController, 'Postnom', 50),
                _field(_prenomController, 'Prénom', 50),
                _field(_lieuController, 'Lieu de naissance', 100),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    hintText: 'AAAA-MM-JJ',
                  ),
                  validator: _validateDate,
                ),
                _field(_parenteController, 'Lien de parenté', 50),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.member == null ? 'Ajouter' : 'Enregistrer'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, int maxLength) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label),
      validator: (value) => _required(value, maxLength),
    );
  }
}

class _MemberFormResult {
  const _MemberFormResult({required this.values});

  final Map<String, String> values;
}

enum _LegacyAction { import, skip, cancel }

enum _LegacyConfirmation { confirm, skip, cancel }

enum _LegacyImportStatus { imported, alreadyPresent, skipped, failed }

String _legacyStatusLabel(_LegacyImportStatus? status) => switch (status) {
  _LegacyImportStatus.imported => 'Importé',
  _LegacyImportStatus.alreadyPresent => 'Déjà présent dans l’API',
  _LegacyImportStatus.skipped => 'Passé',
  _LegacyImportStatus.failed => 'Échec — à reprendre',
  null => 'En attente',
};

IconData _legacyStatusIcon(_LegacyImportStatus? status) => switch (status) {
  _LegacyImportStatus.imported => Icons.cloud_done_outlined,
  _LegacyImportStatus.alreadyPresent => Icons.person_search_outlined,
  _LegacyImportStatus.skipped => Icons.skip_next_rounded,
  _LegacyImportStatus.failed => Icons.error_outline_rounded,
  null => Icons.hourglass_empty_rounded,
};

class _LegacyFormAction {
  const _LegacyFormAction({
    required this.kind,
    this.values = const {},
    this.uploadPhoto = false,
  });

  final _LegacyAction kind;
  final Map<String, String> values;
  final bool uploadPhoto;
}

class _LegacyMemberFormDialog extends StatefulWidget {
  const _LegacyMemberFormDialog({required this.source, this.draft});

  final profile.FamilyMember source;
  final _LegacyFormAction? draft;

  @override
  State<_LegacyMemberFormDialog> createState() =>
      _LegacyMemberFormDialogState();
}

class _LegacyMemberFormDialogState extends State<_LegacyMemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nomController = _controller('nom');
  late final _postnomController = _controller('postnom');
  late final _prenomController = _controller('prenom');
  late final _dateController = _controller('date_naissance');
  late final _lieuController = _controller('lieu_naissance');
  late final _parenteController = _controller('parente');
  late bool _uploadPhoto =
      widget.source.photos.isNotEmpty && (widget.draft?.uploadPhoto ?? true);

  TextEditingController _controller(String key) =>
      TextEditingController(text: widget.draft?.values[key] ?? '');

  @override
  void dispose() {
    _nomController.dispose();
    _postnomController.dispose();
    _prenomController.dispose();
    _dateController.dispose();
    _lieuController.dispose();
    _parenteController.dispose();
    super.dispose();
  }

  String? _required(String? value, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ce champ est obligatoire.';
    if (text.length > maxLength) return 'Maximum $maxLength caractères.';
    return null;
  }

  String? _validateDate(String? value) {
    final requiredError = _required(value, 10);
    if (requiredError != null) return requiredError;
    final text = value!.trim();
    final date = DateTime.tryParse(text);
    if (date == null || date.toIso8601String().substring(0, 10) != text) {
      return 'Utilisez le format AAAA-MM-JJ.';
    }
    if (date.isAfter(DateTime.now())) {
      return 'La date ne peut pas être dans le futur.';
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _LegacyFormAction(
        kind: _LegacyAction.import,
        values: {
          'nom': _nomController.text.trim(),
          'postnom': _postnomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'date_naissance': _dateController.text.trim(),
          'lieu_naissance': _lieuController.text.trim(),
          'parente': _parenteController.text.trim(),
        },
        uploadPhoto: _uploadPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.source;
    return AlertDialog(
      title: const Text('Ancien membre de la famille'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Étape : ${source.name}'),
                Text('Lien enregistré : ${source.relation}'),
                Text('Profession enregistrée : ${source.profession}'),
                const SizedBox(height: 10),
                if (source.photos.isNotEmpty)
                  Center(
                    child: PhotoThumbnail(
                      personName: source.name,
                      photos: source.photos,
                      index: 0,
                      width: 150,
                      height: 170,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  )
                else
                  const Text('Aucune photo principale disponible.'),
                if (source.photos.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => showPhotoGallery(
                        context,
                        personName: source.name,
                        photos: source.photos,
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text('Voir les ${source.photos.length} photos'),
                    ),
                  ),
                const SizedBox(height: 8),
                _field(_nomController, 'Nom', 50),
                _field(_postnomController, 'Postnom', 50),
                _field(_prenomController, 'Prénom', 50),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    hintText: 'AAAA-MM-JJ',
                  ),
                  validator: _validateDate,
                ),
                _field(_lieuController, 'Lieu de naissance', 100),
                _field(_parenteController, 'Lien de parenté', 50),
                if (source.photos.isNotEmpty)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _uploadPhoto,
                    onChanged: (value) {
                      setState(() => _uploadPhoto = value ?? false);
                    },
                    title: const Text('Envoyer la photo principale'),
                    subtitle: const Text(
                      'JPEG, PNG, GIF ou WebP · 2 Mio maximum',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            const _LegacyFormAction(kind: _LegacyAction.cancel),
          ),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            const _LegacyFormAction(kind: _LegacyAction.skip),
          ),
          child: const Text('Passer'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Importer')),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, int maxLength) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label),
      validator: (value) => _required(value, maxLength),
    );
  }
}
