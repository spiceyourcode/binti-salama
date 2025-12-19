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
        biometric_enabled INTEGER DEFAULT 0,
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

    // Security Questions Table (for PIN recovery)
    await db.execute('''
      CREATE TABLE security_questions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        question TEXT NOT NULL,
        answer_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
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
    if (oldVersion < 2) {
      // Add security questions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS security_questions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          question TEXT NOT NULL,
          answer_hash TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add biometric_enabled column to app_settings
      try {
        await db.execute('''
          ALTER TABLE app_settings 
          ADD COLUMN biometric_enabled INTEGER DEFAULT 0
        ''');
        AppLogger.info('Added biometric_enabled column to app_settings');
      } catch (e) {
        // Column might already exist, ignore error
        AppLogger.warning('Error adding biometric_enabled column: $e');
      }
    }
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
    // Try database first, fallback to JSON if unavailable or empty
    try {
      if (!kIsWeb) {
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

        if (maps.isNotEmpty) {
          return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
        }
      }
    } catch (e) {
      AppLogger.warning('Database query failed, using fallback: $e');
    }

    // Fallback: Load from JSON asset
    return await _getServicesFromJson(type: type, county: county);
  }

  /// Fallback method to load services directly from JSON asset
  Future<List<Service>> _getServicesFromJson({
    String? type,
    String? county,
  }) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/services.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> servicesJson = jsonData['services'] as List;

      List<Service> services = servicesJson
          .map((json) => Service.fromJson(json as Map<String, dynamic>))
          .toList();

      // Apply filters if provided
      if (type != null) {
        services = services.where((s) => s.type == type).toList();
      }
      if (county != null) {
        services = services.where((s) => s.county == county).toList();
      }

      AppLogger.info('Loaded ${services.length} services from JSON fallback');
      return services;
    } catch (e) {
      AppLogger.error('Failed to load services from JSON fallback', error: e);
      return [];
    }
  }

  /// Get hardcoded fallback services for offline/emergency use
  List<Service> getHardcodedFallbackServices() {
    return [
      Service(
        id: 'fallback_001',
        name: 'Mombasa County Referral Hospital - GBVRC',
        type: 'GBVRC',
        county: 'Mombasa',
        address: 'Cathedral Road, Mombasa Island',
        phoneNumber: '+254720555000',
        latitude: -4.0435,
        longitude: 39.6682,
        operatingHours: '24/7',
        servicesOffered: [
          'HIV Post-Exposure Prophylaxis (PEP)',
          'Emergency Contraception',
          'STI Treatment',
          'Psychological Counseling',
        ],
        youthFriendly: true,
      ),
      Service(
        id: 'fallback_002',
        name: 'Coast General Teaching & Referral Hospital - GBV Unit',
        type: 'GBVRC',
        county: 'Mombasa',
        address: 'Links Road, Mombasa',
        phoneNumber: '+254722200300',
        latitude: -4.0623,
        longitude: 39.6779,
        operatingHours: '24/7',
        servicesOffered: [
          '24-hour Emergency Services',
          'PEP Within 72 Hours',
          'Emergency Contraception',
          'Rape Crisis Counseling',
        ],
        youthFriendly: true,
      ),
      Service(
        id: 'fallback_003',
        name: 'Mombasa Central Police Station - GBV Desk',
        type: 'police',
        county: 'Mombasa',
        address: 'Makadara Road, Mombasa',
        phoneNumber: '+254202240000',
        latitude: -4.0496,
        longitude: 39.6626,
        operatingHours: '24/7',
        servicesOffered: [
          'Report Filing (OB Number)',
          'P3 Form Issuance',
          'Investigation',
          'Victim Protection',
        ],
        youthFriendly: false,
      ),
      Service(
        id: 'fallback_004',
        name: 'Kilifi County Referral Hospital - GBVRC',
        type: 'GBVRC',
        county: 'Kilifi',
        address: 'Hospital Road, Kilifi Town',
        phoneNumber: '+254725444555',
        latitude: -3.6309,
        longitude: 39.8509,
        operatingHours: '24/7',
        servicesOffered: [
          'Comprehensive PRC Services',
          'HIV PEP',
          'Emergency Contraception',
          'Psychological Support',
        ],
        youthFriendly: true,
      ),
      Service(
        id: 'fallback_005',
        name: 'Kwale County Referral Hospital - GBVRC',
        type: 'GBVRC',
        county: 'Kwale',
        address: 'Matuga, Kwale',
        phoneNumber: '+254720222333',
        latitude: -4.1744,
        longitude: 39.4597,
        operatingHours: '24/7',
        servicesOffered: [
          'Post-Rape Care',
          'PEP Administration',
          'Emergency Contraception',
          'Psychosocial Counseling',
        ],
        youthFriendly: true,
      ),
    ];
  }

  Future<Service?> getServiceById(String id) async {
    // Try database first
    try {
      if (!kIsWeb) {
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(
          'services',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          return Service.fromMap(maps.first);
        }
      }
    } catch (e) {
      AppLogger.warning('Database query failed for service $id: $e');
    }

    // Fallback: Search in JSON
    final services = await _getServicesFromJson();
    try {
      return services.firstWhere((s) => s.id == id);
    } catch (_) {
      // Check hardcoded fallback
      try {
        return getHardcodedFallbackServices().firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<Service>> searchServices(String query) async {
    // Try database first
    try {
      if (!kIsWeb) {
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(
          'services',
          where: 'name LIKE ? OR address LIKE ? OR type LIKE ?',
          whereArgs: ['%$query%', '%$query%', '%$query%'],
        );

        if (maps.isNotEmpty) {
          return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
        }
      }
    } catch (e) {
      AppLogger.warning('Database search failed, using fallback: $e');
    }

    // Fallback: Search in JSON
    final services = await _getServicesFromJson();
    final lowerQuery = query.toLowerCase();
    return services.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          s.address.toLowerCase().contains(lowerQuery) ||
          s.type.toLowerCase().contains(lowerQuery);
    }).toList();
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

  // Security Questions Methods
  Future<int> insertSecurityQuestion(String id, String odId, String question, String answerHash) async {
    if (kIsWeb) return 0; // Web not supported
    final db = await database;
    return await db.insert('security_questions', {
      'id': id,
      'user_id': odId,
      'question': question,
      'answer_hash': answerHash,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSecurityQuestions(String odId) async {
    if (kIsWeb) return []; // Web not supported
    final db = await database;
    return await db.query(
      'security_questions',
      where: 'user_id = ?',
      whereArgs: [odId],
    );
  }

  Future<bool> hasSecurityQuestions(String odId) async {
    if (kIsWeb) return false; // Web not supported
    final db = await database;
    final result = await db.query(
      'security_questions',
      where: 'user_id = ?',
      whereArgs: [odId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> deleteSecurityQuestions(String odId) async {
    if (kIsWeb) return; // Web not supported
    final db = await database;
    await db.delete(
      'security_questions',
      where: 'user_id = ?',
      whereArgs: [odId],
    );
  }

  Future<void> close() async {
    if (kIsWeb) return; // Web not supported
    final db = await database;
    await db.close();
  }
}
