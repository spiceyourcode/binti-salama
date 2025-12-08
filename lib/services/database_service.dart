import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/trusted_contact.dart';
import '../models/service.dart';
import '../models/incident_log.dart';
import '../models/app_settings.dart';
import '../models/panic_alert.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    // Skip database initialization on web for now
    // Web will use in-memory storage or IndexedDB alternative
    if (kIsWeb) {
      AppLogger.warning('Running on web - database features limited');
      return;
    }
    await database;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite database is not supported on web. '
        'Please use the mobile app for full functionality.',
      );
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        pin_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_login TEXT NOT NULL
      )
    ''');

    // Trusted Contacts Table
    await db.execute('''
      CREATE TABLE trusted_contacts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        contact_type TEXT NOT NULL,
        is_emergency INTEGER DEFAULT 1,
        custom_alert_message TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Incident Logs Table
    await db.execute('''
      CREATE TABLE incident_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        incident_date TEXT NOT NULL,
        location_latitude REAL,
        location_longitude REAL,
        location_address TEXT,
        description TEXT NOT NULL,
        perpetrator_description TEXT,
        witnesses TEXT,
        actions_taken TEXT,
        medical_facility_visited TEXT,
        evidence_preserved INTEGER DEFAULT 0,
        police_report_filed INTEGER DEFAULT 0,
        ob_number TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // App Settings Table
    await db.execute('''
      CREATE TABLE app_settings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language TEXT DEFAULT 'en',
        panic_trigger_type TEXT DEFAULT 'shake',
        notifications_enabled INTEGER DEFAULT 0,
        disguise_mode INTEGER DEFAULT 0,
        auto_lock_minutes INTEGER DEFAULT 5,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Services Table (Static Data)
    await db.execute('''
      CREATE TABLE services (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        county TEXT NOT NULL,
        address TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        operating_hours TEXT NOT NULL,
        services_offered TEXT NOT NULL,
        youth_friendly INTEGER DEFAULT 0,
        website TEXT
      )
    ''');

    // Panic Alerts History Table
    await db.execute('''
      CREATE TABLE panic_alerts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        triggered_at TEXT NOT NULL,
        location_latitude REAL,
        location_longitude REAL,
        contacts_alerted INTEGER NOT NULL,
        success INTEGER NOT NULL,
        error_message TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for performance
    await db.execute(
      'CREATE INDEX idx_trusted_contacts_user ON trusted_contacts(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_incident_logs_user ON incident_logs(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_app_settings_user ON app_settings(user_id)',
    );
    await db.execute('CREATE INDEX idx_services_county ON services(county)');
    await db.execute('CREATE INDEX idx_services_type ON services(type)');
    await db.execute(
      'CREATE INDEX idx_panic_alerts_user ON panic_alerts(user_id)',
    );

    // Load initial services data
    await _loadInitialServices(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here when version increases
  }

  Future<void> _loadInitialServices(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/services.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> servicesJson = jsonData['services'] as List;

      final batch = db.batch();
      for (var serviceJson in servicesJson) {
        final service = Service.fromJson(serviceJson as Map<String, dynamic>);
        batch.insert('services', service.toMap());
      }
      await batch.commit(noResult: true);
    } catch (e) {
      AppLogger.error('Error loading initial services', error: e);
    }
  }

  // User Methods
  Future<int> insertUser(User user) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(String id) async {
    if (kIsWeb) return null; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> updateUser(User user) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Trusted Contacts Methods
  Future<int> insertTrustedContact(TrustedContact contact) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.insert('trusted_contacts', contact.toMap());
  }

  Future<List<TrustedContact>> getTrustedContacts(String userId) async {
    if (kIsWeb) return []; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trusted_contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => TrustedContact.fromMap(maps[i]));
  }

  Future<List<TrustedContact>> getEmergencyContacts(String userId) async {
    if (kIsWeb) return []; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trusted_contacts',
      where: 'user_id = ? AND is_emergency = 1',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => TrustedContact.fromMap(maps[i]));
  }

  Future<int> updateTrustedContact(TrustedContact contact) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.update(
      'trusted_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteTrustedContact(String id) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.delete(
      'trusted_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Services Methods
  Future<List<Service>> getServices({String? type, String? county}) async {
    if (kIsWeb) return []; // Web not supported
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (type != null && county != null) {
      where = 'type = ? AND county = ?';
      whereArgs = [type, county];
    } else if (type != null) {
      where = 'type = ?';
      whereArgs = [type];
    } else if (county != null) {
      where = 'county = ?';
      whereArgs = [county];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: where,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<Service?> getServiceById(String id) async {
    if (kIsWeb) return null; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Service.fromMap(maps.first);
  }

  Future<List<Service>> searchServices(String query) async {
    if (kIsWeb) return []; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'name LIKE ? OR address LIKE ? OR type LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  // Incident Logs Methods
  Future<int> insertIncidentLog(IncidentLog log) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.insert('incident_logs', log.toMap());
  }

  Future<List<IncidentLog>> getIncidentLogs(String userId) async {
    if (kIsWeb) return []; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incident_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'incident_date DESC',
    );

    return List.generate(maps.length, (i) => IncidentLog.fromMap(maps[i]));
  }

  Future<IncidentLog?> getIncidentLogById(String id) async {
    if (kIsWeb) return null; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incident_logs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return IncidentLog.fromMap(maps.first);
  }

  Future<int> updateIncidentLog(IncidentLog log) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.update(
      'incident_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteIncidentLog(String id) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.delete('incident_logs', where: 'id = ?', whereArgs: [id]);
  }

  // App Settings Methods
  Future<int> insertAppSettings(AppSettings settings) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.insert('app_settings', settings.toMap());
  }

  Future<AppSettings?> getAppSettings(String userId) async {
    if (kIsWeb) return null; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return AppSettings.fromMap(maps.first);
  }

  Future<int> updateAppSettings(AppSettings settings) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.update(
      'app_settings',
      settings.toMap(),
      where: 'user_id = ?',
      whereArgs: [settings.userId],
    );
  }

  // Panic Alerts Methods
  Future<int> insertPanicAlert(PanicAlert alert) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.insert('panic_alerts', alert.toMap());
  }

  Future<List<PanicAlert>> getPanicAlerts(String userId) async {
    if (kIsWeb) return []; // Web not supported
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'panic_alerts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'triggered_at DESC',
      limit: 50,
    );

    return List.generate(maps.length, (i) => PanicAlert.fromMap(maps[i]));
  }

  // Database Maintenance
  Future<void> clearAllData(String userId) async {
    if (kIsWeb) return; // Web not supported
    final db = await database;
    await db.delete(
      'trusted_contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.delete('incident_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('panic_alerts', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('app_settings', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    if (kIsWeb) return; // Web not supported
    final db = await database;
    await db.close();
  }
}
