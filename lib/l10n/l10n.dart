import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Raccourci: `context.l10n.maCle` au lieu de `AppLocalizations.of(context)`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Code langue courant de l'UI ('fr', 'en', 'es') — pour les noms
  /// localisés (villes, POIs, catégories) stockés en JSONB.
  String get languageCode => Localizations.localeOf(this).languageCode;
}
