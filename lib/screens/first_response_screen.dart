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
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t?.translate('first_response_guide') ??
                            'First Response Guide',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Step-by-step support',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Critical Time Window
                _buildCriticalTimeWindow(),
                const SizedBox(height: 16),

                // You Are Not Alone Card
                _buildSupportCard(),
                const SizedBox(height: 24),

                // Steps Header
                const Text(
                  'Follow These Steps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Steps
                _buildStep(
                  number: 1,
                  title: 'Get to Safety',
                  icon: Icons.shield,
                  color: AppConstants.primaryColor,
                  description:
                      'Your immediate safety is the top priority',
                  actions: [
                    'Move to a safe location away from the perpetrator',
                    'Call someone you trust or use the panic button',
                    'Lock doors and windows if you\'re at home',
                  ],
                ),

                _buildStep(
                  number: 2,
                  title: 'Preserve Evidence',
                  icon: Icons.warning,
                  color: AppConstants.warningColor,
                  description:
                      'If possible, preserve evidence for medical examination',
                  actions: [
                    'Try not to shower, bathe, or wash if possible',
                    'Don\'t change clothes - bring them in a paper bag',
                    'Keep any torn clothing or other physical evidence',
                    'Don\'t brush teeth, eat, or drink if oral contact occurred',
                  ],
                  note:
                      'Your health comes first. If you need to shower or change for your wellbeing, that\'s okay.',
                ),

                _buildStep(
                  number: 3,
                  title: 'Seek Medical Care',
                  icon: Icons.local_hospital,
                  color: AppConstants.emergencyRed,
                  description:
                      'Get immediate medical attention at a GBVRC or hospital',
                  actions: [
                    'Get PEP (HIV prevention) within 72 hours',
                    'Get emergency contraception if needed',
                    'Get treatment for any injuries',
                    'Request STI testing and prophylaxis',
                    'Medical evidence will be collected if you consent',
                  ],
                  actionLink: 'Use Find Services to locate the nearest GBVRC or hospital.',
                ),

                _buildStep(
                  number: 4,
                  title: 'Report to Police',
                  icon: Icons.local_police,
                  color: AppConstants.secondaryColor,
                  description:
                      'Reporting is your choice - you decide when you\'re ready',
                  actions: [
                    'Go to the nearest police station or call 112',
                    'File an Occurrence Book (OB) report',
                    'Get a P3 form for medical examination',
                    'Keep your OB number for reference',
                  ],
                  note:
                      'You can report at any time. Don\'t feel pressured if you\'re not ready.',
                ),

                _buildStep(
                  number: 5,
                  title: 'Document Everything',
                  icon: Icons.edit_note,
                  color: AppConstants.accentColor,
                  description:
                      'Keep records of what happened and actions taken',
                  actions: [
                    'Write down details while they\'re fresh in your memory',
                    'Use the Incident Log feature in this app',
                    'Keep copies of medical reports and police documents',
                    'Note names of people who helped you',
                  ],
                  note:
                      'Your records are encrypted and stored securely on your device only.',
                ),

                _buildStep(
                  number: 6,
                  title: 'Seek Support',
                  icon: Icons.favorite,
                  color: AppConstants.successColor,
                  description:
                      'You don\'t have to go through this alone',
                  actions: [
                    'Talk to someone you trust - family, friend, or counselor',
                    'Contact a support organization or helpline',
                    'Consider professional counseling or therapy',
                    'Join a support group if you feel comfortable',
                  ],
                ),

                const SizedBox(height: 24),

                // Emergency Hotlines
                _buildEmergencyHotlines(context),

                const SizedBox(height: 24),

                // Important Rights
                _buildImportantRights(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalTimeWindow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.emergencyRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_filled,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'CRITICAL TIME WINDOW',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Text(
                  '72 HOURS FOR PEP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Post-Exposure Prophylaxis (PEP) prevents HIV infection but must be started within 72 hours of assault.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Emergency contraception is most effective within 72 hours. Medical evidence collection is best done within 72 hours.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You Are Not Alone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'What happened to you is not your fault. These steps will help you stay safe, get medical care, and access support. Take things one step at a time.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
    String? note,
    String? actionLink,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                color: AppConstants.textSecondaryColor,
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
            if (note != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        note,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (actionLink != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionLink,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyHotlines(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.phone, color: AppConstants.textPrimaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              'Emergency Hotlines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Available 24/7 for immediate support',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildHotlineRow(
          'Gender Violence Hotline',
          AppConstants.genderViolenceHotline,
          'Free confidential support',
          AppConstants.successColor,
        ),
        const SizedBox(height: 12),
        _buildHotlineRow(
          'Child Helpline',
          AppConstants.childHelplineKenya,
          'Support for children & teens',
          AppConstants.successColor,
        ),
        const SizedBox(height: 12),
        _buildHotlineRow(
          'Police Emergency',
          AppConstants.policeEmergencyNumber,
          'Report crimes & emergencies',
          AppConstants.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildHotlineRow(
          'National Emergency',
          AppConstants.nationalEmergencyNumber,
          'All emergency services',
          AppConstants.emergencyRed,
        ),
      ],
    );
  }

  Widget _buildHotlineRow(
      String name, String number, String description, Color buttonColor) {
    return Row(
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
        ElevatedButton(
          onPressed: () => _makePhoneCall(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(number),
        ),
      ],
    );
  }

  Widget _buildImportantRights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.balance, color: AppConstants.textPrimaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              'Know Your Rights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRightItem(
            'You have the right to free medical care at any GBVRC'),
        _buildRightItem(
            'You have the right to report at any time, even years later'),
        _buildRightItem(
            'You have the right to confidentiality and privacy'),
        _buildRightItem(
            'You have the right to be treated with dignity and respect'),
        _buildRightItem(
            'You have the right to legal representation and justice'),
        _buildRightItem(
            'You have the right to counseling and psychological support'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: AppConstants.successColor, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Remember: It\'s not your fault. You deserve support and justice.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppConstants.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: AppConstants.successColor,
            ),
          ),
          const SizedBox(width: 12),
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
