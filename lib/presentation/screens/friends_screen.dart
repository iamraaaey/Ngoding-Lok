import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/progression.dart';
import '../../core/session/user_session.dart';
import '../../core/social/friend.dart';
import '../../core/social/referral_link.dart';
import '../../data/repositories/user_repository.dart';
import '../theme/landing_tokens.dart';
import '../theme/league_style.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';
import '../widgets/noir_dialog.dart';

/// The social hub: share an invite code, redeem a friend's code, and see the
/// live Firebase-backed friend list. A successful redemption connects both
/// accounts and grants 50 XP to each exactly once.
class FriendsScreen extends StatefulWidget {
  final UserSession user;
  final String? uid;
  final UserRepository repository;
  final ValueChanged<UserSession> onUserUpdated;
  final VoidCallback onBack;

  const FriendsScreen({
    super.key,
    required this.user,
    required this.uid,
    required this.repository,
    required this.onUserUpdated,
    required this.onBack,
  });

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _codeController = TextEditingController();
  bool _redeeming = false;
  Stream<List<FriendSummary>>? _liveFriends;

  @override
  void initState() {
    super.initState();
    _bindFirebaseFriends();
    // A code carried in from an invite link (`?ref=CODE`) is normally
    // redeemed automatically at login; if it is still pending (e.g. the
    // user was offline), surface it here ready to submit.
    final pending = ReferralLink.pendingCode;
    if (pending != null && !widget.user.referralRewardClaimed) {
      _codeController.text = pending;
    }
  }

