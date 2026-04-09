import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

enum DiscoveryPermissionStatus {
  grantedAlways,
  grantedForegroundOnly,
  denied,
  deniedForever,
  serviceDisabled,
}

class DiscoveryPermissionResult {
  const DiscoveryPermissionResult._(this.status, this.message);

  final DiscoveryPermissionStatus status;
  final String? message;

  bool get isGranted =>
      status == DiscoveryPermissionStatus.grantedAlways ||
      status == DiscoveryPermissionStatus.grantedForegroundOnly;

  bool get hasBackgroundAccess =>
      status == DiscoveryPermissionStatus.grantedAlways;

  factory DiscoveryPermissionResult.grantedAlways([String? message]) =>
      DiscoveryPermissionResult._(
        DiscoveryPermissionStatus.grantedAlways,
        message,
      );

  factory DiscoveryPermissionResult.grantedForegroundOnly([String? message]) =>
      DiscoveryPermissionResult._(
        DiscoveryPermissionStatus.grantedForegroundOnly,
        message,
      );

  factory DiscoveryPermissionResult.denied([String? message]) =>
      DiscoveryPermissionResult._(DiscoveryPermissionStatus.denied, message);

  factory DiscoveryPermissionResult.deniedForever([String? message]) =>
      DiscoveryPermissionResult._(
        DiscoveryPermissionStatus.deniedForever,
        message,
      );

  factory DiscoveryPermissionResult.serviceDisabled([String? message]) =>
      DiscoveryPermissionResult._(
        DiscoveryPermissionStatus.serviceDisabled,
        message,
      );
}

class PermissionService {
  PermissionService._internal();

  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() => _instance;

  Future<DiscoveryPermissionResult> checkDiscoveryPermission({
    bool requireBackground = false,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return DiscoveryPermissionResult.serviceDisabled(
        _PermissionMessages.locationServiceDisabledSnack,
      );
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return DiscoveryPermissionResult.denied(
        _PermissionMessages.locationDeniedSnack,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return DiscoveryPermissionResult.deniedForever(
        _PermissionMessages.locationDeniedForeverSnack,
      );
    }

    if (permission == LocationPermission.always) {
      return DiscoveryPermissionResult.grantedAlways();
    }

    if (permission == LocationPermission.whileInUse) {
      if (requireBackground) {
        return DiscoveryPermissionResult.grantedForegroundOnly(
          _PermissionMessages.locationForegroundOnlySnack,
        );
      }

      return DiscoveryPermissionResult.grantedForegroundOnly();
    }

    return DiscoveryPermissionResult.denied(
      _PermissionMessages.locationDeniedSnack,
    );
  }

  Future<DiscoveryPermissionResult> requestDiscoveryPermissions(
    BuildContext context, {
    bool requestBackground = true,
  }) async {
    final initialStatus = await checkDiscoveryPermission();
    if (initialStatus.status == DiscoveryPermissionStatus.serviceDisabled) {
      if (!context.mounted) {
        return initialStatus;
      }
      final openSettings = await _showDialog(
        context,
        title: 'Activer la localisation',
        message: _PermissionMessages.locationServiceDisabledDialog,
        confirmLabel: 'Réglages',
      );
      if (openSettings) {
        await openLocationSettings();
      }
      return initialStatus;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!context.mounted) {
        return DiscoveryPermissionResult.denied();
      }
      final shouldRequest = await _showDialog(
        context,
        title: 'Autoriser la localisation',
        message: _PermissionMessages.locationRequestDialog,
        confirmLabel: 'Continuer',
      );
      if (!shouldRequest) {
        return DiscoveryPermissionResult.denied(
          _PermissionMessages.locationDeniedSnack,
        );
      }

      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return DiscoveryPermissionResult.denied(
        _PermissionMessages.locationDeniedSnack,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) {
        return DiscoveryPermissionResult.deniedForever();
      }
      final openSettings = await _showDialog(
        context,
        title: 'Autorisation requise',
        message: _PermissionMessages.locationDeniedForeverDialog,
        confirmLabel: 'Ouvrir les réglages',
      );
      if (openSettings) {
        await openAppSettings();
      }
      return DiscoveryPermissionResult.deniedForever(
        _PermissionMessages.locationDeniedForeverSnack,
      );
    }

    if (permission == LocationPermission.whileInUse && requestBackground) {
      if (!context.mounted) {
        return DiscoveryPermissionResult.grantedForegroundOnly(
          _PermissionMessages.locationForegroundOnlySnack,
        );
      }
      final requestAlways = await _showDialog(
        context,
        title: 'Accès en arrière-plan recommandé',
        message: _PermissionMessages.locationBackgroundDialog,
        confirmLabel: 'Demander',
      );

      if (requestAlways) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) {
          return DiscoveryPermissionResult.deniedForever();
        }
        final openSettings = await _showDialog(
          context,
          title: 'Autorisation en arrière-plan bloquée',
          message: _PermissionMessages.locationDeniedForeverDialog,
          confirmLabel: 'Ouvrir les réglages',
        );
        if (openSettings) {
          await openAppSettings();
        }
        return DiscoveryPermissionResult.deniedForever(
          _PermissionMessages.locationDeniedForeverSnack,
        );
      }
    }

    if (permission == LocationPermission.always) {
      return DiscoveryPermissionResult.grantedAlways();
    }

    if (permission == LocationPermission.whileInUse) {
      return DiscoveryPermissionResult.grantedForegroundOnly(
        _PermissionMessages.locationForegroundOnlySnack,
      );
    }

    return DiscoveryPermissionResult.denied(
      _PermissionMessages.locationDeniedSnack,
    );
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<bool> _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

abstract final class _PermissionMessages {
  static const String locationServiceDisabledDialog =
      'Le mode découverte a besoin de la localisation du téléphone pour '
      'surveiller automatiquement les points autour de vous, y compris '
      'quand l’écran est verrouillé.';

  static const String locationRequestDialog =
      'Le mode découverte utilise votre position pour détecter les POIs '
      'proches et lancer les guides audio au bon moment.';

  static const String locationBackgroundDialog =
      'Le mode découverte fonctionne déjà au premier plan. Pour continuer '
      'quand l’app passe en arrière-plan ou écran verrouillé, autorisez '
      '"Toujours" si votre téléphone le propose.';

  static const String locationDeniedForeverDialog =
      'La localisation est bloquée de façon permanente. Ouvrez les '
      'réglages de l’app pour autoriser le mode découverte.';

  static const String locationServiceDisabledSnack =
      'La localisation est désactivée. Activez-la pour utiliser le mode découverte.';

  static const String locationDeniedSnack =
      'Autorisation GPS refusée. Mode découverte non activé.';

  static const String locationDeniedForeverSnack =
      'Autorisation GPS bloquée. Ouvrez les réglages pour activer le mode découverte.';

  static const String locationForegroundOnlySnack =
      'Mode découverte actif au premier plan. Autorisez "Toujours" pour écran verrouillé et arrière-plan.';
}
