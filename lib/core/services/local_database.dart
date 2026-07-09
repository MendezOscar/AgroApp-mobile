import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agroapp.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE IF NOT EXISTS tasks_cache (
    id TEXT PRIMARY KEY,
    assigned_to TEXT NOT NULL,
    assignee_name TEXT NOT NULL,
    created_by TEXT NOT NULL,
    creator_name TEXT NOT NULL,
    plot_id TEXT,
    plot_name TEXT,
    crop_id TEXT,
    crop_name TEXT,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT NOT NULL,
    status TEXT NOT NULL,
    task_type TEXT NOT NULL,
    due_date TEXT NOT NULL,
    completed_at TEXT,
    notes TEXT,
    created_at TEXT NOT NULL,
    synced_at TEXT NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS occurrences_cache (
    id TEXT PRIMARY KEY,
    template_id TEXT NOT NULL,
    template_title TEXT NOT NULL,
    task_type TEXT NOT NULL,
    priority TEXT NOT NULL,
    assigned_to TEXT,
    assignee_name TEXT,
    plot_name TEXT,
    crop_name TEXT,
    scheduled_date TEXT NOT NULL,
    shift TEXT NOT NULL,
    status TEXT NOT NULL,
    completed_at TEXT,
    notes TEXT,
    synced_at TEXT NOT NULL
  )
''');
    // Fincas
    await db.execute('''
    CREATE TABLE farms (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      lat REAL,
      lng REAL,
      area_ha REAL,
      country TEXT,
      region TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      synced_at TEXT NOT NULL
    )
  ''');

    // Parcelas
    await db.execute('''
    CREATE TABLE plots (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL,
      name TEXT NOT NULL,
      soil_type TEXT,
      area_ha REAL,
      notes TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      synced_at TEXT NOT NULL
    )
  ''');

    // Cultivos
    await db.execute('''
    CREATE TABLE crops (
      id TEXT PRIMARY KEY,
      plot_id TEXT NOT NULL,
      crop_type TEXT NOT NULL,
      variety TEXT,
      planted_at TEXT NOT NULL,
      estimated_harvest TEXT,
      harvested_at TEXT,
      status TEXT NOT NULL DEFAULT 'Active',
      yield_kg REAL,
      notes TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT NOT NULL
    )
  ''');

    // Riegos
    await db.execute('''
    CREATE TABLE irrigation_logs (
      id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      task_id TEXT,
      method TEXT NOT NULL,
      volume_liters REAL,
      duration_min INTEGER,
      applied_at TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT NOT NULL
    )
  ''');

    // Fertilización
    await db.execute('''
    CREATE TABLE fertilization_logs (
      id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      task_id TEXT,
      product_name TEXT NOT NULL,
      product_type TEXT,
      dose_kg_ha REAL,
      total_kg REAL,
      method TEXT,
      cost REAL,
      applied_at TEXT NOT NULL,
      next_application TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT NOT NULL
    )
  ''');

    // Labores
    await db.execute('''
    CREATE TABLE labor_logs (
      id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      task_id TEXT,
      activity_type TEXT NOT NULL,
      hours_worked REAL,
      workers_count INTEGER NOT NULL DEFAULT 1,
      cost REAL,
      performed_at TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT NOT NULL
    )
  ''');

    // Pendientes de sincronización
    await db.execute('''
    CREATE TABLE pending_sync (
      id TEXT PRIMARY KEY,
      entity_type TEXT NOT NULL,
      action TEXT NOT NULL,
      payload TEXT NOT NULL,
      created_at TEXT NOT NULL,
      attempts INTEGER NOT NULL DEFAULT 0
    )
  ''');

    // Lecturas de sensores
    await db.execute('''
    CREATE TABLE sensor_readings (
      id TEXT PRIMARY KEY,
      device_id TEXT NOT NULL,
      temperature REAL,
      humidity_air REAL,
      humidity_soil REAL,
      luminosity REAL,
      rain_mm REAL,
      ph REAL,
      ec REAL,
      recorded_at TEXT NOT NULL
    )
  ''');

    // Alertas
    await db.execute('''
    CREATE TABLE alerts (
      id TEXT PRIMARY KEY,
      alert_type TEXT NOT NULL,
      severity TEXT NOT NULL,
      message TEXT NOT NULL,
      is_read INTEGER NOT NULL DEFAULT 0,
      triggered_at TEXT NOT NULL
    )
  ''');

    // Imágenes pendientes
    await db.execute('''
    CREATE TABLE IF NOT EXISTS pending_images (
      id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      file_path TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT 'general',
      taken_at TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks_cache (
        id TEXT PRIMARY KEY,
        assigned_to TEXT NOT NULL,
        assignee_name TEXT NOT NULL,
        created_by TEXT NOT NULL,
        creator_name TEXT NOT NULL,
        plot_id TEXT,
        plot_name TEXT,
        crop_id TEXT,
        crop_name TEXT,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        task_type TEXT NOT NULL,
        due_date TEXT NOT NULL,
        completed_at TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS occurrences_cache (
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        template_title TEXT NOT NULL,
        task_type TEXT NOT NULL,
        priority TEXT NOT NULL,
        assigned_to TEXT,
        assignee_name TEXT,
        plot_name TEXT,
        crop_name TEXT,
        scheduled_date TEXT NOT NULL,
        shift TEXT NOT NULL,
        status TEXT NOT NULL,
        completed_at TEXT,
        notes TEXT,
        synced_at TEXT NOT NULL
      )
    ''');

      // Agregar tablas nuevas si no existen
      await db.execute('''
      CREATE TABLE IF NOT EXISTS irrigation_logs (
        id TEXT PRIMARY KEY,
        crop_id TEXT NOT NULL,
        method TEXT NOT NULL,
        volume_liters REAL,
        duration_min INTEGER,
        applied_at TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS fertilization_logs (
        id TEXT PRIMARY KEY,
        crop_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_type TEXT,
        dose_kg_ha REAL,
        total_kg REAL,
        method TEXT,
        cost REAL,
        applied_at TEXT NOT NULL,
        next_application TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS labor_logs (
        id TEXT PRIMARY KEY,
        crop_id TEXT NOT NULL,
        activity_type TEXT NOT NULL,
        hours_worked REAL,
        workers_count INTEGER NOT NULL DEFAULT 1,
        cost REAL,
        performed_at TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS crops (
        id TEXT PRIMARY KEY,
        plot_id TEXT NOT NULL,
        crop_type TEXT NOT NULL,
        variety TEXT,
        planted_at TEXT NOT NULL,
        estimated_harvest TEXT,
        harvested_at TEXT,
        status TEXT NOT NULL DEFAULT 'Active',
        yield_kg REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
    CREATE TABLE IF NOT EXISTS pending_images (
      id TEXT PRIMARY KEY,
      crop_id TEXT NOT NULL,
      file_path TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT 'general',
      taken_at TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE irrigation_logs ADD COLUMN task_id TEXT');
      await db
          .execute('ALTER TABLE fertilization_logs ADD COLUMN task_id TEXT');
      await db.execute('ALTER TABLE labor_logs ADD COLUMN task_id TEXT');
    }
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