  @override
  void didUpdateWidget(covariant FriendsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid ||
        oldWidget.repository != widget.repository) {
      _bindFirebaseFriends();
    }
  }

  void _bindFirebaseFriends() {
    final uid = widget.uid;
    _liveFriends = uid == null
        ? Stream.value(const <FriendSummary>[])
        : widget.repository.streamFriendsForUser(uid);

    // Also repair links created before the stale-session overwrite fix. This
    // is idempotent and is protected by the redemption document in rules.
    if (uid != null) {
      unawaited(
        widget.repository.reconcileReferralFriendLink(uid).catchError((error) {
          debugPrint('Referral link reconciliation skipped: $error');
        }),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Stream<List<FriendSummary>> _friendsStream() {
    return _liveFriends ?? Stream.value(const <FriendSummary>[]);
  }

  Future<void> _redeemCode() async {
    final uid = widget.uid;
    if (uid == null) {
      showNoirSnack(
        context,
        'Sign in with Firebase to add friends.',
        success: false,
      );
      return;
    }
    if (_codeController.text.trim().isEmpty) {
      showNoirSnack(context, 'Enter a referral code first.', success: false);
      return;
    }

    setState(() => _redeeming = true);
    try {
      final updated = await widget.repository.redeemReferralCode(
        uid,
        _codeController.text,
      );
      widget.onUserUpdated(updated);
      _codeController.clear();
      if (mounted) {
        showNoirSnack(context, 'Friend added. You both earned +50 XP.');
      }
    } on ReferralException catch (error) {
      if (mounted) showNoirSnack(context, error.message, success: false);
    } catch (_) {
      if (mounted) {
        showNoirSnack(
          context,
          'Could not sync the referral right now. Try again.',
          success: false,
        );
      }
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  Future<void> _showFriendDetails(FriendSummary friend) async {
    final skin = NoirSkin.of(context);
    final progression = Progression(friend.xp);
    final tier = progression.tier;
    await showNoirDialog<void>(
      context,
      builder: (_) => NoirDialogShell(
        title: 'FRIEND\nDETAIL',
        eyebrow: friend.displayName,
        maxWidth: 520,
        maxHeight: 520,
        actions: [
          CinematicOutlineButton(
            label: 'Close',
            compact: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: tier.color.withValues(alpha: 0.2),
                  backgroundImage: friend.photoUrl == null
                      ? null
                      : NetworkImage(friend.photoUrl!),
                  child: friend.photoUrl == null
                      ? Icon(tier.icon, color: tier.color)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.displayName,
                        style: TextStyle(
                          color: skin.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend.email,
                        style: LandingTokens.mono(
                          fontSize: 11,
                          color: skin.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DetailMetricRow(label: 'League', value: tier.label.toUpperCase()),
            const SizedBox(height: 8),
            _DetailMetricRow(label: 'XP', value: '${friend.xp}'),
            const SizedBox(height: 8),
            _DetailMetricRow(label: 'Streak', value: '${friend.streak} days'),
            const SizedBox(height: 8),
            _DetailMetricRow(
              label: 'Modules cleared',
              value: '${friend.completedCount}',
            ),
            const SizedBox(height: 8),
            _DetailMetricRow(
              label: 'Streak freezes',
              value: '${friend.streakFreezes}',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) showNoirSnack(context, 'Invite code copied.');
  }

  Future<void> _copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      showNoirSnack(context, 'Invite link copied. Send it to a friend.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    final code =
        widget.user.referralCode ??
        (widget.uid == null
            ? null
            : widget.repository.referralCodeForUid(widget.uid!));
    final inviteLink = code == null ? null : ReferralLink.inviteUrl(code);

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                // The social hub is intentionally edge-to-edge on desktop so
                // invite controls and the crew list have room to breathe.
                constraints: const BoxConstraints(maxWidth: 1800),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.sizeOf(context).width < 600 ? 12 : 20,
                    12,
                    MediaQuery.sizeOf(context).width < 600 ? 12 : 20,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NoirHeader(
                        title: 'Friends',
                        eyebrow: 'Social XP',
                        skin: skin,
                        onBack: widget.onBack,
                        trailing: CinematicOutlineButton(
                          label: 'Refresh',
                          icon: Icons.refresh,
                          compact: true,
                          onPressed: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InvitePanel(
                        skin: skin,
                        code: code,
                        inviteLink: inviteLink,
                        enabled: widget.uid != null,
                        onCopy: code == null ? null : () => _copyCode(code),
                        onCopyLink: inviteLink == null
                            ? null
                            : () => _copyLink(inviteLink),
                        controller: _codeController,
                        redeeming: _redeeming,
                        onRedeem: _redeemCode,
                      ),
                      const SizedBox(height: 16),
                      _FriendsPanel(
                        skin: skin,
                        friendsStream: _friendsStream(),
                        onOpenDetails: _showFriendDetails,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitePanel extends StatelessWidget {
  final NoirSkin skin;
  final String? code;
  final String? inviteLink;
  final bool enabled;
  final VoidCallback? onCopy;
  final VoidCallback? onCopyLink;
  final TextEditingController controller;
  final bool redeeming;
  final VoidCallback onRedeem;

  const _InvitePanel({
    required this.skin,
    required this.code,
    required this.inviteLink,
    required this.enabled,
    required this.onCopy,
    required this.onCopyLink,
    required this.controller,
    required this.redeeming,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.group_add, color: LandingTokens.circuit),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '// INVITE A CODER',
                  style: LandingTokens.label(
                    fontSize: 10,
                    color: LandingTokens.circuit,
                  ),
                ),
              ),
              Text(
                '+50 XP EACH',
                style: LandingTokens.label(fontSize: 9, color: skin.faint),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Share your code with a friend, or enter theirs after they join Ngoding Lok. The first successful referral links both accounts and rewards both coders once.',
            style: TextStyle(color: skin.sub, height: 1.45),
          ),
          const SizedBox(height: 16),
          _InviteValueRow(
            value: code ?? 'SIGN IN TO GET A CODE',
            valueColor: code == null ? skin.faint : LandingTokens.ember,
            button: CinematicOutlineButton(
              label: 'Copy',
              icon: Icons.copy,
              compact: true,
              onPressed: enabled ? onCopy : null,
            ),
          ),
          const SizedBox(height: 10),
          _InviteValueRow(
            value: inviteLink ?? 'Sign in to get your invite link',
            valueColor: inviteLink == null ? skin.faint : LandingTokens.circuit,
            fontSize: 11,
            button: CinematicOutlineButton(
              label: 'Copy Link',
              icon: Icons.link,
              compact: true,
              onPressed: enabled ? onCopyLink : null,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            enabled: enabled && !redeeming,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            style: LandingTokens.mono(fontSize: 14, color: skin.text),
            decoration: InputDecoration(
              labelText: 'Friend referral code',
              hintText: 'NGXXXXXXXX',
              labelStyle: TextStyle(color: skin.sub),
              hintStyle: TextStyle(color: skin.faint),
              filled: true,
              fillColor: skin.panelRaised,
              border: OutlineInputBorder(
                borderRadius: LandingTokens.smallRadius,
                borderSide: BorderSide(color: skin.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: LandingTokens.smallRadius,
                borderSide: BorderSide(color: skin.border),
              ),
            ),
            onSubmitted: (_) => onRedeem(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: redeeming ? 'Syncing...' : 'Add Friend +50 XP',
              icon: redeeming ? Icons.sync : Icons.person_add,
              compact: true,
              onPressed: enabled && !redeeming ? onRedeem : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps copy controls usable on a phone by stacking the action below the
/// value, while retaining the compact two-column layout on larger screens.
class _InviteValueRow extends StatelessWidget {
  final String value;
  final Color valueColor;
  final double fontSize;
  final Widget button;

  const _InviteValueRow({
    required this.value,
    required this.valueColor,
    required this.button,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final field = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NoirSkin.of(context).panelRaised,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: NoirSkin.of(context).borderStrong),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: LandingTokens.mono(fontSize: fontSize, color: valueColor),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [field, const SizedBox(height: 8), button],
          );
        }
        return Row(
          children: [
            Expanded(child: field),
            const SizedBox(width: 10),
            button,
          ],
        );
      },
    );
  }
}

class _FriendsPanel extends StatelessWidget {
  final NoirSkin skin;
  final Stream<List<FriendSummary>> friendsStream;
  final ValueChanged<FriendSummary> onOpenDetails;

  const _FriendsPanel({
    required this.skin,
    required this.friendsStream,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder<List<FriendSummary>>(
            stream: friendsStream,
            builder: (context, snapshot) {
              final friends = snapshot.data ?? const <FriendSummary>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_alt, color: LandingTokens.ember),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '// YOUR CODING CREW',
                          style: LandingTokens.label(
                            fontSize: 10,
                            color: LandingTokens.ember,
                          ),
                        ),
                      ),
                      Text(
                        '${friends.length} FRIEND${friends.length == 1 ? '' : 'S'}',
                        style: LandingTokens.label(
                          fontSize: 9,
                          color: skin.faint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (friends.isEmpty)
                    Text(
                      'No friends yet. Share your invite code to start a crew.',
                      style: TextStyle(color: skin.sub),
                    )
                  else
                    for (final friend in friends) ...[
                      _FriendRow(
                        friend: friend,
                        skin: skin,
                        onTap: () => onOpenDetails(friend),
                      ),
                      if (friend != friends.last) Divider(color: skin.border),
                    ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final FriendSummary friend;
  final NoirSkin skin;
  final VoidCallback onTap;

  const _FriendRow({
    required this.friend,
    required this.skin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: LandingTokens.circuit.withValues(alpha: 0.15),
              backgroundImage: friend.photoUrl == null
                  ? null
                  : NetworkImage(friend.photoUrl!),
              child: friend.photoUrl == null
                  ? const Icon(Icons.code, color: LandingTokens.circuit)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.displayName,
                    style: TextStyle(
                      color: skin.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    friend.email,
                    style: LandingTokens.mono(fontSize: 10, color: skin.faint),
                  ),
                ],
              ),
            ),
            Text(
              '${friend.xp} XP',
              style: LandingTokens.label(
                fontSize: 10,
                color: LandingTokens.ember,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: skin.faint),
          ],
        ),
      ),
    );
  }
}

class _DetailMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailMetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: LandingTokens.label(
              fontSize: 9,
              color: LandingTokens.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: LandingTokens.mono(
            fontSize: 12,
            color: LandingTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
