/// Point d'entrée EdgeTtsService — implémentation par plateforme.
///
/// Le service réel (edge_tts_service_io.dart) utilise dart:io (WebSocket,
/// fichiers) et n'est pas disponible sur le web: le build web reçoit un
/// stub no-op et l'app retombe naturellement sur le TTS natif du navigateur.
library;

export 'edge_tts_service_stub.dart'
    if (dart.library.io) 'edge_tts_service_io.dart';
