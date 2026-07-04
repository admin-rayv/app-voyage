import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'App Voyage'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In fr, this message translates to:
  /// **'Un ami historien dans tes écouteurs 🎧'**
  String get tagline;

  /// No description provided for @exploreCity.
  ///
  /// In fr, this message translates to:
  /// **'Explore une ville'**
  String get exploreCity;

  /// No description provided for @settingsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTooltip;

  /// No description provided for @poiCountBadge.
  ///
  /// In fr, this message translates to:
  /// **'{count} POIs'**
  String poiCountBadge(int count);

  /// No description provided for @citiesLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des villes...'**
  String get citiesLoading;

  /// No description provided for @noCities.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ville disponible'**
  String get noCities;

  /// No description provided for @comeBackSoon.
  ///
  /// In fr, this message translates to:
  /// **'Reviens bientôt !'**
  String get comeBackSoon;

  /// No description provided for @citiesError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les villes'**
  String get citiesError;

  /// No description provided for @checkConnection.
  ///
  /// In fr, this message translates to:
  /// **'Vérifie ta connexion internet'**
  String get checkConnection;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @onb1Title.
  ///
  /// In fr, this message translates to:
  /// **'Explore librement'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In fr, this message translates to:
  /// **'Pas de parcours imposé. Tous les points d\'intérêt de la ville sont sur la carte — promène-toi où tu veux, à ton rythme.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In fr, this message translates to:
  /// **'Active le mode découverte'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In fr, this message translates to:
  /// **'Quand tu t\'approches d\'un lieu, l\'audio se déclenche tout seul. Autorise la localisation « Toujours » pour que ça fonctionne même téléphone en poche, écran verrouillé.'**
  String get onb2Body;

  /// No description provided for @onbLangTitle.
  ///
  /// In fr, this message translates to:
  /// **'La langue de Marco'**
  String get onbLangTitle;

  /// No description provided for @onbLangBody.
  ///
  /// In fr, this message translates to:
  /// **'Choisis la langue des guides audio. Tu pourras la changer dans les paramètres.'**
  String get onbLangBody;

  /// No description provided for @onb3Title.
  ///
  /// In fr, this message translates to:
  /// **'Marco te raconte'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In fr, this message translates to:
  /// **'Ton ami guide te partage l\'histoire, les anecdotes et les bons plans de chaque endroit. Mets tes écouteurs et laisse-toi surprendre !'**
  String get onb3Body;

  /// No description provided for @skip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @letsGo.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get letsGo;

  /// No description provided for @downloadAudiosTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les audios'**
  String get downloadAudiosTooltip;

  /// No description provided for @viewMapTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Voir la carte'**
  String get viewMapTooltip;

  /// No description provided for @viewListTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Voir la liste'**
  String get viewListTooltip;

  /// No description provided for @myPositionTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get myPositionTooltip;

  /// No description provided for @groupListenTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Écouter ensemble'**
  String get groupListenTooltip;

  /// No description provided for @downloadDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les audios ?'**
  String get downloadDialogTitle;

  /// No description provided for @downloadDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'Génère et met en cache les audios de qualité (voix Marco) pour tous les POIs de {city} en {language}. À faire en Wi-Fi — ensuite tout fonctionne sans réseau.'**
  String downloadDialogBody(String city, String language);

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @download.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get download;

  /// No description provided for @downloadProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement des audios'**
  String get downloadProgressTitle;

  /// No description provided for @downloadProgressCount.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {total} scripts'**
  String downloadProgressCount(int current, int total);

  /// No description provided for @stopAction.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get stopAction;

  /// No description provided for @downloadDone.
  ///
  /// In fr, this message translates to:
  /// **'Audios téléchargés ({count} scripts). Prêt pour la balade !'**
  String downloadDone(int count);

  /// No description provided for @downloadInterrupted.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement interrompu ({current}/{total}).'**
  String downloadInterrupted(int current, int total);

  /// No description provided for @allFilter.
  ///
  /// In fr, this message translates to:
  /// **'Tous ({count})'**
  String allFilter(int count);

  /// No description provided for @unvisitedOnlyFilter.
  ///
  /// In fr, this message translates to:
  /// **'Non écoutés seulement ({count})'**
  String unvisitedOnlyFilter(int count);

  /// No description provided for @progressListened.
  ///
  /// In fr, this message translates to:
  /// **'{visited}/{total} POIs écoutés'**
  String progressListened(int visited, int total);

  /// No description provided for @legendToDiscover.
  ///
  /// In fr, this message translates to:
  /// **'À découvrir'**
  String get legendToDiscover;

  /// No description provided for @legendListened.
  ///
  /// In fr, this message translates to:
  /// **'Écouté'**
  String get legendListened;

  /// No description provided for @legendPlaying.
  ///
  /// In fr, this message translates to:
  /// **'En lecture'**
  String get legendPlaying;

  /// No description provided for @noPoisWithFilters.
  ///
  /// In fr, this message translates to:
  /// **'Aucun POI trouvé avec ces filtres'**
  String get noPoisWithFilters;

  /// No description provided for @errorWith.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String errorWith(String error);

  /// No description provided for @discoveryActiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode découverte actif'**
  String get discoveryActiveTitle;

  /// No description provided for @discoveryActivating.
  ///
  /// In fr, this message translates to:
  /// **'Activation du mode découverte...'**
  String get discoveryActivating;

  /// No description provided for @watchingPois.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance de {count} POIs'**
  String watchingPois(int count);

  /// No description provided for @checkingPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Vérification des permissions et du GPS'**
  String get checkingPermissions;

  /// No description provided for @lastDetected.
  ///
  /// In fr, this message translates to:
  /// **'Dernier POI détecté : {name}'**
  String lastDetected(String name);

  /// No description provided for @nowPlayingPoi.
  ///
  /// In fr, this message translates to:
  /// **'Lecture en cours : {name}'**
  String nowPlayingPoi(String name);

  /// No description provided for @triggeredCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 déclenché} =1{1 déclenché} other{{count} déclenchés}}'**
  String triggeredCount(int count);

  /// No description provided for @fabActivating.
  ///
  /// In fr, this message translates to:
  /// **'Activation...'**
  String get fabActivating;

  /// No description provided for @fabDiscoveryOn.
  ///
  /// In fr, this message translates to:
  /// **'Découverte active'**
  String get fabDiscoveryOn;

  /// No description provided for @fabEnableDiscovery.
  ///
  /// In fr, this message translates to:
  /// **'Activer la découverte'**
  String get fabEnableDiscovery;

  /// No description provided for @discoveryEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Mode découverte activé.'**
  String get discoveryEnabled;

  /// No description provided for @discoveryDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Mode découverte désactivé.'**
  String get discoveryDisabled;

  /// No description provided for @discoveryStartFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de démarrer le mode découverte.'**
  String get discoveryStartFailed;

  /// No description provided for @noPointsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun point disponible pour activer la découverte.'**
  String get noPointsAvailable;

  /// No description provided for @msgAutoplayIn.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name}. Lecture automatique dans {seconds}s.'**
  String msgAutoplayIn(String name, int seconds);

  /// No description provided for @msgAutoplayNow.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name}. Lecture automatique.'**
  String msgAutoplayNow(String name);

  /// No description provided for @msgAutoplayDisabled.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name}. Lecture automatique désactivée.'**
  String msgAutoplayDisabled(String name);

  /// No description provided for @msgPausedSkip.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name}. Lecture ignorée car l\'audio est en pause.'**
  String msgPausedSkip(String name);

  /// No description provided for @msgManualSkip.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name}. Lecture manuelle en cours, auto-play ignoré.'**
  String msgManualSkip(String name);

  /// No description provided for @msgAlreadyPlaying.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name} déjà en lecture.'**
  String msgAlreadyPlaying(String name);

  /// No description provided for @msgNoScript.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name}. Aucun script disponible.'**
  String msgNoScript(String name);

  /// No description provided for @msgDetectedOnly.
  ///
  /// In fr, this message translates to:
  /// **'POI détecté : {name}.'**
  String msgDetectedOnly(String name);

  /// No description provided for @listen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get listen;

  /// No description provided for @detail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get detail;

  /// No description provided for @noScriptForPoi.
  ///
  /// In fr, this message translates to:
  /// **'Aucun script disponible pour ce POI.'**
  String get noScriptForPoi;

  /// No description provided for @audioScript.
  ///
  /// In fr, this message translates to:
  /// **'Script audio'**
  String get audioScript;

  /// No description provided for @wordsDuration.
  ///
  /// In fr, this message translates to:
  /// **'~{words} mots · {seconds} s'**
  String wordsDuration(int words, int seconds);

  /// No description provided for @noScript.
  ///
  /// In fr, this message translates to:
  /// **'Aucun script disponible'**
  String get noScript;

  /// No description provided for @playingNow.
  ///
  /// In fr, this message translates to:
  /// **'En cours de lecture...'**
  String get playingNow;

  /// No description provided for @pausedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lecture en pause'**
  String get pausedLabel;

  /// No description provided for @stopLabel.
  ///
  /// In fr, this message translates to:
  /// **'Stop'**
  String get stopLabel;

  /// No description provided for @directions.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get directions;

  /// No description provided for @practicalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos pratiques'**
  String get practicalInfo;

  /// No description provided for @toilets.
  ///
  /// In fr, this message translates to:
  /// **'Toilettes'**
  String get toilets;

  /// No description provided for @parkingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Stationnement'**
  String get parkingLabel;

  /// No description provided for @photoSpot.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get photoSpot;

  /// No description provided for @goodToKnow.
  ///
  /// In fr, this message translates to:
  /// **'Bon à savoir'**
  String get goodToKnow;

  /// No description provided for @accessibilityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Accessibilité'**
  String get accessibilityLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In fr, this message translates to:
  /// **'Horaires'**
  String get hoursLabel;

  /// No description provided for @audioPlayback.
  ///
  /// In fr, this message translates to:
  /// **'Lecture audio'**
  String get audioPlayback;

  /// No description provided for @pauseTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @resumeTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get resumeTooltip;

  /// No description provided for @playTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get playTooltip;

  /// No description provided for @stopTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get stopTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @debugLogsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Logs de debug'**
  String get debugLogsTooltip;

  /// No description provided for @readingLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de lecture'**
  String get readingLanguage;

  /// No description provided for @readingLanguageDesc.
  ///
  /// In fr, this message translates to:
  /// **'Langue utilisée par défaut pour les scripts audio et le mode découverte.'**
  String get readingLanguageDesc;

  /// No description provided for @discoveryModeSection.
  ///
  /// In fr, this message translates to:
  /// **'Mode découverte'**
  String get discoveryModeSection;

  /// No description provided for @discoveryModeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Configure la lecture automatique quand un POI est détecté à proximité.'**
  String get discoveryModeDesc;

  /// No description provided for @autoplayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture automatique des POIs'**
  String get autoplayTitle;

  /// No description provided for @autoplayDesc.
  ///
  /// In fr, this message translates to:
  /// **'Démarre automatiquement un script quand le mode découverte déclenche un POI.'**
  String get autoplayDesc;

  /// No description provided for @delayBeforePlay.
  ///
  /// In fr, this message translates to:
  /// **'Délai avant lecture'**
  String get delayBeforePlay;

  /// No description provided for @delaySeconds.
  ///
  /// In fr, this message translates to:
  /// **'{seconds}s'**
  String delaySeconds(int seconds);

  /// No description provided for @vibrationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vibration avant lecture'**
  String get vibrationTitle;

  /// No description provided for @vibrationDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute un retour haptique avant le lancement automatique du script.'**
  String get vibrationDesc;

  /// No description provided for @replayVisitedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejouer les POIs déjà écoutés'**
  String get replayVisitedTitle;

  /// No description provided for @replayVisitedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Si activé, le mode découverte redéclenche aussi les POIs déjà marqués comme écoutés (utile pour les tests terrain).'**
  String get replayVisitedDesc;

  /// No description provided for @progressSection.
  ///
  /// In fr, this message translates to:
  /// **'Progression des POIs'**
  String get progressSection;

  /// No description provided for @progressSectionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialise les POIs marqués comme déjà écoutés sur cet appareil.'**
  String get progressSectionDesc;

  /// No description provided for @visitedSaved.
  ///
  /// In fr, this message translates to:
  /// **'{count} POIs écoutés enregistrés'**
  String visitedSaved(int count);

  /// No description provided for @resetHint.
  ///
  /// In fr, this message translates to:
  /// **'Le reset efface la progression locale de toutes les villes.'**
  String get resetHint;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser la progression ?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Tous les POIs marqués comme écoutés seront supprimés de cet appareil.'**
  String get resetConfirmBody;

  /// No description provided for @resetDone.
  ///
  /// In fr, this message translates to:
  /// **'Progression des POIs réinitialisée.'**
  String get resetDone;

  /// No description provided for @speedSection.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse de lecture'**
  String get speedSection;

  /// No description provided for @speedSectionDesc.
  ///
  /// In fr, this message translates to:
  /// **'La vitesse s\'applique à toutes les lectures.'**
  String get speedSectionDesc;

  /// No description provided for @voiceSection.
  ///
  /// In fr, this message translates to:
  /// **'Voix de Marco'**
  String get voiceSection;

  /// No description provided for @voiceSectionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Choisis la voix pour chaque langue. Appuie sur ▶️ pour tester.'**
  String get voiceSectionDesc;

  /// No description provided for @localVoicesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 locale} other{{count} locales}}'**
  String localVoicesCount(int count);

  /// No description provided for @voiceN.
  ///
  /// In fr, this message translates to:
  /// **'Voix {n}'**
  String voiceN(int n);

  /// No description provided for @voiceLocalLabel.
  ///
  /// In fr, this message translates to:
  /// **'📱 Locale (offline)'**
  String get voiceLocalLabel;

  /// No description provided for @voiceNetworkN.
  ///
  /// In fr, this message translates to:
  /// **'Voix réseau {n}'**
  String voiceNetworkN(int n);

  /// No description provided for @voiceNetworkDesc.
  ///
  /// In fr, this message translates to:
  /// **'☁️ Meilleure qualité, besoin de wifi/data'**
  String get voiceNetworkDesc;

  /// No description provided for @networkVoicesHeader.
  ///
  /// In fr, this message translates to:
  /// **'☁️ Voix réseau ({count}) — nécessite internet'**
  String networkVoicesHeader(int count);

  /// No description provided for @noVoicesInstalled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune voix installée pour cette langue.\nVa dans Paramètres → TTS pour en télécharger.'**
  String get noVoicesInstalled;

  /// No description provided for @copyAction.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copyAction;

  /// No description provided for @logsCopied.
  ///
  /// In fr, this message translates to:
  /// **'Logs copiés dans le presse-papier.'**
  String get logsCopied;

  /// No description provided for @clearAction.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clearAction;

  /// No description provided for @noLogs.
  ///
  /// In fr, this message translates to:
  /// **'Aucun log'**
  String get noLogs;

  /// No description provided for @aboutSection.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutSection;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'App Voyage {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutDesc.
  ///
  /// In fr, this message translates to:
  /// **'Guide audio géolocalisé — un ami historien dans tes écouteurs. Cartes : © OpenStreetMap contributors, © CARTO.'**
  String get aboutDesc;

  /// No description provided for @permServiceDisabled.
  ///
  /// In fr, this message translates to:
  /// **'La localisation est désactivée. Active-la pour utiliser le mode découverte.'**
  String get permServiceDisabled;

  /// No description provided for @permDenied.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation GPS refusée. Mode découverte non activé.'**
  String get permDenied;

  /// No description provided for @permDeniedForever.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation GPS bloquée. Ouvre les réglages pour activer le mode découverte.'**
  String get permDeniedForever;

  /// No description provided for @permForegroundOnly.
  ///
  /// In fr, this message translates to:
  /// **'Mode découverte actif au premier plan. Autorise « Toujours » pour écran verrouillé et arrière-plan.'**
  String get permForegroundOnly;

  /// No description provided for @permDialogServiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer la localisation'**
  String get permDialogServiceTitle;

  /// No description provided for @permDialogServiceBody.
  ///
  /// In fr, this message translates to:
  /// **'Le mode découverte a besoin de la localisation du téléphone pour surveiller automatiquement les points autour de toi, y compris quand l\'écran est verrouillé.'**
  String get permDialogServiceBody;

  /// No description provided for @permDialogRequestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser la localisation'**
  String get permDialogRequestTitle;

  /// No description provided for @permDialogRequestBody.
  ///
  /// In fr, this message translates to:
  /// **'Le mode découverte utilise ta position pour détecter les POIs proches et lancer les guides audio au bon moment.'**
  String get permDialogRequestBody;

  /// No description provided for @permDialogBackgroundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès en arrière-plan recommandé'**
  String get permDialogBackgroundTitle;

  /// No description provided for @permDialogBackgroundBody.
  ///
  /// In fr, this message translates to:
  /// **'Le mode découverte fonctionne déjà au premier plan. Pour continuer quand l\'app passe en arrière-plan ou écran verrouillé, autorise « Toujours » si ton téléphone le propose.'**
  String get permDialogBackgroundBody;

  /// No description provided for @permDialogBlockedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation requise'**
  String get permDialogBlockedTitle;

  /// No description provided for @permDialogBlockedBody.
  ///
  /// In fr, this message translates to:
  /// **'La localisation est bloquée de façon permanente. Ouvre les réglages de l\'app pour autoriser le mode découverte.'**
  String get permDialogBlockedBody;

  /// No description provided for @permDialogBackgroundBlockedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation en arrière-plan bloquée'**
  String get permDialogBackgroundBlockedTitle;

  /// No description provided for @openSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get openSettings;

  /// No description provided for @settingsButton.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsButton;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @requestButton.
  ///
  /// In fr, this message translates to:
  /// **'Demander'**
  String get requestButton;

  /// No description provided for @notifNearbyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tu es à proximité !'**
  String get notifNearbyTitle;

  /// No description provided for @notifBodyNow.
  ///
  /// In fr, this message translates to:
  /// **'{name} est prêt. L\'audio démarre maintenant.'**
  String notifBodyNow(String name);

  /// No description provided for @notifBodyIn.
  ///
  /// In fr, this message translates to:
  /// **'{name} est à proximité. L\'audio démarre dans {seconds} secondes.'**
  String notifBodyIn(String name, int seconds);

  /// No description provided for @groupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Écouter ensemble'**
  String get groupTitle;

  /// No description provided for @groupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Synchronise l\'écoute avec ton groupe — le Host contrôle la lecture pour tout le monde.'**
  String get groupSubtitle;

  /// No description provided for @createSession.
  ///
  /// In fr, this message translates to:
  /// **'Créer une session'**
  String get createSession;

  /// No description provided for @joinSession.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get joinSession;

  /// No description provided for @sessionCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code de session'**
  String get sessionCodeLabel;

  /// No description provided for @sessionCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : MARC42'**
  String get sessionCodeHint;

  /// No description provided for @youAreHost.
  ///
  /// In fr, this message translates to:
  /// **'Tu es le Host — ta lecture est diffusée au groupe.'**
  String get youAreHost;

  /// No description provided for @memberFollowNote.
  ///
  /// In fr, this message translates to:
  /// **'La lecture suit automatiquement le Host.'**
  String get memberFollowNote;

  /// No description provided for @shareCode.
  ///
  /// In fr, this message translates to:
  /// **'Partage ce code (ou le QR) avec ton groupe'**
  String get shareCode;

  /// No description provided for @participantsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String participantsCount(int count);

  /// No description provided for @leaveSession.
  ///
  /// In fr, this message translates to:
  /// **'Quitter la session'**
  String get leaveSession;

  /// No description provided for @endSession.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la session'**
  String get endSession;

  /// No description provided for @joinedSession.
  ///
  /// In fr, this message translates to:
  /// **'Connecté à la session {code}.'**
  String joinedSession(String code);

  /// No description provided for @sessionEnded.
  ///
  /// In fr, this message translates to:
  /// **'Session terminée.'**
  String get sessionEnded;

  /// No description provided for @hostBadge.
  ///
  /// In fr, this message translates to:
  /// **'Host'**
  String get hostBadge;

  /// No description provided for @youBadge.
  ///
  /// In fr, this message translates to:
  /// **'Toi'**
  String get youBadge;

  /// No description provided for @invalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide — 6 caractères attendus.'**
  String get invalidCode;

  /// No description provided for @groupConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion. Réessaie.'**
  String get groupConnectionError;

  /// No description provided for @groupActiveBadge.
  ///
  /// In fr, this message translates to:
  /// **'Session {code}'**
  String groupActiveBadge(String code);

  /// No description provided for @groupListenScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Visite en cours'**
  String get groupListenScreenTitle;

  /// No description provided for @groupWaitingForHost.
  ///
  /// In fr, this message translates to:
  /// **'La visite va commencer dès que l\'hôte lancera un point d\'intérêt.'**
  String get groupWaitingForHost;

  /// No description provided for @groupHostControlsNote.
  ///
  /// In fr, this message translates to:
  /// **'C\'est l\'hôte qui contrôle la lecture pour tout le groupe.'**
  String get groupHostControlsNote;

  /// No description provided for @groupGuestAccessNote.
  ///
  /// In fr, this message translates to:
  /// **'Pas besoin d\'avoir la ville — tu écoutes ce que l\'hôte partage, en direct.'**
  String get groupGuestAccessNote;

  /// No description provided for @groupOpenLiveTour.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la visite en cours'**
  String get groupOpenLiveTour;

  /// No description provided for @vsdTitle.
  ///
  /// In fr, this message translates to:
  /// **'Voix de Marco'**
  String get vsdTitle;

  /// No description provided for @vsdIntro.
  ///
  /// In fr, this message translates to:
  /// **'Pour que Marco te guide avec une belle voix, installe les voix de qualité sur ton téléphone.'**
  String get vsdIntro;

  /// No description provided for @vsdStepsTitle.
  ///
  /// In fr, this message translates to:
  /// **'📋 Étapes rapides :'**
  String get vsdStepsTitle;

  /// No description provided for @vsdSteps.
  ///
  /// In fr, this message translates to:
  /// **'1. Clique « Installer les voix »\n2. Sélectionne le moteur Google\n3. Appuie sur ⚙️ → « Installer les données vocales »\n4. Télécharge :\n   🇨🇦 Français (Canada)\n   🇺🇸 English (US)\n   🇪🇸 Español\n5. Reviens dans l\'app'**
  String get vsdSteps;

  /// No description provided for @vsdFree.
  ///
  /// In fr, this message translates to:
  /// **'⏱️ Ça prend 30 secondes et c\'est gratuit !'**
  String get vsdFree;

  /// No description provided for @vsdLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get vsdLater;

  /// No description provided for @vsdInstall.
  ///
  /// In fr, this message translates to:
  /// **'Installer les voix'**
  String get vsdInstall;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
