import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/incident_log.dart';
import 'database_service.dart';

class IncidentLogService {
  final DatabaseService databaseService;

  IncidentLogService({required this.databaseService});

  /// Create a new incident log
  Future<String> createIncidentLog({
    required String userId,
    required DateTime incidentDate,
    required String description,
    Position? location,
    String? perpetratorDescription,
    String? witnesses,
    String? actionsTaken,
    String? medicalFacilityVisited,
    bool evidencePreserved = false,
    bool policeReportFiled = false,
    String? obNumber,
  }) async {
    final id = const Uuid().v4();
    String? locationAddress;

    // Get address from coordinates if location is provided
    if (location != null) {
      try {
        locationAddress = await _getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
      } catch (e) {
        print('Failed to get address: $e');
      }
    }

    final incident = IncidentLog(
      id: id,
      userId: userId,
      incidentDate: incidentDate,
      latitude: location?.latitude,
      longitude: location?.longitude,
      locationAddress: locationAddress,
      description: description,
      perpetratorDescription: perpetratorDescription,
      witnesses: witnesses,
      actionsTaken: actionsTaken,
      medicalFacilityVisited: medicalFacilityVisited,
      evidencePreserved: evidencePreserved,
      policeReportFiled: policeReportFiled,
      obNumber: obNumber,
    );

    await databaseService.insertIncidentLog(incident);

    return id;
  }

  /// Get all incident logs for a user
  Future<List<IncidentLog>> getIncidentLogs(String userId) async {
    return await databaseService.getIncidentLogs(userId);
  }

  /// Get a specific incident log by ID
  Future<IncidentLog?> getIncidentLogById(String incidentId) async {
    return await databaseService.getIncidentLogById(incidentId);
  }

  /// Update an existing incident log
  Future<void> updateIncidentLog(IncidentLog log) async {
    final updatedLog = log.copyWith(updatedAt: DateTime.now());
    await databaseService.updateIncidentLog(updatedLog);
  }

  /// Delete an incident log
  Future<void> deleteIncidentLog(String incidentId) async {
    await databaseService.deleteIncidentLog(incidentId);
  }

  /// Search incident logs by query
  Future<List<IncidentLog>> searchIncidentLogs(
    String userId,
    String query,
  ) async {
    final logs = await getIncidentLogs(userId);
    final queryLower = query.toLowerCase();

    return logs.where((log) {
      return log.description.toLowerCase().contains(queryLower) ||
          (log.perpetratorDescription?.toLowerCase().contains(queryLower) ?? false) ||
          (log.witnesses?.toLowerCase().contains(queryLower) ?? false) ||
          (log.locationAddress?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  /// Export incident log as formatted text
  String exportIncidentLog(IncidentLog incident) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a');
    
    return '''
═══════════════════════════════════════════════════
        CONFIDENTIAL INCIDENT REPORT
═══════════════════════════════════════════════════

Generated: ${dateFormat.format(DateTime.now())}
Report ID: ${incident.id}

───────────────────────────────────────────────────
INCIDENT DETAILS
───────────────────────────────────────────────────

Date & Time: ${dateFormat.format(incident.incidentDate)}

Location: ${incident.locationAddress ?? 'Not recorded'}
${incident.latitude != null && incident.longitude != null ? 'GPS Coordinates: ${incident.latitude}, ${incident.longitude}' : ''}

───────────────────────────────────────────────────
DESCRIPTION OF INCIDENT
───────────────────────────────────────────────────

${incident.description}

───────────────────────────────────────────────────
PERPETRATOR INFORMATION
───────────────────────────────────────────────────

${incident.perpetratorDescription ?? 'Not provided'}

───────────────────────────────────────────────────
WITNESSES
───────────────────────────────────────────────────

${incident.witnesses ?? 'None recorded'}

───────────────────────────────────────────────────
ACTIONS TAKEN
───────────────────────────────────────────────────

${incident.actionsTaken ?? 'None recorded'}

───────────────────────────────────────────────────
MEDICAL CARE
───────────────────────────────────────────────────

Medical Facility Visited: ${incident.medicalFacilityVisited ?? 'Not sought'}
Evidence Preserved: ${incident.evidencePreserved ? 'Yes' : 'No'}

───────────────────────────────────────────────────
LEGAL REPORTING
───────────────────────────────────────────────────

Police Report Filed: ${incident.policeReportFiled ? 'Yes' : 'No'}
OB Number: ${incident.obNumber ?? 'Not obtained'}

───────────────────────────────────────────────────

This document is strictly confidential and intended 
for legal, medical, or support purposes only.

Generated by Binti Salama - Safe Girl App

═══════════════════════════════════════════════════
''';
  }

  /// Get address from coordinates using reverse geocoding
  Future<String> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        return addressParts.join(', ');
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    
    return 'Lat: ${lat.toStringAsFixed(6)}, Lon: ${lon.toStringAsFixed(6)}';
  }

  /// Get incident logs count for user
  Future<int> getIncidentLogsCount(String userId) async {
    final logs = await getIncidentLogs(userId);
    return logs.length;
  }

  /// Get recent incident logs (last N days)
  Future<List<IncidentLog>> getRecentIncidentLogs(
    String userId,
    int days,
  ) async {
    final logs = await getIncidentLogs(userId);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return logs.where((log) {
      return log.incidentDate.isAfter(cutoffDate);
    }).toList();
  }

  /// Check if within critical PEP window (72 hours)
  bool isWithinPEPWindow(DateTime incidentDate) {
    final now = DateTime.now();
    final hoursSince = now.difference(incidentDate).inHours;
    return hoursSince <= 72;
  }

  /// Check if within emergency contraception window (120 hours)
  bool isWithinECWindow(DateTime incidentDate) {
    final now = DateTime.now();
    final hoursSince = now.difference(incidentDate).inHours;
    return hoursSince <= 120;
  }

  /// Get time remaining in PEP window
  String getPEPTimeRemaining(DateTime incidentDate) {
    final now = DateTime.now();
    final hoursSince = now.difference(incidentDate).inHours;
    final hoursRemaining = 72 - hoursSince;

    if (hoursRemaining <= 0) {
      return 'PEP window expired';
    }

    return '$hoursRemaining hours remaining for PEP';
  }
}

