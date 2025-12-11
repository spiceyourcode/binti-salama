import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../services/authentication_service.dart';
import '../services/incident_log_service.dart';
import '../services/language_provider.dart';
import '../models/incident_log.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class IncidentLogScreen extends StatefulWidget {
  const IncidentLogScreen({super.key});

  @override
  State<IncidentLogScreen> createState() => _IncidentLogScreenState();
}

class _IncidentLogScreenState extends State<IncidentLogScreen> {
  List<IncidentLog> _incidents = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthenticationService>(
        context,
        listen: false,
      );
      final incidentService = Provider.of<IncidentLogService>(
        context,
        listen: false,
      );

      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        _incidents = await incidentService.getIncidentLogs(userId);
      }
    } catch (e) {
      _showError('Failed to load incidents: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchIncidents(String query) async {
    if (query.isEmpty) {
      await _loadIncidents();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthenticationService>(
        context,
        listen: false,
      );
      final incidentService = Provider.of<IncidentLogService>(
        context,
        listen: false,
      );

      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        _incidents = await incidentService.searchIncidentLogs(userId, query);
      }
    } catch (e) {
      _showError('Search failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider?>(context);
    final t = languageProvider?.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t?.translate('incident_log') ?? 'Incident Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(t),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _incidents.isEmpty
              ? _buildEmptyState()
              : _buildIncidentList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIncidentForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final languageProvider =
        Provider.of<LanguageProvider?>(context, listen: false);
    final t = languageProvider?.t;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              t?.translate('no_incidents_recorded') ?? 'No incidents recorded',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t?.translate('tap_plus_document') ??
                  'Tap the + button to document an incident',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _incidents.length,
      itemBuilder: (context, index) {
        final incident = _incidents[index];
        return _buildIncidentCard(incident);
      },
    );
  }

  Widget _buildIncidentCard(IncidentLog incident) {
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showIncidentDetails(incident),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(incident.incidentDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (incident.locationAddress != null)
                          Text(
                            incident.locationAddress!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareIncident(incident),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                incident.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (incident.policeReportFiled)
                    _buildBadge(
                      Icons.local_police,
                      'Police Report',
                      AppConstants.secondaryColor,
                    ),
                  if (incident.evidencePreserved)
                    _buildBadge(
                      Icons.inventory,
                      'Evidence',
                      AppConstants.successColor,
                    ),
                  if (incident.medicalFacilityVisited != null)
                    _buildBadge(
                      Icons.local_hospital,
                      'Medical',
                      AppConstants.accentColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showIncidentDetails(IncidentLog incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            _buildIncidentDetailsSheet(incident, scrollController),
      ),
    );
  }

  Widget _buildIncidentDetailsSheet(
    IncidentLog incident,
    ScrollController scrollController,
  ) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a');

    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            children: [
              const Text(
                'Incident Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pop(context);
                  _showIncidentForm(incident: incident);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(incident),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailItem(
            'Date & Time',
            dateFormat.format(incident.incidentDate),
          ),
          if (incident.locationAddress != null)
            _buildDetailItem('Location', incident.locationAddress!),
          _buildDetailItem('Description', incident.description),
          if (incident.perpetratorDescription != null)
            _buildDetailItem('Perpetrator', incident.perpetratorDescription!),
          if (incident.witnesses != null)
            _buildDetailItem('Witnesses', incident.witnesses!),
          if (incident.actionsTaken != null)
            _buildDetailItem('Actions Taken', incident.actionsTaken!),
          if (incident.medicalFacilityVisited != null)
            _buildDetailItem(
              'Medical Facility',
              incident.medicalFacilityVisited!,
            ),
          if (incident.obNumber != null)
            _buildDetailItem('OB Number', incident.obNumber!),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _shareIncident(incident),
            icon: const Icon(Icons.share),
            label: const Text('Export Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _shareIncident(IncidentLog incident) async {
    final incidentService = Provider.of<IncidentLogService>(
      context,
      listen: false,
    );
    final report = incidentService.exportIncidentLog(incident);
    // Using share_plus package
    await Share.share(report, subject: 'Confidential Incident Report');
  }

  void _confirmDelete(IncidentLog incident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Incident'),
        content: const Text(
          'Are you sure you want to delete this incident log? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              await _deleteIncident(incident);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIncident(IncidentLog incident) async {
    try {
      final incidentService = Provider.of<IncidentLogService>(
        context,
        listen: false,
      );
      await incidentService.deleteIncidentLog(incident.id);
      await _loadIncidents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident deleted'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to delete incident: $e');
    }
  }

  void _showSearchDialog(dynamic t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Incidents'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _searchIncidents(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
              _loadIncidents();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchIncidents(_searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showIncidentForm({IncidentLog? incident}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncidentFormScreen(incident: incident)),
    ).then((_) => _loadIncidents());
  }
}

// Separate screen for incident form
class IncidentFormScreen extends StatefulWidget {
  final IncidentLog? incident;

  const IncidentFormScreen({super.key, this.incident});

  @override
  State<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends State<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _incidentDate;
  final _descriptionController = TextEditingController();
  final _perpetratorController = TextEditingController();
  final _witnessesController = TextEditingController();
  final _actionsTakenController = TextEditingController();
  final _medicalFacilityController = TextEditingController();
  final _obNumberController = TextEditingController();
  bool _evidencePreserved = false;
  bool _policeReportFiled = false;
  bool _isLoading = false;
  Position? _location;

  @override
  void initState() {
    super.initState();
    if (widget.incident != null) {
      _incidentDate = widget.incident!.incidentDate;
      _descriptionController.text = widget.incident!.description;
      _perpetratorController.text =
          widget.incident!.perpetratorDescription ?? '';
      _witnessesController.text = widget.incident!.witnesses ?? '';
      _actionsTakenController.text = widget.incident!.actionsTaken ?? '';
      _medicalFacilityController.text =
          widget.incident!.medicalFacilityVisited ?? '';
      _obNumberController.text = widget.incident!.obNumber ?? '';
      _evidencePreserved = widget.incident!.evidencePreserved;
      _policeReportFiled = widget.incident!.policeReportFiled;
    } else {
      _incidentDate = DateTime.now();
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _perpetratorController.dispose();
    _witnessesController.dispose();
    _actionsTakenController.dispose();
    _medicalFacilityController.dispose();
    _obNumberController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _location = await Geolocator.getCurrentPosition();
    } catch (e) {
      AppLogger.warning('Could not get location: $e');
    }
  }

  Future<void> _saveIncident() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthenticationService>(
        context,
        listen: false,
      );
      final incidentService = Provider.of<IncidentLogService>(
        context,
        listen: false,
      );

      final userId = await authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      if (widget.incident == null) {
        // Create new incident
        await incidentService.createIncidentLog(
          userId: userId,
          incidentDate: _incidentDate,
          description: _descriptionController.text,
          location: _location,
          perpetratorDescription: _perpetratorController.text.isNotEmpty
              ? _perpetratorController.text
              : null,
          witnesses: _witnessesController.text.isNotEmpty
              ? _witnessesController.text
              : null,
          actionsTaken: _actionsTakenController.text.isNotEmpty
              ? _actionsTakenController.text
              : null,
          medicalFacilityVisited: _medicalFacilityController.text.isNotEmpty
              ? _medicalFacilityController.text
              : null,
          evidencePreserved: _evidencePreserved,
          policeReportFiled: _policeReportFiled,
          obNumber: _obNumberController.text.isNotEmpty
              ? _obNumberController.text
              : null,
        );
      } else {
        // Update existing incident
        final updated = widget.incident!.copyWith(
          incidentDate: _incidentDate,
          description: _descriptionController.text,
          perpetratorDescription: _perpetratorController.text.isNotEmpty
              ? _perpetratorController.text
              : null,
          witnesses: _witnessesController.text.isNotEmpty
              ? _witnessesController.text
              : null,
          actionsTaken: _actionsTakenController.text.isNotEmpty
              ? _actionsTakenController.text
              : null,
          medicalFacilityVisited: _medicalFacilityController.text.isNotEmpty
              ? _medicalFacilityController.text
              : null,
          evidencePreserved: _evidencePreserved,
          policeReportFiled: _policeReportFiled,
          obNumber: _obNumberController.text.isNotEmpty
              ? _obNumberController.text
              : null,
        );
        await incidentService.updateIncidentLog(updated);
      }

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident saved successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save incident: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incident == null ? 'New Incident' : 'Edit Incident'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date selector
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date of Incident'),
              subtitle: Text(
                DateFormat('MMM d, yyyy h:mm a').format(_incidentDate),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _incidentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_incidentDate),
                  );
                  if (time != null && mounted) {
                    setState(() {
                      _incidentDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'What Happened *',
                hintText: 'Describe the incident in detail...',
              ),
              maxLines: 5,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Perpetrator
            TextFormField(
              controller: _perpetratorController,
              decoration: const InputDecoration(
                labelText: 'Perpetrator Description',
                hintText: 'Physical description, name if known...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Witnesses
            TextFormField(
              controller: _witnessesController,
              decoration: const InputDecoration(
                labelText: 'Witnesses',
                hintText: 'Names and contact information...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Actions Taken
            TextFormField(
              controller: _actionsTakenController,
              decoration: const InputDecoration(
                labelText: 'Actions Taken',
                hintText: 'What steps have you taken so far...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Medical Facility
            TextFormField(
              controller: _medicalFacilityController,
              decoration: const InputDecoration(
                labelText: 'Medical Facility Visited',
                hintText: 'Name of hospital or clinic...',
              ),
            ),
            const SizedBox(height: 16),

            // Checkboxes
            CheckboxListTile(
              title: const Text('Evidence Preserved'),
              subtitle: const Text('Did not wash, change clothes, etc.'),
              value: _evidencePreserved,
              onChanged: (value) =>
                  setState(() => _evidencePreserved = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Police Report Filed'),
              subtitle: const Text('Reported to police GBV desk'),
              value: _policeReportFiled,
              onChanged: (value) =>
                  setState(() => _policeReportFiled = value ?? false),
            ),

            // OB Number (if police report filed)
            if (_policeReportFiled) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _obNumberController,
                decoration: const InputDecoration(
                  labelText: 'OB Number',
                  hintText: 'Occurrence Book number from police',
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveIncident,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Incident'),
            ),
          ],
        ),
      ),
    );
  }
}
