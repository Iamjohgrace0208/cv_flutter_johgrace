import 'package:cv_flutter_johgrace/data/family_member.dart';
import 'package:cv_flutter_johgrace/data/family_name_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const member = FamilyMember(
    id: 1,
    nom: 'Selemani',
    postnom: 'Joseph',
    prenom: 'Grace',
    lieuNaissance: 'Goma',
    dateNaissance: '1990-01-01',
    parente: 'Frère',
  );

  test(
    'matches names independent of order, accents, case, and punctuation',
    () {
      final result = matchFamilyNames(['JÓSEPH, grâce-selemani!'], [member]);

      expect(result.kind, FamilyNameMatchKind.exact);
      expect(result.members, [member]);
    },
  );

  test('flags shared name parts as an uncertain match', () {
    final result = matchFamilyNames(['Joseph Grâce'], [member]);

    expect(result.kind, FamilyNameMatchKind.uncertain);
    expect(result.members, [member]);
  });

  test('returns no match for unrelated names', () {
    final result = matchFamilyNames(['Matakio Annonciate'], [member]);

    expect(result.kind, FamilyNameMatchKind.none);
    expect(result.members, isEmpty);
  });
}
