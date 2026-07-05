import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/session/leaderboard_entry.dart';
import '../../core/session/user_session.dart';
import '../theme/doodle.dart';
import '../widgets/leaderboard_panel.dart';
import '../widgets/module_card.dart';
import '../widgets/profile_card.dart';

class DashboardScreen extends StatefulWidget {
  final UserSession user;
  final List<LeaderboardEntry> leaderboard;
  final VoidCallback onLogout;
  final void Function(CurriculumModule module) onLaunchModule;

  /// Returns to the Home hub. Optional so the screen still works standalone.
  final VoidCallback? onBack;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.leaderboard,
    required this.onLogout,
    required this.onLaunchModule,
    this.onBack,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
        parent: _entrance,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodlePalette.dark,
      body: DoodleDotBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.onBack != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: widget.onBack,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          DoodleIconBadge(
                            icon: Icons.arrow_back,
                            color: DoodlePalette.white,
                            iconColor: Colors.black,
                            size: 38,
                            iconSize: 18,
                            borderRadius: 12,
                          ),
                          SizedBox(width: 8),
                          Text('Back to Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                final sidebar = DoodleFadeSlide(
                  animation: _interval(0.0, 0.50),
                  yOffset: 24,
                  child: SizedBox(
                    width: isWide ? 300 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileCard(user: widget.user, onLogout: widget.onLogout),
                        const SizedBox(height: 16),
                        LeaderboardPanel(
                          entries: widget.leaderboard,
                          currentUserName: widget.user.displayName,
                        ),
                      ],
                    ),
                  ),
                );

                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DoodleFadeSlide(
                      animation: _interval(0.10, 0.55),
                      yOffset: 20,
                      child: const Text(
                        'Active Curriculum Maps',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DoodleFadeSlide(
                      animation: _interval(0.15, 0.60),
                      yOffset: 16,
                      child: const Text(
                        'Select an interactive module to continue your programming journey.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Curriculum.modules.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisExtent: 240,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final module = Curriculum.modules[index];
                        return _StaggeredCard(
                          index: index,
                          parentController: _entrance,
                          child: ModuleCard(
                            module: module,
                            isCompleted: widget.user.completedModuleIds.contains(module.id),
                            onLaunch: () => widget.onLaunchModule(module),
                          ),
                        );
                      },
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sidebar,
                      const SizedBox(width: 16),
                      Expanded(child: SingleChildScrollView(child: content)),
                    ],
                  );
                }
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [sidebar, const SizedBox(height: 16), content],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Staggered fade-in card for the dashboard grid.
class _StaggeredCard extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationController parentController;

  const _StaggeredCard({
    required this.child,
    required this.index,
    required this.parentController,
  });

  @override
  Widget build(BuildContext context) {
    final start = (0.25 + index * 0.12).clamp(0.0, 0.85);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return DoodleFadeSlide(
      animation: CurvedAnimation(
        parent: parentController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
      yOffset: 36,
      child: child,
    );
  }
}
