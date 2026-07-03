import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/l10n.dart';
import 'debug_log.dart';

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
    DebugLog().log('[PermissionService] check: isLocationServiceEnabled?');
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    DebugLog().log('[PermissionService] serviceEnabled=$serviceEnabled');
    if (!serviceEnabled) {
      return DiscoveryPermissionResult.serviceDisabled(
        _PermissionMessages.locationServiceDisabledSnack,
      );
    }

    final permission = await Geolocator.checkPermission();
    DebugLog().log('[PermissionService] checkPermission=$permission');
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
    // La permission « arrière-plan » n'existe pas sur le web — et
    // requestPermission() peut y rester suspendu indéfiniment.
    requestBackground = requestBackground && !kIsWeb;

    final initialStatus = await checkDiscoveryPermission();
    if (initialStatus.status == DiscoveryPermissionStatus.serviceDisabled) {
      if (!context.mounted) {
        return initialStatus;
      }
      final openSettings = await _showDialog(
        context,
        title: context.l10n.permDialogServiceTitle,
        message: context.l10n.permDialogServiceBody,
        confirmLabel: context.l10n.settingsButton,
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
        title: context.l10n.permDialogRequestTitle,
        message: context.l10n.permDialogRequestBody,
        confirmLabel: context.l10n.continueButton,
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
        title: context.l10n.permDialogBlockedTitle,
        message: context.l10n.permDialogBlockedBody,
        confirmLabel: context.l10n.openSettings,
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
        title: context.l10n.permDialogBackgroundTitle,
        message: context.l10n.permDialogBackgroundBody,
        confirmLabel: context.l10n.requestButton,
      );

      if (requestAlways) {
        DebugLog().log('[PermissionService] requesting background permission');
        permission = await Geolocator.requestPermission();
        DebugLog().log('[PermissionService] request result=$permission');
      }

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) {
          return DiscoveryPermissionResult.deniedForever();
        }
        final openSettings = await _showDialog(
          context,
          title: context.l10n.permDialogBackgroundBlockedTitle,
          message: context.l10n.permDialogBlockedBody,
          confirmLabel: context.l10n.openSettings,
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
            child: Text(dialogContext.l10n.cancel),
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

/// Messages de secours portés par DiscoveryPermissionResult (FR).
/// L'UI affiche des messages localisés à partir du statut — voir
/// _permissionMessage() dans map_screen.
abstract final class _PermissionMessages {
  static const String locationServiceDisabledSnack =
      'La localisation est désactivée. Activez-la pour utiliser le mode découverte.';

  static const String locationDeniedSnack =
      'Autorisation GPS refusée. Mode découverte non activé.';

  static const String locationDeniedForeverSnack =
      'Autorisation GPS bloquée. Ouvrez les réglages pour activer le mode découverte.';

  static const String locationForegroundOnlySnack =
      'Mode découverte actif au premier plan. Autorisez "Toujours" pour écran verrouillé et arrière-plan.';
}
