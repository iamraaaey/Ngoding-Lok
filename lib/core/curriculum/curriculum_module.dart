import 'language_track.dart';
import 'module_config.dart';
import 'module_type.dart';

/// A single playable lesson in the curriculum: which engine it runs on
/// ([type]/[config]), how it's presented ([title]/[description]/[hint]),
/// its track-local display order ([trackOrder]), and its starting script
/// ([initialCode]).
class CurriculumModule {
  final String id;
  final ModuleType type;
  final LanguageTrack track;
  final int trackOrder;
  final String title;
  final String description;
  final int xpReward;
  final String hint;
  final ModuleConfig config;
  final String initialCode;

  const CurriculumModule({
    required this.id,
    required this.type,
    required this.track,
    required this.trackOrder,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.hint,
    required this.config,
    required this.initialCode,
  });
}
