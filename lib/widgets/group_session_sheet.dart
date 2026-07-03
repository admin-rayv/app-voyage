import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/theme.dart';
import '../l10n/l10n.dart';
import '../services/group_session_service.dart';

/// Bottom sheet « Écouter ensemble » — créer/rejoindre une session de
/// groupe, afficher le code + QR et la liste des participants en direct.
class GroupSessionSheet extends StatefulWidget {
  const GroupSessionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const GroupSessionSheet(),
      ),
    );
  }

  @override
  State<GroupSessionSheet> createState() => _GroupSessionSheetState();
}

class _GroupSessionSheetState extends State<GroupSessionSheet> {
  final GroupSessionService _service = GroupSessionService();
  final TextEditingController _codeController = TextEditingController();
  bool _busy = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _errorText = null;
    });
    final code = await _service.createSession();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (code == null) {
        _errorText = context.l10n.groupConnectionError;
      }
    });
  }

  Future<void> _join() async {
    final code = GroupSessionService.normalizeCode(_codeController.text);
    if (!GroupSessionService.isValidCode(code)) {
      setState(() => _errorText = context.l10n.invalidCode);
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });
    final joined = await _service.joinSession(code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!joined) {
        _errorText = context.l10n.groupConnectionError;
      }
    });
    if (joined && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.joinedSession(code))),
      );
    }
  }

  Future<void> _leave() async {
    setState(() => _busy = true);
    await _service.leaveSession();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.sessionEnded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _service.activeCode,
      builder: (context, code, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.subtleBorderOf(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('👥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.groupTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.groupSubtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondaryOf(context),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                if (code == null) _buildIdle(context) else _buildActive(code),
                if (_errorText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _busy ? null : _create,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.podcasts),
          label: Text(context.l10n.createSession),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: GroupSessionService.codeLength,
                decoration: InputDecoration(
                  labelText: context.l10n.sessionCodeLabel,
                  hintText: context.l10n.sessionCodeHint,
                  counterText: '',
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _join(),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _busy ? null : _join,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              child: Text(context.l10n.joinSession),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActive(String code) {
    final isHost = _service.isHost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Code + QR
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.softBackgroundOf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.subtleBorderOf(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.shareCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: code,
                  size: 92,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isHost ? context.l10n.youAreHost : context.l10n.memberFollowNote,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        // Participants (Presence, en direct)
        ValueListenableBuilder<List<GroupParticipant>>(
          valueListenable: _service.participants,
          builder: (context, people, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.participantsCount(people.length),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: people.map((person) {
                    return Chip(
                      avatar: Text(
                        person.isHost ? '🎙️' : '🎧',
                        style: const TextStyle(fontSize: 14),
                      ),
                      label: Text(
                        person.isMe
                            ? '${person.label} (${context.l10n.youBadge})'
                            : person.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _busy ? null : _leave,
          icon: const Icon(Icons.logout, size: 18),
          label: Text(
            isHost ? context.l10n.endSession : context.l10n.leaveSession,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
