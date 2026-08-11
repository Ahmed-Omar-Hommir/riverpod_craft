import 'src/project_wide_plugin.dart';
import 'src/project_wide_processor.dart';

/// Owns the registered [ProjectWideCraftPlugin]s and their processor.
///
/// craft_runner is a generic orchestrator: it has no built-in generators.
/// Plugins are registered either from `craft_runner.yaml` (via the CLI's
/// entry-script handoff) or programmatically through
/// [registerProjectWidePlugins] / `runWithPlugins`.
class FileProcessor {
  /// The processor for project-wide plugins. Empty until
  /// [registerProjectWidePlugins] is called.
  static ProjectWideProcessor _projectWideProcessor =
      ProjectWideProcessor(const []);

  /// True once any plugin has been registered in-process via
  /// [registerProjectWidePlugins]. The CLI consults this to skip the
  /// yaml-driven handoff when the caller already wired plugins through
  /// `runWithPlugins(...)` from a custom entry script.
  static bool _pluginsRegistered = false;
  static bool get hasRegisteredPlugins => _pluginsRegistered;

  /// Register project-wide plugins ([ProjectWideCraftPlugin]).
  ///
  /// Each collects across every Dart source file under its declared
  /// `sourceRoots` and emits standalone generated files.
  static void registerProjectWidePlugins(
    List<ProjectWideCraftPlugin> plugins,
  ) {
    _projectWideProcessor = ProjectWideProcessor(plugins);
    if (plugins.isNotEmpty) _pluginsRegistered = true;
  }

  /// The active project-wide processor.
  static ProjectWideProcessor get projectWideProcessor => _projectWideProcessor;
}
