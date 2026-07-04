// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App Voyage';

  @override
  String get tagline => 'Un amigo historiador en tus auriculares 🎧';

  @override
  String get exploreCity => 'Explora una ciudad';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String poiCountBadge(int count) {
    return '$count POIs';
  }

  @override
  String get citiesLoading => 'Cargando ciudades...';

  @override
  String get noCities => 'No hay ciudades disponibles';

  @override
  String get comeBackSoon => '¡Vuelve pronto!';

  @override
  String get citiesError => 'No se pudieron cargar las ciudades';

  @override
  String get checkConnection => 'Verifica tu conexión a internet';

  @override
  String get retry => 'Reintentar';

  @override
  String get onb1Title => 'Explora libremente';

  @override
  String get onb1Body =>
      'Sin recorridos fijos. Todos los puntos de interés de la ciudad están en el mapa — pasea por donde quieras, a tu ritmo.';

  @override
  String get onb2Title => 'Activa el modo descubrimiento';

  @override
  String get onb2Body =>
      'Cuando te acerques a un lugar, el audio se activa solo. Permite la ubicación «Siempre» para que funcione con el teléfono en el bolsillo y la pantalla bloqueada.';

  @override
  String get onbLangTitle => 'El idioma de Marco';

  @override
  String get onbLangBody =>
      'Elige el idioma de las audioguías. Podrás cambiarlo en los ajustes.';

  @override
  String get onb3Title => 'Marco te lo cuenta';

  @override
  String get onb3Body =>
      'Tu amigo guía comparte la historia, las anécdotas y los mejores consejos de cada lugar. ¡Ponte los auriculares y déjate sorprender!';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get letsGo => '¡Vamos!';

  @override
  String get downloadAudiosTooltip => 'Descargar la ciudad';

  @override
  String get viewMapTooltip => 'Ver el mapa';

  @override
  String get viewListTooltip => 'Ver la lista';

  @override
  String get myPositionTooltip => 'Mi posición';

  @override
  String get groupListenTooltip => 'Escuchar juntos';

  @override
  String get downloadDialogTitle => '¿Descargar la ciudad?';

  @override
  String downloadDialogBody(String city, String language) {
    return 'Pone todo $city en tu teléfono: los POIs y sus textos, los audios de Marco ($language) y el mapa. Hazlo con Wi-Fi — después toda la ciudad funciona sin red.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get download => 'Descargar';

  @override
  String get downloadProgressTitle => 'Descargando la ciudad';

  @override
  String downloadProgressCount(int current, int total) {
    return '$current / $total elementos';
  }

  @override
  String get stopAction => 'Detener';

  @override
  String downloadDone(int count) {
    return 'Ciudad descargada ($count elementos). ¡Lista para pasear, incluso sin red!';
  }

  @override
  String downloadInterrupted(int current, int total) {
    return 'Descarga interrumpida ($current/$total).';
  }

  @override
  String allFilter(int count) {
    return 'Todos ($count)';
  }

  @override
  String unvisitedOnlyFilter(int count) {
    return 'Solo no escuchados ($count)';
  }

  @override
  String progressListened(int visited, int total) {
    return '$visited/$total POIs escuchados';
  }

  @override
  String get legendToDiscover => 'Por descubrir';

  @override
  String get legendListened => 'Escuchado';

  @override
  String get legendPlaying => 'Reproduciendo';

  @override
  String get noPoisWithFilters => 'No se encontraron POIs con estos filtros';

  @override
  String errorWith(String error) {
    return 'Error: $error';
  }

  @override
  String get discoveryActiveTitle => 'Modo descubrimiento activo';

  @override
  String get discoveryActivating => 'Activando el modo descubrimiento...';

  @override
  String watchingPois(int count) {
    return 'Vigilando $count POIs';
  }

  @override
  String get checkingPermissions => 'Comprobando permisos y GPS';

  @override
  String lastDetected(String name) {
    return 'Último POI detectado: $name';
  }

  @override
  String nowPlayingPoi(String name) {
    return 'Reproduciendo: $name';
  }

  @override
  String triggeredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activados',
      one: '1 activado',
      zero: '0 activado',
    );
    return '$_temp0';
  }

  @override
  String get fabActivating => 'Activando...';

  @override
  String get fabDiscoveryOn => 'Descubrimiento activo';

  @override
  String get fabEnableDiscovery => 'Activar descubrimiento';

  @override
  String get discoveryEnabled => 'Modo descubrimiento activado.';

  @override
  String get discoveryDisabled => 'Modo descubrimiento desactivado.';

  @override
  String get discoveryStartFailed =>
      'No se pudo iniciar el modo descubrimiento.';

  @override
  String get noPointsAvailable =>
      'No hay puntos disponibles para activar el descubrimiento.';

  @override
  String msgAutoplayIn(String name, int seconds) {
    return 'POI detectado: $name. Reproducción automática en ${seconds}s.';
  }

  @override
  String msgAutoplayNow(String name) {
    return 'POI detectado: $name. Reproducción automática.';
  }

  @override
  String msgAutoplayDisabled(String name) {
    return 'POI detectado: $name. Reproducción automática desactivada.';
  }

  @override
  String msgPausedSkip(String name) {
    return 'POI detectado: $name. Omitido porque el audio está en pausa.';
  }

  @override
  String msgManualSkip(String name) {
    return 'POI detectado: $name. Reproducción manual en curso, auto-play omitido.';
  }

  @override
  String msgAlreadyPlaying(String name) {
    return 'POI detectado: $name ya se está reproduciendo.';
  }

  @override
  String msgNoScript(String name) {
    return 'POI detectado: $name. No hay audio disponible.';
  }

  @override
  String msgDetectedOnly(String name) {
    return 'POI detectado: $name.';
  }

  @override
  String get listen => 'Escuchar';

  @override
  String get detail => 'Detalle';

  @override
  String get noScriptForPoi => 'No hay audio disponible para este POI.';

  @override
  String get audioScript => 'Guion de audio';

  @override
  String wordsDuration(int words, int seconds) {
    return '~$words palabras · $seconds s';
  }

  @override
  String get noScript => 'No hay audio disponible';

  @override
  String get playingNow => 'Reproduciendo...';

  @override
  String get pausedLabel => 'En pausa';

  @override
  String get stopLabel => 'Stop';

  @override
  String get directions => 'Cómo llegar';

  @override
  String get practicalInfo => 'Información práctica';

  @override
  String get toilets => 'Baños';

  @override
  String get parkingLabel => 'Estacionamiento';

  @override
  String get photoSpot => 'Foto';

  @override
  String get goodToKnow => 'Bueno saber';

  @override
  String get accessibilityLabel => 'Accesibilidad';

  @override
  String get hoursLabel => 'Horarios';

  @override
  String get audioPlayback => 'Reproducción de audio';

  @override
  String get pauseTooltip => 'Pausa';

  @override
  String get resumeTooltip => 'Reanudar';

  @override
  String get playTooltip => 'Reproducir';

  @override
  String get stopTooltip => 'Detener';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get debugLogsTooltip => 'Registros de depuración';

  @override
  String get readingLanguage => 'Idioma del audio';

  @override
  String get readingLanguageDesc =>
      'Idioma predeterminado para los guiones de audio y el modo descubrimiento.';

  @override
  String get discoveryModeSection => 'Modo descubrimiento';

  @override
  String get discoveryModeDesc =>
      'Configura la reproducción automática cuando se detecta un POI cercano.';

  @override
  String get autoplayTitle => 'Reproducción automática de POIs';

  @override
  String get autoplayDesc =>
      'Inicia automáticamente un guion cuando el modo descubrimiento activa un POI.';

  @override
  String get delayBeforePlay => 'Retraso antes de reproducir';

  @override
  String delaySeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get vibrationTitle => 'Vibración antes de reproducir';

  @override
  String get vibrationDesc =>
      'Añade una señal háptica antes del inicio automático del guion.';

  @override
  String get replayVisitedTitle => 'Repetir POIs ya escuchados';

  @override
  String get replayVisitedDesc =>
      'Si está activado, el modo descubrimiento también vuelve a activar los POIs ya marcados como escuchados (útil para pruebas de campo).';

  @override
  String get progressSection => 'Progreso de POIs';

  @override
  String get progressSectionDesc =>
      'Reinicia los POIs marcados como escuchados en este dispositivo.';

  @override
  String visitedSaved(int count) {
    return '$count POIs escuchados guardados';
  }

  @override
  String get resetHint =>
      'El reinicio borra el progreso local de todas las ciudades.';

  @override
  String get reset => 'Reiniciar';

  @override
  String get resetConfirmTitle => '¿Reiniciar el progreso?';

  @override
  String get resetConfirmBody =>
      'Todos los POIs marcados como escuchados se eliminarán de este dispositivo.';

  @override
  String get resetDone => 'Progreso de POIs reiniciado.';

  @override
  String get speedSection => 'Velocidad de reproducción';

  @override
  String get speedSectionDesc =>
      'La velocidad se aplica a todas las reproducciones.';

  @override
  String get voiceSection => 'La voz de Marco';

  @override
  String get voiceSectionDesc =>
      'Elige la voz para cada idioma. Toca ▶️ para probar.';

  @override
  String localVoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count locales',
      one: '1 local',
    );
    return '$_temp0';
  }

  @override
  String voiceN(int n) {
    return 'Voz $n';
  }

  @override
  String get voiceLocalLabel => '📱 Local (sin conexión)';

  @override
  String voiceNetworkN(int n) {
    return 'Voz en línea $n';
  }

  @override
  String get voiceNetworkDesc => '☁️ Mejor calidad, requiere wifi/datos';

  @override
  String networkVoicesHeader(int count) {
    return '☁️ Voces en línea ($count) — requiere internet';
  }

  @override
  String get noVoicesInstalled =>
      'No hay voces instaladas para este idioma.\nVe a Ajustes → TTS para descargarlas.';

  @override
  String get copyAction => 'Copiar';

  @override
  String get logsCopied => 'Registros copiados al portapapeles.';

  @override
  String get clearAction => 'Borrar';

  @override
  String get noLogs => 'Sin registros';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String aboutVersion(String version) {
    return 'App Voyage $version';
  }

  @override
  String get aboutDesc =>
      'Audioguía geolocalizada — un amigo historiador en tus auriculares. Mapas: © OpenStreetMap contributors, © CARTO.';

  @override
  String get permServiceDisabled =>
      'La ubicación está desactivada. Actívala para usar el modo descubrimiento.';

  @override
  String get permDenied =>
      'Permiso de GPS denegado. Modo descubrimiento no activado.';

  @override
  String get permDeniedForever =>
      'Permiso de GPS bloqueado. Abre los ajustes para activar el modo descubrimiento.';

  @override
  String get permForegroundOnly =>
      'Modo descubrimiento activo en primer plano. Permite «Siempre» para pantalla bloqueada y segundo plano.';

  @override
  String get permDialogServiceTitle => 'Activar la ubicación';

  @override
  String get permDialogServiceBody =>
      'El modo descubrimiento necesita la ubicación del teléfono para vigilar automáticamente los puntos a tu alrededor, incluso con la pantalla bloqueada.';

  @override
  String get permDialogRequestTitle => 'Permitir la ubicación';

  @override
  String get permDialogRequestBody =>
      'El modo descubrimiento usa tu posición para detectar POIs cercanos y lanzar las audioguías en el momento adecuado.';

  @override
  String get permDialogBackgroundTitle => 'Acceso en segundo plano recomendado';

  @override
  String get permDialogBackgroundBody =>
      'El modo descubrimiento ya funciona en primer plano. Para continuar cuando la app pase a segundo plano o la pantalla se bloquee, permite «Siempre» si tu teléfono lo ofrece.';

  @override
  String get permDialogBlockedTitle => 'Permiso requerido';

  @override
  String get permDialogBlockedBody =>
      'La ubicación está bloqueada permanentemente. Abre los ajustes de la app para permitir el modo descubrimiento.';

  @override
  String get permDialogBackgroundBlockedTitle =>
      'Permiso en segundo plano bloqueado';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get settingsButton => 'Ajustes';

  @override
  String get continueButton => 'Continuar';

  @override
  String get requestButton => 'Solicitar';

  @override
  String get notifNearbyTitle => '¡Estás cerca!';

  @override
  String notifBodyNow(String name) {
    return '$name está listo. El audio comienza ahora.';
  }

  @override
  String notifBodyIn(String name, int seconds) {
    return '$name está cerca. El audio comienza en $seconds segundos.';
  }

  @override
  String get groupTitle => 'Escuchar juntos';

  @override
  String get groupSubtitle =>
      'Sincroniza la escucha con tu grupo — el anfitrión controla la reproducción para todos.';

  @override
  String get createSession => 'Crear una sesión';

  @override
  String get joinSession => 'Unirse';

  @override
  String get sessionCodeLabel => 'Código de sesión';

  @override
  String get sessionCodeHint => 'Ej.: MARC42';

  @override
  String get youAreHost =>
      'Eres el anfitrión — tu reproducción se transmite al grupo.';

  @override
  String get memberFollowNote =>
      'La reproducción sigue automáticamente al anfitrión.';

  @override
  String get shareCode => 'Comparte este código (o el QR) con tu grupo';

  @override
  String participantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String get leaveSession => 'Salir de la sesión';

  @override
  String get endSession => 'Terminar la sesión';

  @override
  String joinedSession(String code) {
    return 'Conectado a la sesión $code.';
  }

  @override
  String get sessionEnded => 'Sesión terminada.';

  @override
  String get hostBadge => 'Anfitrión';

  @override
  String get youBadge => 'Tú';

  @override
  String get invalidCode => 'Código inválido — se esperan 6 caracteres.';

  @override
  String get groupConnectionError => 'Error de conexión. Inténtalo de nuevo.';

  @override
  String groupActiveBadge(String code) {
    return 'Sesión $code';
  }

  @override
  String get groupListenScreenTitle => 'Visita en curso';

  @override
  String get groupWaitingForHost =>
      'La visita comenzará en cuanto el anfitrión inicie un punto de interés.';

  @override
  String get groupHostControlsNote =>
      'El anfitrión controla la reproducción para todo el grupo.';

  @override
  String get groupGuestAccessNote =>
      'No necesitas la ciudad — escuchas lo que comparte el anfitrión, en directo.';

  @override
  String get groupOpenLiveTour => 'Abrir la visita en curso';

  @override
  String get favoriteTooltip => 'Favorito';

  @override
  String get favoriteAdded => 'Añadido a favoritos ❤️';

  @override
  String get favoriteRemoved => 'Quitado de favoritos.';

  @override
  String favoritesFilter(int count) {
    return '❤️ Favoritos ($count)';
  }

  @override
  String get rewind10Tooltip => 'Retroceder 10 segundos';

  @override
  String get forward10Tooltip => 'Avanzar 10 segundos';

  @override
  String get batteryTitle => '¿Paseo largo? Protege el modo descubrimiento';

  @override
  String get batteryBody =>
      'Algunos teléfonos Android cortan el GPS en segundo plano para ahorrar batería — Marco se callaría en pleno paseo. Excluye App Voyage de la optimización de batería («Sin restricciones»).';

  @override
  String get batteryOpenSettings => 'Abrir los ajustes de batería';

  @override
  String get reportProblemTooltip => 'Informar de un problema';

  @override
  String get reportProblemBodyIntro =>
      'Describe el problema (error en el texto, posición GPS, audio, otro):';

  @override
  String get reportNoEmailApp =>
      'No hay app de correo — escríbenos a admin@rayv.ca';

  @override
  String get shareAction => 'Compartir';

  @override
  String get searchHint => 'Buscar un lugar…';

  @override
  String get storageSection => 'Almacenamiento sin conexión';

  @override
  String get storageSectionDesc =>
      'Lo que se guarda en el teléfono para funcionar sin red. Vaciar un caché no rompe nada — se reconstruye con el uso.';

  @override
  String get storageAudio => 'Audios de Marco';

  @override
  String get storageMaps => 'Mapas';

  @override
  String get storageData => 'Datos de las ciudades (POIs y textos)';

  @override
  String storageSize(String size) {
    return '$size MB';
  }

  @override
  String get storageClearAction => 'Vaciar';

  @override
  String get storageCleared => 'Caché vaciado.';

  @override
  String get vsdTitle => 'La voz de Marco';

  @override
  String get vsdIntro =>
      'Para que Marco te guíe con una buena voz, instala las voces de calidad en tu teléfono.';

  @override
  String get vsdStepsTitle => '📋 Pasos rápidos:';

  @override
  String get vsdSteps =>
      '1. Toca «Instalar voces»\n2. Selecciona el motor de Google\n3. Toca ⚙️ → «Instalar datos de voz»\n4. Descarga:\n   🇨🇦 Francés (Canadá)\n   🇺🇸 Inglés (EE. UU.)\n   🇪🇸 Español\n5. Vuelve a la app';

  @override
  String get vsdFree => '⏱️ ¡Toma 30 segundos y es gratis!';

  @override
  String get vsdLater => 'Más tarde';

  @override
  String get vsdInstall => 'Instalar voces';
}
