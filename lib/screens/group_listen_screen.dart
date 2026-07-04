import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/categories.dart';
import '../config/theme.dart';
import '../l10n/l10n.dart';
import '../models/audio_state.dart';
import '../services/audio_service.dart';
import '../services/group_session_service.dart';

/// Écran invité « Visite en cours » — l'invité suit la visite pilotée par
/// l'hôte, sans accès à la ville (ni carte, ni liste de POIs). Il ne voit
/// que le POI que l'hôte fait jouer, moment par moment.
class GroupListenScreen extends StatefulWidget {
  const GroupListenScreen({super.key});

  @override
  State<GroupListenScreen> createState() => _GroupListenScreenState();
}

class _GroupListenScreenState extends State<GroupListenScreen> {
  final GroupSessionService _service = GroupSessionService();
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _service.activeCode.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _service.activeCode.removeListener(_onSessionChanged);
    super.dispose();
  }

  /// Session terminée ailleurs (sheet, erreur réseau) → retour arrière.
  void _onSessionChanged() {
    if (_service.activeCode.value == null && mounted && !_leaving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) context.pop();
      });
    }
  }

  Future<void> _leave() async {
    setState(() => _leaving = true);
    await _service.leaveSession();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.groupListenScreenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSessionCard(context),
              Expanded(child: _buildNowPlaying(context)),
              Text(
                context.l10n.groupHostControlsNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryOf(context),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _leaving ? null : _leave,
                icon: const Icon(Icons.logout, size: 18),
                label: Text(context.l10n.leaveSession),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Code de session + participants en direct.
  Widget _buildSessionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.softBackgroundOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.subtleBorderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: _service.activeCode,
            builder: (context, code, _) => Text(
              context.l10n.groupActiveBadge(code ?? '—'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.groupGuestAccessNote,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryOf(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<GroupParticipant>>(
            valueListenable: _service.participants,
            builder: (context, people, _) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: people.map((person) {
                  return Chip(
                    avatar: Text(
                      person.isHost ? '🎙️' : '🎧',
                      style: const TextStyle(fontSize: 13),
                    ),
                    label: Text(
                      person.isMe
                          ? '${person.label} (${context.l10n.youBadge})'
                          : person.label,
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// POI en cours de lecture (suit AudioService) — ou attente de l'hôte.
  Widget _buildNowPlaying(BuildContext context) {
    final audio = AudioService();
    return StreamBuilder<AudioState>(
      stream: audio.stateStream,
      initialData: audio.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final poi = state?.currentPoi;

        if (state == null ||
            poi == null ||
            state.playState == AudioPlayState.stopped) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎧', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    context.l10n.groupWaitingForHost,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final category = Categories.byKey(poi.primaryCategory);
        final isPaused = state.playState == AudioPlayState.paused;
        final progress = state.duration.inMilliseconds > 0
            ? (state.position.inMilliseconds / state.duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : null;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category?.emoji ?? '📍',
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  poi.localizedName(context.languageCode),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress, minHeight: 6),
                ),
              ),
              const SizedBox(height: 14),
              Icon(
                isPaused ? Icons.pause_circle : Icons.play_circle,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
