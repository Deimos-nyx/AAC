/// All raw SQL for the local database lives here so schema evolution is easy
/// to audit in one place. Every future column/table addition must be added
/// as a new `if (oldVersion < N)` migration step in [DbSchema.migrate] —
/// never by editing an existing CREATE TABLE, or existing users' databases
/// will silently keep the old shape.
class DbSchema {
  DbSchema._();

  static const int currentVersion = 1;

  static const String createProfiles = '''
    CREATE TABLE profiles (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      avatar_path TEXT,
      locale_code TEXT NOT NULL DEFAULT 'en',
      grid_size TEXT NOT NULL DEFAULT '4x4',
      button_size_scale REAL NOT NULL DEFAULT 1.0,
      button_spacing_scale REAL NOT NULL DEFAULT 1.0,
      font_scale REAL NOT NULL DEFAULT 1.0,
      high_contrast INTEGER NOT NULL DEFAULT 0,
      reduced_animation INTEGER NOT NULL DEFAULT 0,
      tts_voice_id TEXT,
      tts_rate REAL NOT NULL DEFAULT 0.5,
      tts_pitch REAL NOT NULL DEFAULT 1.0,
      tts_volume REAL NOT NULL DEFAULT 1.0,
      editing_locked INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createCategories = '''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      profile_id TEXT NOT NULL,
      name TEXT NOT NULL,
      icon_key TEXT,
      color_hex TEXT,
      sort_order INTEGER NOT NULL DEFAULT 0,
      is_system INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
    );
  ''';

  static const String createButtons = '''
    CREATE TABLE buttons (
      id TEXT PRIMARY KEY,
      profile_id TEXT NOT NULL,
      category_id TEXT,
      label TEXT NOT NULL,
      spoken_phrase TEXT,
      pronunciation_override TEXT,
      icon_key TEXT,
      image_path TEXT,
      background_color_hex TEXT,
      grid_position INTEGER,
      sort_order INTEGER NOT NULL DEFAULT 0,
      is_core INTEGER NOT NULL DEFAULT 0,
      is_folder INTEGER NOT NULL DEFAULT 0,
      folder_target_category_id TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
    );
  ''';

  static const String createSettings = '''
    CREATE TABLE app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  ''';

  static const String indexButtonsByProfile =
      'CREATE INDEX idx_buttons_profile ON buttons(profile_id);';
  static const String indexButtonsByCategory =
      'CREATE INDEX idx_buttons_category ON buttons(category_id);';
  static const String indexCategoriesByProfile =
      'CREATE INDEX idx_categories_profile ON categories(profile_id);';

  static Future<void> createAll(Future<void> Function(String sql) exec) async {
    await exec(createProfiles);
    await exec(createCategories);
    await exec(createButtons);
    await exec(createSettings);
    await exec(indexButtonsByProfile);
    await exec(indexButtonsByCategory);
    await exec(indexCategoriesByProfile);
  }

  /// Applies incremental migrations from [oldVersion] to [newVersion].
  /// Intentionally a no-op chain today since we're at version 1 — this is
  /// the seam future releases hook into so upgrading never destroys data.
  static Future<void> migrate(
    Future<void> Function(String sql) exec,
    int oldVersion,
    int newVersion,
  ) async {
    // Example for the future:
    // if (oldVersion < 2) {
    //   await exec('ALTER TABLE buttons ADD COLUMN motor_plan_locked INTEGER NOT NULL DEFAULT 0;');
    // }
  }
}
