import 'family_member.dart';

enum FamilyNameMatchKind { none, exact, uncertain }

class FamilyNameMatchResult {
  const FamilyNameMatchResult(this.kind, this.members);

  final FamilyNameMatchKind kind;
  final List<FamilyMember> members;
}

FamilyNameMatchResult matchFamilyNames(
  Iterable<String> candidateNames,
  Iterable<FamilyMember> members,
) {
  final candidates = candidateNames
      .map(_nameTokens)
      .where((tokens) => tokens.isNotEmpty)
      .toList();
  final exactMatches = <FamilyMember>[];
  final uncertainMatches = <FamilyMember>[];

  for (final member in members) {
    final apiNames = [
      _nameTokens(member.fullName),
      _nameTokens('${member.nom} ${member.postnom} ${member.prenom}'),
    ].where((tokens) => tokens.isNotEmpty);

    var uncertain = false;
    for (final candidate in candidates) {
      for (final apiName in apiNames) {
        if (_sameTokens(candidate, apiName)) {
          exactMatches.add(member);
          uncertain = false;
          break;
        }
        final commonTokens = candidate.toSet().intersection(apiName.toSet());
        final minimumLength = candidate.length < apiName.length
            ? candidate.length
            : apiName.length;
        if (commonTokens.length >= (minimumLength == 1 ? 1 : 2)) {
          uncertain = true;
        }
      }
      if (exactMatches.contains(member)) break;
    }
    if (!exactMatches.contains(member) && uncertain) {
      uncertainMatches.add(member);
    }
  }

  if (exactMatches.isNotEmpty) {
    return FamilyNameMatchResult(
      FamilyNameMatchKind.exact,
      List.unmodifiable(exactMatches),
    );
  }
  if (uncertainMatches.isNotEmpty) {
    return FamilyNameMatchResult(
      FamilyNameMatchKind.uncertain,
      List.unmodifiable(uncertainMatches),
    );
  }
  return const FamilyNameMatchResult(FamilyNameMatchKind.none, []);
}

bool _sameTokens(List<String> first, List<String> second) {
  if (first.length != second.length) return false;
  final sortedFirst = [...first]..sort();
  final sortedSecond = [...second]..sort();
  for (var index = 0; index < sortedFirst.length; index++) {
    if (sortedFirst[index] != sortedSecond[index]) return false;
  }
  return true;
}

List<String> _nameTokens(String value) {
  const replacements = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'ā': 'a',
    'ă': 'a',
    'ą': 'a',
    'æ': 'ae',
    'ç': 'c',
    'ć': 'c',
    'ĉ': 'c',
    'ċ': 'c',
    'č': 'c',
    'ď': 'd',
    'đ': 'd',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ē': 'e',
    'ĕ': 'e',
    'ė': 'e',
    'ę': 'e',
    'ě': 'e',
    'ĝ': 'g',
    'ğ': 'g',
    'ġ': 'g',
    'ģ': 'g',
    'ĥ': 'h',
    'ħ': 'h',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ĩ': 'i',
    'ī': 'i',
    'ĭ': 'i',
    'į': 'i',
    'ı': 'i',
    'ĵ': 'j',
    'ķ': 'k',
    'ĺ': 'l',
    'ļ': 'l',
    'ľ': 'l',
    'ŀ': 'l',
    'ł': 'l',
    'ñ': 'n',
    'ń': 'n',
    'ņ': 'n',
    'ň': 'n',
    'ŋ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ø': 'o',
    'ō': 'o',
    'ŏ': 'o',
    'ő': 'o',
    'œ': 'oe',
    'ŕ': 'r',
    'ŗ': 'r',
    'ř': 'r',
    'ś': 's',
    'ŝ': 's',
    'ş': 's',
    'š': 's',
    'ţ': 't',
    'ť': 't',
    'ŧ': 't',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ũ': 'u',
    'ū': 'u',
    'ŭ': 'u',
    'ů': 'u',
    'ű': 'u',
    'ų': 'u',
    'ŵ': 'w',
    'ý': 'y',
    'ÿ': 'y',
    'ŷ': 'y',
    'ź': 'z',
    'ż': 'z',
    'ž': 'z',
  };
  final normalized = String.fromCharCodes(
    value
        .toLowerCase()
        .runes
        .map(
          (rune) =>
              (replacements[String.fromCharCode(rune)] ??
                      String.fromCharCode(rune))
                  .runes,
        )
        .expand((runes) => runes),
  );
  return normalized
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList();
}
