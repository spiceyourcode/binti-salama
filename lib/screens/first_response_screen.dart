import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../services/language_provider.dart';

class FirstResponseScreen extends StatelessWidget {
  const FirstResponseScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider?>(context);
    final t = languageProvider?.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            t?.translate('first_response_guide') ?? 'First Response Guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Critical Notice
          _buildCriticalNotice(),
          const SizedBox(height: 24),

          // Steps
          _buildStep(
            number: 1,
            title: 'Get to Safety',
            icon: Icons.shield,
            color: AppConstants.primaryColor,
            description:
                'Move to a safe location immediately. If possible, call someone you trust.',
            actions: [
              'Leave the dangerous situation',
              'Go to a public place if needed',
              'Contact a trusted person',
            ],
          ),

          _buildStep(
            number: 2,
            title: 'Preserve Evidence',
            icon: Icons.warning,
            color: AppConstants.warningColor,
            description: 'This is crucial for medical and legal reasons.',
            actions: [
              'DO NOT wash or bathe',
              'DO NOT change clothes',
              'DO NOT eat, drink, or brush teeth',
              'DO NOT use the bathroom if possible',
              'DO NOT comb hair',
              'Keep clothes in a paper bag (not plastic)',
            ],
          ),

          _buildStep(
            number: 3,
            title: 'Seek Medical Care IMMEDIATELY',
            icon: Icons.local_hospital,
            color: AppConstants.emergencyRed,
            description:
                'Go to the nearest GBVRC within 72 hours for PEP (HIV prevention).',
            actions: [
              'Request HIV Post-Exposure Prophylaxis (PEP) - within 72 hours',
              'Request emergency contraception - within 120 hours',
              'Get treatment for injuries',
              'Request forensic examination',
              'Get tested for STIs',
              'Request counseling services',
            ],
          ),

          _buildStep(
            number: 4,
            title: 'Report to Police',
            icon: Icons.local_police,
            color: AppConstants.secondaryColor,
            description:
                'File a report at the GBV desk. You have the right to be treated with respect.',
            actions: [
              'Go to the nearest police GBV desk',
              'Ask for an OB (Occurrence Book) number',
              'Request a P3 form (medical-legal form)',
              'Get a copy of your statement',
              'Note the officer\'s name and badge number',
            ],
          ),

          _buildStep(
            number: 5,
            title: 'Document Everything',
            icon: Icons.edit_note,
            color: AppConstants.accentColor,
            description:
                'Write down what happened while it\'s still fresh in your mind.',
            actions: [
              'Date and time of incident',
              'Location details',
              'Description of perpetrator',
              'Names of witnesses',
              'What was said and done',
              'Use the Incident Log in this app',
            ],
          ),

          _buildStep(
            number: 6,
            title: 'Seek Support',
            icon: Icons.favorite,
            color: AppConstants.successColor,
            description:
                'You don\'t have to go through this alone. Help is available.',
            actions: [
              'Contact a counselor',
              'Talk to a trusted person',
              'Join a support group',
              'Use the resources in this app',
              'Remember: It\'s not your fault',
            ],
          ),

          const SizedBox(height: 24),

          // Emergency Hotlines
          _buildEmergencyHotlines(context),

          const SizedBox(height: 24),

          // Important Rights
          _buildImportantRights(),
        ],
      ),
    );
  }

  Widget _buildCriticalNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.emergencyRed.withOpacity(0.1),
        border: Border.all(color: AppConstants.emergencyRed, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.access_time_filled,
            size: 48,
            color: AppConstants.emergencyRed,
          ),
          SizedBox(height: 12),
          Text(
            'CRITICAL TIME WINDOW',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.emergencyRed,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'You have 72 hours (3 days) to start HIV Post-Exposure Prophylaxis (PEP) treatment.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'The sooner you get medical care, the better. PEP is most effective when started within the first few hours.',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required List<String> actions,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 32),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ...actions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          action,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyHotlines(BuildContext context) {
    return Card(
      color: AppConstants.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone, color: AppConstants.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Emergency Hotlines',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildHotlineRow(
              'National Emergency',
              AppConstants.nationalEmergencyNumber,
              'Available 24/7',
            ),
            _buildHotlineRow(
              'Police Emergency',
              AppConstants.policeEmergencyNumber,
              'Available 24/7',
            ),
            _buildHotlineRow(
              'Gender Violence Hotline',
              AppConstants.genderViolenceHotline,
              'Free & confidential',
            ),
            _buildHotlineRow(
              'Child Helpline Kenya',
              AppConstants.childHelplineKenya,
              'For children and youth',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlineRow(String name, String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _makePhoneCall(number),
            icon: const Icon(Icons.phone, size: 16),
            label: Text(number),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantRights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.balance, color: AppConstants.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Know Your Rights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildRightItem(
                'You have the right to medical treatment regardless of ability to pay'),
            _buildRightItem(
                'You have the right to report or not report to police - it\'s your choice'),
            _buildRightItem(
                'You have the right to be treated with dignity and respect'),
            _buildRightItem(
                'You have the right to privacy and confidentiality'),
            _buildRightItem(
                'You have the right to counseling and support services'),
            _buildRightItem(
                'You have the right to refuse any unwanted examination or procedure'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: AppConstants.accentColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remember: What happened is NOT your fault. You deserve support and care.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: AppConstants.successColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
