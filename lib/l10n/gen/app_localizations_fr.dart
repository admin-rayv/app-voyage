// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'App Voyage';

  @override
  String get tagline => 'Un ami historien dans tes écouteurs 🎧';

  @override
  String get exploreCity => 'Explore une ville';

  @override
  String get settingsTooltip => 'Paramètres';

  @override
  String poiCountBadge(int count) {
    return '$count POIs';
  }

  @override
  String get citiesLoading => 'Chargement des villes...';

  @override
  String get noCities => 'Aucune ville disponible';

  @override
  String get comeBackSoon => 'Reviens bientôt !';

  @override
  String get citiesError => 'Impossible de charger les villes';

  @override
  String get checkConnection => 'Vérifie ta connexion internet';

  @override
  String get retry => 'Réessayer';

  @override
  String get onb1Title => 'Explore librement';

  @override
  String get onb1Body =>
      'Pas de parcours imposé. Tous les points d\'intérêt de la ville sont sur la carte — promène-toi où tu veux, à ton rythme.';

  @override
  String get onb2Title => 'Active le mode découverte';

  @override
  String get onb2Body =>
      'Quand tu t\'approches d\'un lieu, l\'audio se déclenche tout seul. Autorise la localisation « Toujours » pour que ça fonctionne même téléphone en poche, écran verrouillé.';

  @override
  String get onbLangTitle => 'La langue de Marco';

  @override
  String get onbLangBody =>
      'Choisis la langue des guides audio. Tu pourras la changer dans les paramètres.';

  @override
  String get onb3Title => 'Marco te raconte';

  @override
  String get onb3Body =>
      'Ton ami guide te partage l\'histoire, les anecdotes et les bons plans de chaque endroit. Mets tes écouteurs et laisse-toi surprendre !';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get letsGo => 'C\'est parti !';

  @override
  String get downloadAudiosTooltip => 'Télécharger les audios';

  @override
  String get viewMapTooltip => 'Voir la carte';

  @override
  String get viewListTooltip => 'Voir la liste';

  @override
  String get myPositionTooltip => 'Ma position';

  @override
  String get groupListenTooltip => 'Écouter ensemble';

  @override
  String get downloadDialogTitle => 'Télécharger les audios ?';

  @override
  String downloadDialogBody(String city, String language) {
    return 'Génère et met en cache les audios de qualité (voix Marco) pour tous les POIs de $city en $language. À faire en Wi-Fi — ensuite tout fonctionne sans réseau.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get download => 'Télécharger';

  @override
  String get downloadProgressTitle => 'Téléchargement des audios';

  @override
  String downloadProgressCount(int current, int total) {
    return '$current / $total scripts';
  }

  @override
  String get stopAction => 'Arrêter';

  @override
  String downloadDone(int count) {
    return 'Audios téléchargés ($count scripts). Prêt pour la balade !';
  }

  @override
  String downloadInterrupted(int current, int total) {
    return 'Téléchargement interrompu ($current/$total).';
  }

  @override
  String allFilter(int count) {
    return 'Tous ($count)';
  }

  @override
  String unvisitedOnlyFilter(int count) {
    return 'Non écoutés seulement ($count)';
  }

  @override
  String progressListened(int visited, int total) {
    return '$visited/$total POIs écoutés';
  }

  @override
  String get legendToDiscover => 'À découvrir';

  @override
  String get legendListened => 'Écouté';

  @override
  String get legendPlaying => 'En lecture';

  @override
  String get noPoisWithFilters => 'Aucun POI trouvé avec ces filtres';

  @override
  String errorWith(String error) {
    return 'Erreur : $error';
  }

  @override
  String get discoveryActiveTitle => 'Mode découverte actif';

  @override
  String get discoveryActivating => 'Activation du mode découverte...';

  @override
  String watchingPois(int count) {
    return 'Surveillance de $count POIs';
  }

  @override
  String get checkingPermissions => 'Vérification des permissions et du GPS';

  @override
  String lastDetected(String name) {
    return 'Dernier POI détecté : $name';
  }

  @override
  String nowPlayingPoi(String name) {
    return 'Lecture en cours : $name';
  }

  @override
  String triggeredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count déclenchés',
      one: '1 déclenché',
      zero: '0 déclenché',
    );
    return '$_temp0';
  }

  @override
  String get fabActivating => 'Activation...';

  @override
  String get fabDiscoveryOn => 'Découverte active';

  @override
  String get fabEnableDiscovery => 'Activer la découverte';

  @override
  String get discoveryEnabled => 'Mode découverte activé.';

  @override
  String get discoveryDisabled => 'Mode découverte désactivé.';

  @override
  String get discoveryStartFailed =>
      'Impossible de démarrer le mode découverte.';

  @override
  String get noPointsAvailable =>
      'Aucun point disponible pour activer la découverte.';

  @override
  String msgAutoplayIn(String name, int seconds) {
    return 'POI détecté : $name. Lecture automatique dans ${seconds}s.';
  }

  @override
  String msgAutoplayNow(String name) {
    return 'POI détecté : $name. Lecture automatique.';
  }

  @override
  String msgAutoplayDisabled(String name) {
    return 'POI détecté : $name. Lecture automatique désactivée.';
  }

  @override
  String msgPausedSkip(String name) {
    return 'POI détecté : $name. Lecture ignorée car l\'audio est en pause.';
  }

  @override
  String msgManualSkip(String name) {
    return 'POI détecté : $name. Lecture manuelle en cours, auto-play ignoré.';
  }

  @override
  String msgAlreadyPlaying(String name) {
    return 'POI détecté : $name déjà en lecture.';
  }

  @override
  String msgNoScript(String name) {
    return 'POI détecté : $name. Aucun script disponible.';
  }

  @override
  String msgDetectedOnly(String name) {
    return 'POI détecté : $name.';
  }

  @override
  String get listen => 'Écouter';

  @override
  String get detail => 'Détail';

  @override
  String get noScriptForPoi => 'Aucun script disponible pour ce POI.';

  @override
  String get audioScript => 'Script audio';

  @override
  String wordsDuration(int words, int seconds) {
    return '~$words mots · $seconds s';
  }

  @override
  String get noScript => 'Aucun script disponible';

  @override
  String get playingNow => 'En cours de lecture...';

  @override
  String get pausedLabel => 'Lecture en pause';

  @override
  String get stopLabel => 'Stop';

  @override
  String get directions => 'Itinéraire';

  @override
  String get practicalInfo => 'Infos pratiques';

  @override
  String get toilets => 'Toilettes';

  @override
  String get parkingLabel => 'Stationnement';

  @override
  String get photoSpot => 'Photo';

  @override
  String get goodToKnow => 'Bon à savoir';

  @override
  String get accessibilityLabel => 'Accessibilité';

  @override
  String get hoursLabel => 'Horaires';

  @override
  String get audioPlayback => 'Lecture audio';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Reprendre';

  @override
  String get playTooltip => 'Lire';

  @override
  String get stopTooltip => 'Arrêter';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get debugLogsTooltip => 'Logs de debug';

  @override
  String get readingLanguage => 'Langue de lecture';

  @override
  String get readingLanguageDesc =>
      'Langue utilisée par défaut pour les scripts audio et le mode découverte.';

  @override
  String get discoveryModeSection => 'Mode découverte';

  @override
  String get discoveryModeDesc =>
      'Configure la lecture automatique quand un POI est détecté à proximité.';

  @override
  String get autoplayTitle => 'Lecture automatique des POIs';

  @override
  String get autoplayDesc =>
      'Démarre automatiquement un script quand le mode découverte déclenche un POI.';

  @override
  String get delayBeforePlay => 'Délai avant lecture';

  @override
  String delaySeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get vibrationTitle => 'Vibration avant lecture';

  @override
  String get vibrationDesc =>
      'Ajoute un retour haptique avant le lancement automatique du script.';

  @override
  String get replayVisitedTitle => 'Rejouer les POIs déjà écoutés';

  @override
  String get replayVisitedDesc =>
      'Si activé, le mode découverte redéclenche aussi les POIs déjà marqués comme écoutés (utile pour les tests terrain).';

  @override
  String get progressSection => 'Progression des POIs';

  @override
  String get progressSectionDesc =>
      'Réinitialise les POIs marqués comme déjà écoutés sur cet appareil.';

  @override
  String visitedSaved(int count) {
    return '$count POIs écoutés enregistrés';
  }

  @override
  String get resetHint =>
      'Le reset efface la progression locale de toutes les villes.';

  @override
  String get reset => 'Reset';

  @override
  String get resetConfirmTitle => 'Réinitialiser la progression ?';

  @override
  String get resetConfirmBody =>
      'Tous les POIs marqués comme écoutés seront supprimés de cet appareil.';

  @override
  String get resetDone => 'Progression des POIs réinitialisée.';

  @override
  String get speedSection => 'Vitesse de lecture';

  @override
  String get speedSectionDesc =>
      'La vitesse s\'applique à toutes les lectures.';

  @override
  String get voiceSection => 'Voix de Marco';

  @override
  String get voiceSectionDesc =>
      'Choisis la voix pour chaque langue. Appuie sur ▶️ pour tester.';

  @override
  String localVoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count locales',
      one: '1 locale',
    );
    return '$_temp0';
  }

  @override
  String voiceN(int n) {
    return 'Voix $n';
  }

  @override
  String get voiceLocalLabel => '📱 Locale (offline)';

  @override
  String voiceNetworkN(int n) {
    return 'Voix réseau $n';
  }

  @override
  String get voiceNetworkDesc => '☁️ Meilleure qualité, besoin de wifi/data';

  @override
  String networkVoicesHeader(int count) {
    return '☁️ Voix réseau ($count) — nécessite internet';
  }

  @override
  String get noVoicesInstalled =>
      'Aucune voix installée pour cette langue.\nVa dans Paramètres → TTS pour en télécharger.';

  @override
  String get copyAction => 'Copier';

  @override
  String get logsCopied => 'Logs copiés dans le presse-papier.';

  @override
  String get clearAction => 'Effacer';

  @override
  String get noLogs => 'Aucun log';

  @override
  String get aboutSection => 'À propos';

  @override
  String aboutVersion(String version) {
    return 'App Voyage $version';
  }

  @override
  String get aboutDesc =>
      'Guide audio géolocalisé — un ami historien dans tes écouteurs. Cartes : © OpenStreetMap contributors, © CARTO.';

  @override
  String get permServiceDisabled =>
      'La localisation est désactivée. Active-la pour utiliser le mode découverte.';

  @override
  String get permDenied =>
      'Autorisation GPS refusée. Mode découverte non activé.';

  @override
  String get permDeniedForever =>
      'Autorisation GPS bloquée. Ouvre les réglages pour activer le mode découverte.';

  @override
  String get permForegroundOnly =>
      'Mode découverte actif au premier plan. Autorise « Toujours » pour écran verrouillé et arrière-plan.';

  @override
  String get permDialogServiceTitle => 'Activer la localisation';

  @override
  String get permDialogServiceBody =>
      'Le mode découverte a besoin de la localisation du téléphone pour surveiller automatiquement les points autour de toi, y compris quand l\'écran est verrouillé.';

  @override
  String get permDialogRequestTitle => 'Autoriser la localisation';

  @override
  String get permDialogRequestBody =>
      'Le mode découverte utilise ta position pour détecter les POIs proches et lancer les guides audio au bon moment.';

  @override
  String get permDialogBackgroundTitle => 'Accès en arrière-plan recommandé';

  @override
  String get permDialogBackgroundBody =>
      'Le mode découverte fonctionne déjà au premier plan. Pour continuer quand l\'app passe en arrière-plan ou écran verrouillé, autorise « Toujours » si ton téléphone le propose.';

  @override
  String get permDialogBlockedTitle => 'Autorisation requise';

  @override
  String get permDialogBlockedBody =>
      'La localisation est bloquée de façon permanente. Ouvre les réglages de l\'app pour autoriser le mode découverte.';

  @override
  String get permDialogBackgroundBlockedTitle =>
      'Autorisation en arrière-plan bloquée';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get settingsButton => 'Réglages';

  @override
  String get continueButton => 'Continuer';

  @override
  String get requestButton => 'Demander';

  @override
  String get notifNearbyTitle => 'Tu es à proximité !';

  @override
  String notifBodyNow(String name) {
    return '$name est prêt. L\'audio démarre maintenant.';
  }

  @override
  String notifBodyIn(String name, int seconds) {
    return '$name est à proximité. L\'audio démarre dans $seconds secondes.';
  }

  @override
  String get groupTitle => 'Écouter ensemble';

  @override
  String get groupSubtitle =>
      'Synchronise l\'écoute avec ton groupe — le Host contrôle la lecture pour tout le monde.';

  @override
  String get createSession => 'Créer une session';

  @override
  String get joinSession => 'Rejoindre';

  @override
  String get sessionCodeLabel => 'Code de session';

  @override
  String get sessionCodeHint => 'Ex : MARC42';

  @override
  String get youAreHost => 'Tu es le Host — ta lecture est diffusée au groupe.';

  @override
  String get memberFollowNote => 'La lecture suit automatiquement le Host.';

  @override
  String get shareCode => 'Partage ce code (ou le QR) avec ton groupe';

  @override
  String participantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String get leaveSession => 'Quitter la session';

  @override
  String get endSession => 'Terminer la session';

  @override
  String joinedSession(String code) {
    return 'Connecté à la session $code.';
  }

  @override
  String get sessionEnded => 'Session terminée.';

  @override
  String get hostBadge => 'Host';

  @override
  String get youBadge => 'Toi';

  @override
  String get invalidCode => 'Code invalide — 6 caractères attendus.';

  @override
  String get groupConnectionError => 'Erreur de connexion. Réessaie.';

  @override
  String groupActiveBadge(String code) {
    return 'Session $code';
  }

  @override
  String get groupListenScreenTitle => 'Visite en cours';

  @override
  String get groupWaitingForHost =>
      'La visite va commencer dès que l\'hôte lancera un point d\'intérêt.';

  @override
  String get groupHostControlsNote =>
      'C\'est l\'hôte qui contrôle la lecture pour tout le groupe.';

  @override
  String get groupGuestAccessNote =>
      'Pas besoin d\'avoir la ville — tu écoutes ce que l\'hôte partage, en direct.';

  @override
  String get groupOpenLiveTour => 'Ouvrir la visite en cours';

  @override
  String get vsdTitle => 'Voix de Marco';

  @override
  String get vsdIntro =>
      'Pour que Marco te guide avec une belle voix, installe les voix de qualité sur ton téléphone.';

  @override
  String get vsdStepsTitle => '📋 Étapes rapides :';

  @override
  String get vsdSteps =>
      '1. Clique « Installer les voix »\n2. Sélectionne le moteur Google\n3. Appuie sur ⚙️ → « Installer les données vocales »\n4. Télécharge :\n   🇨🇦 Français (Canada)\n   🇺🇸 English (US)\n   🇪🇸 Español\n5. Reviens dans l\'app';

  @override
  String get vsdFree => '⏱️ Ça prend 30 secondes et c\'est gratuit !';

  @override
  String get vsdLater => 'Plus tard';

  @override
  String get vsdInstall => 'Installer les voix';
}
