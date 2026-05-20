/// A craft_runner **project-wide** plugin that generates a grouped,
/// versioned retrofit API client aggregator (`AppApi`) from `@Api`-annotated
/// retrofit classes scattered across the project.
library;

export 'src/api_generator.dart';
export 'src/api_models.dart';
export 'src/api_scanner.dart';
export 'src/retrofit_api_plugin.dart';
export 'src/retrofit_craft_config.dart';
