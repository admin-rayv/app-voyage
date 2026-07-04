// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'App Voyage';

  @override
  String get tagline => 'A historian friend in your ears 🎧';

  @override
  String get exploreCity => 'Explore a city';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String poiCountBadge(int count) {
    return '$count POIs';
  }

  @override
  String get citiesLoading => 'Loading cities...';

  @override
  String get noCities => 'No cities available';

  @override
  String get comeBackSoon => 'Come back soon!';

  @override
  String get citiesError => 'Could not load cities';

  @override
  String get checkConnection => 'Check your internet connection';

  @override
  String get retry => 'Retry';

  @override
  String get onb1Title => 'Explore freely';

  @override
  String get onb1Body =>
      'No fixed route. Every point of interest in the city is on the map — wander wherever you like, at your own pace.';

  @override
  String get onb2Title => 'Turn on discovery mode';

  @override
  String get onb2Body =>
      'When you get close to a place, the audio starts by itself. Allow location \"Always\" so it works even with your phone in your pocket, screen locked.';

  @override
  String get onbLangTitle => 'Marco\'s language';

  @override
  String get onbLangBody =>
      'Pick the language for the audio guides. You can change it later in the settings.';

  @override
  String get onb3Title => 'Marco tells the story';

  @override
  String get onb3Body =>
      'Your guide friend shares the history, anecdotes and local tips of every place. Put on your headphones and let yourself be surprised!';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get letsGo => 'Let\'s go!';

  @override
  String get downloadAudiosTooltip => 'Download audio';

  @override
  String get viewMapTooltip => 'Show map';

  @override
  String get viewListTooltip => 'Show list';

  @override
  String get myPositionTooltip => 'My position';

  @override
  String get groupListenTooltip => 'Listen together';

  @override
  String get downloadDialogTitle => 'Download audio?';

  @override
  String downloadDialogBody(String city, String language) {
    return 'Generates and caches the high-quality audio (Marco\'s voice) for every POI in $city in $language. Do this on Wi-Fi — everything then works offline.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get download => 'Download';

  @override
  String get downloadProgressTitle => 'Downloading audio';

  @override
  String downloadProgressCount(int current, int total) {
    return '$current / $total scripts';
  }

  @override
  String get stopAction => 'Stop';

  @override
  String downloadDone(int count) {
    return 'Audio downloaded ($count scripts). Ready for the walk!';
  }

  @override
  String downloadInterrupted(int current, int total) {
    return 'Download interrupted ($current/$total).';
  }

  @override
  String allFilter(int count) {
    return 'All ($count)';
  }

  @override
  String unvisitedOnlyFilter(int count) {
    return 'Unplayed only ($count)';
  }

  @override
  String progressListened(int visited, int total) {
    return '$visited/$total POIs listened';
  }

  @override
  String get legendToDiscover => 'To discover';

  @override
  String get legendListened => 'Listened';

  @override
  String get legendPlaying => 'Playing';

  @override
  String get noPoisWithFilters => 'No POIs found with these filters';

  @override
  String errorWith(String error) {
    return 'Error: $error';
  }

  @override
  String get discoveryActiveTitle => 'Discovery mode on';

  @override
  String get discoveryActivating => 'Turning on discovery mode...';

  @override
  String watchingPois(int count) {
    return 'Watching $count POIs';
  }

  @override
  String get checkingPermissions => 'Checking permissions and GPS';

  @override
  String lastDetected(String name) {
    return 'Last POI detected: $name';
  }

  @override
  String nowPlayingPoi(String name) {
    return 'Now playing: $name';
  }

  @override
  String triggeredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count triggered',
      one: '1 triggered',
      zero: '0 triggered',
    );
    return '$_temp0';
  }

  @override
  String get fabActivating => 'Starting...';

  @override
  String get fabDiscoveryOn => 'Discovery on';

  @override
  String get fabEnableDiscovery => 'Enable discovery';

  @override
  String get discoveryEnabled => 'Discovery mode enabled.';

  @override
  String get discoveryDisabled => 'Discovery mode disabled.';

  @override
  String get discoveryStartFailed => 'Could not start discovery mode.';

  @override
  String get noPointsAvailable => 'No points available to enable discovery.';

  @override
  String msgAutoplayIn(String name, int seconds) {
    return 'POI detected: $name. Auto-play in ${seconds}s.';
  }

  @override
  String msgAutoplayNow(String name) {
    return 'POI detected: $name. Auto-playing.';
  }

  @override
  String msgAutoplayDisabled(String name) {
    return 'POI detected: $name. Auto-play is disabled.';
  }

  @override
  String msgPausedSkip(String name) {
    return 'POI detected: $name. Skipped because audio is paused.';
  }

  @override
  String msgManualSkip(String name) {
    return 'POI detected: $name. Manual playback in progress, auto-play skipped.';
  }

  @override
  String msgAlreadyPlaying(String name) {
    return 'POI detected: $name is already playing.';
  }

  @override
  String msgNoScript(String name) {
    return 'POI detected: $name. No audio available.';
  }

  @override
  String msgDetectedOnly(String name) {
    return 'POI detected: $name.';
  }

  @override
  String get listen => 'Listen';

  @override
  String get detail => 'Details';

  @override
  String get noScriptForPoi => 'No audio available for this POI.';

  @override
  String get audioScript => 'Audio script';

  @override
  String wordsDuration(int words, int seconds) {
    return '~$words words · $seconds s';
  }

  @override
  String get noScript => 'No audio available';

  @override
  String get playingNow => 'Playing...';

  @override
  String get pausedLabel => 'Paused';

  @override
  String get stopLabel => 'Stop';

  @override
  String get directions => 'Directions';

  @override
  String get practicalInfo => 'Practical info';

  @override
  String get toilets => 'Restrooms';

  @override
  String get parkingLabel => 'Parking';

  @override
  String get photoSpot => 'Photo';

  @override
  String get goodToKnow => 'Good to know';

  @override
  String get accessibilityLabel => 'Accessibility';

  @override
  String get hoursLabel => 'Hours';

  @override
  String get audioPlayback => 'Audio playback';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Resume';

  @override
  String get playTooltip => 'Play';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get debugLogsTooltip => 'Debug logs';

  @override
  String get readingLanguage => 'Audio language';

  @override
  String get readingLanguageDesc =>
      'Default language for the audio scripts and discovery mode.';

  @override
  String get discoveryModeSection => 'Discovery mode';

  @override
  String get discoveryModeDesc =>
      'Configure auto-play when a POI is detected nearby.';

  @override
  String get autoplayTitle => 'Auto-play POIs';

  @override
  String get autoplayDesc =>
      'Automatically starts a script when discovery mode triggers a POI.';

  @override
  String get delayBeforePlay => 'Delay before playback';

  @override
  String delaySeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get vibrationTitle => 'Vibrate before playback';

  @override
  String get vibrationDesc =>
      'Adds a haptic cue before the script starts automatically.';

  @override
  String get replayVisitedTitle => 'Replay listened POIs';

  @override
  String get replayVisitedDesc =>
      'If enabled, discovery mode also re-triggers POIs already marked as listened (useful for field tests).';

  @override
  String get progressSection => 'POI progress';

  @override
  String get progressSectionDesc =>
      'Reset the POIs marked as listened on this device.';

  @override
  String visitedSaved(int count) {
    return '$count listened POIs saved';
  }

  @override
  String get resetHint => 'Reset clears the local progress for all cities.';

  @override
  String get reset => 'Reset';

  @override
  String get resetConfirmTitle => 'Reset progress?';

  @override
  String get resetConfirmBody =>
      'All POIs marked as listened will be removed from this device.';

  @override
  String get resetDone => 'POI progress has been reset.';

  @override
  String get speedSection => 'Playback speed';

  @override
  String get speedSectionDesc => 'The speed applies to all playback.';

  @override
  String get voiceSection => 'Marco\'s voice';

  @override
  String get voiceSectionDesc =>
      'Pick the voice for each language. Tap ▶️ to preview.';

  @override
  String localVoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count local',
      one: '1 local',
    );
    return '$_temp0';
  }

  @override
  String voiceN(int n) {
    return 'Voice $n';
  }

  @override
  String get voiceLocalLabel => '📱 Local (offline)';

  @override
  String voiceNetworkN(int n) {
    return 'Network voice $n';
  }

  @override
  String get voiceNetworkDesc => '☁️ Better quality, needs wifi/data';

  @override
  String networkVoicesHeader(int count) {
    return '☁️ Network voices ($count) — requires internet';
  }

  @override
  String get noVoicesInstalled =>
      'No voices installed for this language.\nGo to Settings → TTS to download some.';

  @override
  String get copyAction => 'Copy';

  @override
  String get logsCopied => 'Logs copied to clipboard.';

  @override
  String get clearAction => 'Clear';

  @override
  String get noLogs => 'No logs';

  @override
  String get aboutSection => 'About';

  @override
  String aboutVersion(String version) {
    return 'App Voyage $version';
  }

  @override
  String get aboutDesc =>
      'Location-based audio guide — a historian friend in your ears. Maps: © OpenStreetMap contributors, © CARTO.';

  @override
  String get permServiceDisabled =>
      'Location is turned off. Enable it to use discovery mode.';

  @override
  String get permDenied => 'GPS permission denied. Discovery mode not enabled.';

  @override
  String get permDeniedForever =>
      'GPS permission blocked. Open the settings to enable discovery mode.';

  @override
  String get permForegroundOnly =>
      'Discovery mode active in the foreground. Allow \"Always\" for locked screen and background.';

  @override
  String get permDialogServiceTitle => 'Enable location';

  @override
  String get permDialogServiceBody =>
      'Discovery mode needs your phone\'s location to automatically watch the points around you, including when the screen is locked.';

  @override
  String get permDialogRequestTitle => 'Allow location';

  @override
  String get permDialogRequestBody =>
      'Discovery mode uses your position to detect nearby POIs and start the audio guides at the right moment.';

  @override
  String get permDialogBackgroundTitle => 'Background access recommended';

  @override
  String get permDialogBackgroundBody =>
      'Discovery mode already works in the foreground. To keep going when the app is in the background or the screen is locked, allow \"Always\" if your phone offers it.';

  @override
  String get permDialogBlockedTitle => 'Permission required';

  @override
  String get permDialogBlockedBody =>
      'Location is permanently blocked. Open the app settings to allow discovery mode.';

  @override
  String get permDialogBackgroundBlockedTitle =>
      'Background permission blocked';

  @override
  String get openSettings => 'Open settings';

  @override
  String get settingsButton => 'Settings';

  @override
  String get continueButton => 'Continue';

  @override
  String get requestButton => 'Request';

  @override
  String get notifNearbyTitle => 'You are nearby!';

  @override
  String notifBodyNow(String name) {
    return '$name is ready. Audio starts now.';
  }

  @override
  String notifBodyIn(String name, int seconds) {
    return '$name is nearby. Audio starts in $seconds seconds.';
  }

  @override
  String get groupTitle => 'Listen together';

  @override
  String get groupSubtitle =>
      'Sync playback with your group — the host controls what everyone hears.';

  @override
  String get createSession => 'Create a session';

  @override
  String get joinSession => 'Join';

  @override
  String get sessionCodeLabel => 'Session code';

  @override
  String get sessionCodeHint => 'E.g. MARC42';

  @override
  String get youAreHost =>
      'You are the host — your playback is broadcast to the group.';

  @override
  String get memberFollowNote => 'Playback automatically follows the host.';

  @override
  String get shareCode => 'Share this code (or the QR) with your group';

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
  String get leaveSession => 'Leave session';

  @override
  String get endSession => 'End session';

  @override
  String joinedSession(String code) {
    return 'Connected to session $code.';
  }

  @override
  String get sessionEnded => 'Session ended.';

  @override
  String get hostBadge => 'Host';

  @override
  String get youBadge => 'You';

  @override
  String get invalidCode => 'Invalid code — 6 characters expected.';

  @override
  String get groupConnectionError => 'Connection error. Try again.';

  @override
  String groupActiveBadge(String code) {
    return 'Session $code';
  }

  @override
  String get groupListenScreenTitle => 'Live tour';

  @override
  String get groupWaitingForHost =>
      'The tour will begin as soon as the host starts a point of interest.';

  @override
  String get groupHostControlsNote =>
      'The host controls playback for the whole group.';

  @override
  String get groupGuestAccessNote =>
      'No need to own the city — you hear what the host shares, live.';

  @override
  String get groupOpenLiveTour => 'Open the live tour';

  @override
  String get vsdTitle => 'Marco\'s voice';

  @override
  String get vsdIntro =>
      'For Marco to guide you with a great voice, install the high-quality voices on your phone.';

  @override
  String get vsdStepsTitle => '📋 Quick steps:';

  @override
  String get vsdSteps =>
      '1. Tap \"Install voices\"\n2. Select the Google engine\n3. Tap ⚙️ → \"Install voice data\"\n4. Download:\n   🇨🇦 French (Canada)\n   🇺🇸 English (US)\n   🇪🇸 Spanish\n5. Come back to the app';

  @override
  String get vsdFree => '⏱️ It takes 30 seconds and it\'s free!';

  @override
  String get vsdLater => 'Later';

  @override
  String get vsdInstall => 'Install voices';
}
