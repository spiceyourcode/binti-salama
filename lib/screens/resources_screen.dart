import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../services/language_provider.dart';
import '../utils/localization.dart';
import '../widgets/bottom_navigation.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider?>(context, listen: true);
    final t = languageProvider?.t;

    return Scaffold(
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
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
                        t?.translate('resources_info') ??
                            'Resources & Information',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t?.translate('knowledge_is_power') ??
                            'Knowledge is power',
                        style: const TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStaticInfoCard(
                  title: t?.translate('learn_empower_yourself') ??
                      'Learn & Empower Yourself',
                  description: t?.translate('learn_empower_description') ??
                      'Understanding your rights and options helps you make informed decisions. Knowledge is a powerful tool for healing.',
                  icon: Icons.lightbulb_outline,
                  color: AppConstants.successColor.withValues(alpha: 0.1),
                  iconColor: AppConstants.successColor,
                ),
                _buildResourceCard(
                  context,
                  title: t?.translate('what_is_sexual_violence_title') ??
                      'What is Sexual Violence?',
                  description:
                      t?.translate('what_is_sexual_violence_description') ??
                          'Understanding definitions, types, and consent.',
                  icon: Icons.info,
                  color: AppConstants.primaryColor,
                  onTap: () =>
                      _showResourceDetails(context, _whatIsSexualViolence, t),
                  t: t,
                ),
                _buildResourceCard(
                  context,
                  title: t?.translate('your_rights_after_assault_title') ??
                      'Your Rights After Assault',
                  description:
                      t?.translate('your_rights_after_assault_description') ??
                          'Legal protections and what you\'re entitled to.',
                  icon: Icons.balance,
                  color: AppConstants.accentColor,
                  onTap: () => _showResourceDetails(context, _yourRights, t),
                  t: t,
                ),
                _buildResourceCard(
                  context,
                  title: t?.translate('health_medical_support_title') ??
                      'Health & Medical Support',
                  description:
                      t?.translate('health_medical_support_description') ??
                          'PEP timeline, GBVRC services, and follow-up care.',
                  icon: Icons.local_hospital,
                  color: AppConstants.successColor,
                  onTap: () => _showResourceDetails(context, _healthSupport, t),
                  t: t,
                ),
                _buildResourceCard(
                  context,
                  title: t?.translate('legal_rights_reporting_title') ??
                      'Legal Rights & Reporting',
                  description:
                      t?.translate('legal_rights_reporting_description') ??
                          'Sexual Offences Act and court procedures.',
                  icon: Icons.gavel,
                  color: AppConstants.secondaryColor,
                  onTap: () => _showResourceDetails(context, _legalRights, t),
                  t: t,
                ),
                _buildResourceCard(
                  context,
                  title: t?.translate('psychological_support_title') ??
                      'Psychological Support',
                  description:
                      t?.translate('psychological_support_description') ??
                          'Common reactions, coping strategies, and healing.',
                  icon: Icons.psychology,
                  color: AppConstants.warningColor,
                  onTap: () =>
                      _showResourceDetails(context, _psychologicalSupport, t),
                  t: t,
                ),
                _buildResourceCard(
                  context,
                  title:
                      t?.translate('myths_vs_facts_title') ?? 'Myths vs Facts',
                  description: t?.translate('myths_vs_facts_description') ??
                      'Debunking common misconceptions.',
                  icon: Icons.fact_check,
                  color: const Color(0xFFFF6B9D),
                  onTap: () => _showResourceDetails(context, _mythsFacts, t),
                  t: t,
                ),
                const SizedBox(height: 16),
                _buildGuidanceCard(t),
                const SizedBox(height: 16),
                _buildEmergencyContactSection(t),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/resources'),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    AppLocalizations? t,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildGuidanceCard(AppLocalizations? t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timer_outlined,
              color: AppConstants.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t?.translate('take_your_time') ?? 'Take Your Time',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t?.translate('take_your_time_description') ??
                      'There\'s no rush to read everything at once. Come back to these resources whenever you need them. Healing happens at your own pace.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? AppConstants.primaryColor)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactSection(AppLocalizations? t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.phone,
                size: 20, color: AppConstants.textPrimaryColor),
            const SizedBox(width: 8),
            Text(
              t?.translate('need_to_talk') ?? 'Need to Talk?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          t?.translate('need_to_talk_description') ??
              'If you need immediate support, our helplines are available 24/7.',
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri(
                      scheme: 'tel', path: AppConstants.genderViolenceHotline);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.phone, size: 18),
                label: Text(AppConstants.genderViolenceHotline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri =
                      Uri(scheme: 'tel', path: AppConstants.childHelplineKenya);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.phone, size: 18),
                label: Text(AppConstants.childHelplineKenya),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showResourceDetails(BuildContext context, Map<String, dynamic> resource,
      AppLocalizations? t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceDetailScreen(resource: resource, t: t),
      ),
    );
  }

  // Resource Content
  static final Map<String, dynamic> _whatIsSexualViolence = {
    'title': 'What is Sexual Violence',
    'icon': Icons.info,
    'color': AppConstants.primaryColor,
    'content': '''
Sexual violence is any sexual act or attempt to obtain a sexual act by violence or coercion, acts to traffic a person, or acts directed against a person's sexuality, regardless of the relationship to the victim.

**Types of Sexual Violence:**

• **Rape:** Non-consensual sexual intercourse through force, threats, or when someone is unable to consent

• **Sexual Assault:** Any unwanted sexual contact or behavior that occurs without consent

• **Child Sexual Abuse:** Any sexual activity with a minor who cannot give informed consent

• **Sexual Harassment:** Unwelcome sexual advances, requests for sexual favors, or other verbal or physical conduct of a sexual nature

• **Sexual Exploitation:** Taking advantage of someone for sexual purposes

**What is Consent?**

Consent means freely agreeing to sexual activity. Consent must be:

• Given freely without pressure, force, or manipulation
• Informed - understanding what you're consenting to
• Reversible - you can change your mind at any time
• Specific - consenting to one thing doesn't mean consenting to everything

**Who Cannot Give Consent:**

• Children and minors
• Someone who is asleep or unconscious
• Someone who is incapacitated by alcohol or drugs
• Someone with certain mental disabilities
• Someone who is forced, threatened, or coerced

**Remember:** If you didn't consent, it's not your fault. You have the right to say no at any time.
''',
  };

  static final Map<String, dynamic> _yourRights = {
    'title': 'Your Rights After Assault',
    'icon': Icons.balance,
    'color': AppConstants.accentColor,
    'content': '''
You have legal rights under Kenyan law. The Sexual Offences Act 2006 protects you and holds perpetrators accountable.

**Your Fundamental Rights:**

• **Right to Medical Care:** You have the right to free medical treatment at government health facilities, regardless of your ability to pay

• **Right to Privacy:** Your identity as a survivor must be protected. It's illegal for media to publish your name without consent

• **Right to Dignity:** You must be treated with respect and dignity by all service providers (medical, police, legal)

• **Right to Report:** You can choose whether or not to report to police. It's your decision.

• **Right to Safety:** You have the right to protection from further harm and intimidation

• **Right to Support:** You have the right to counseling, support services, and legal aid

**At the Police Station:**

• You have the right to file a report and get an OB number
• You have the right to a female officer if you prefer
• You have the right to refuse to answer questions that make you uncomfortable
• You have the right to have a support person with you
• You have the right to get a copy of your statement

**In Court:**

• You have the right to testify in camera (private hearing)
• You have the right to be protected from intimidating questions
• You have the right to legal representation
• You have the right to victim compensation if perpetrator is convicted

**Important:** No one can force you to do anything you don't want to do. You are in control of your healing journey.
''',
  };

  static final Map<String, dynamic> _healthSupport = {
    'title': 'Health & Medical Support',
    'icon': Icons.local_hospital,
    'color': AppConstants.successColor,
    'content': '''
Seeking medical care after sexual violence is crucial for your health and safety.

**Immediate Medical Needs (First 72 Hours):**

• **HIV Post-Exposure Prophylaxis (PEP):** Must be started within 72 hours to prevent HIV infection. It's most effective within the first few hours. Take for 28 days.

• **Emergency Contraception:** Available up to 120 hours (5 days) after assault to prevent pregnancy. Most effective within 72 hours.

• **STI Prevention:** Prophylactic treatment for sexually transmitted infections

• **Injury Treatment:** Treatment for any physical injuries

• **Forensic Evidence:** If you plan to report, forensic examination should be done within 72 hours

**What to Expect at a GBVRC:**

1. Registration (your information is confidential)
2. Medical history and examination
3. Treatment for injuries
4. HIV and pregnancy tests
5. Provision of PEP and emergency contraception
6. STI prophylaxis
7. Counseling services
8. Forensic evidence collection (if you consent)
9. P3 form completion for legal purposes

**Follow-up Care:**

• Return for PEP refills (28-day course)
• HIV testing at 6 weeks, 3 months, and 6 months
• Pregnancy test after 2-3 weeks
• STI screening
• Counseling sessions
• Medical certificate if needed for legal proceedings

**Remember:** Medical treatment at government facilities is FREE. You don't need money for emergency care.
''',
  };

  static final Map<String, dynamic> _legalRights = {
    'title': 'Legal Rights & Reporting',
    'icon': Icons.gavel,
    'color': AppConstants.secondaryColor,
    'content': '''
Understanding your legal options helps you make informed decisions about reporting.

**The Sexual Offences Act 2006:**

This law makes all forms of sexual violence illegal in Kenya and provides penalties for perpetrators:

• Rape: Life imprisonment
• Gang rape: Minimum 15 years
• Attempted rape: Minimum 10 years
• Child sexual offences: Minimum 20 years

**What Happens When You Report:**

1. **At the Police Station:**
   • File report at GBV desk
   • Give statement
   • Get OB (Occurrence Book) number - KEEP THIS!
   • Request P3 form for medical examination

2. **Investigation:**
   • Police investigate the case
   • Interview witnesses
   • Collect evidence
   • May arrest suspect

3. **Court Process:**
   • Case goes to court if there's sufficient evidence
   • You may need to testify
   • You can have support person present
   • Hearings can be private (in camera)

**Important Documents:**

• **OB Number:** Proof you reported to police
• **P3 Form:** Medical-legal evidence form completed by doctor
• **Medical Certificate:** Documents injuries
• **Statement Copy:** Your account of what happened

**Your Rights During Legal Process:**

• Right to information about case progress
• Right to protection from intimidation
• Right to legal aid if you can't afford lawyer
• Right to privacy (no media naming)
• Right to victim-friendly procedures
• Right to compensation if perpetrator convicted

**Remember:** Reporting is your choice. You can report immediately or later. The decision is yours alone.
''',
  };

  static final Map<String, dynamic> _psychologicalSupport = {
    'title': 'Psychological Support',
    'icon': Icons.psychology,
    'color': AppConstants.warningColor,
    'content': '''
Sexual violence affects more than just your physical health. Emotional and psychological healing is equally important.

**Common Reactions:**

You may experience a range of feelings, all of which are normal:

• Shock and disbelief
• Fear and anxiety
• Anger and rage
• Guilt and shame (though it's NOT your fault)
• Sadness and depression
• Difficulty trusting others
• Flashbacks or nightmares
• Changes in appetite or sleep
• Difficulty concentrating
• Avoiding people or places

**These Are Normal Reactions to Trauma**

**How to Cope:**

• Talk to someone you trust
• Seek professional counseling
• Join a support group
• Take care of your physical health
• Practice self-care activities
• Give yourself time to heal
• Don't blame yourself
• Know that healing is possible

**When to Seek Professional Help:**

• Thoughts of harming yourself or others
• Persistent nightmares or flashbacks
• Severe anxiety or depression
• Difficulty functioning in daily life
• Substance abuse to cope
• Feeling stuck in your healing process

**Available Support:**

• GBVRCs provide free counseling
• Helplines available 24/7
• Support groups for survivors
• Community-based organizations
• Faith-based counseling (if you choose)
• School counselors (for students)

**Self-Care Tips:**

• Create a safety plan
• Establish routines
• Exercise regularly
• Eat nutritious meals
• Get enough sleep
• Practice relaxation techniques
• Do things you enjoy
• Connect with supportive people
• Be patient with yourself

**Remember:** Healing is not linear. You may have good days and bad days. Both are part of the process.
''',
  };

  static final Map<String, dynamic> _mythsFacts = {
    'title': 'Myths vs Facts',
    'icon': Icons.fact_check,
    'color': AppConstants.primaryColor,
    'content': '''
Many myths about sexual violence exist. Let's separate fact from fiction.

**MYTH:** Sexual violence only happens to women and girls.
**FACT:** While females are more often targeted, males and people of all genders can experience sexual violence.

**MYTH:** Sexual violence is usually committed by strangers.
**FACT:** Most survivors know their attackers - they may be family members, friends, partners, or acquaintances.

**MYTH:** If you didn't fight back, it wasn't really assault.
**FACT:** Freezing is a common trauma response. Not resisting doesn't mean you consented.

**MYTH:** What you were wearing caused the assault.
**FACT:** Clothing does NOT cause sexual violence. The perpetrator's decision to assault is the only cause.

**MYTH:** If you were drinking or using drugs, you're to blame.
**FACT:** Being intoxicated does NOT give anyone permission to assault you. It's still sexual violence.

**MYTH:** If you had a previous sexual relationship, it can't be rape.
**FACT:** Anyone can withdraw consent at any time. Rape can occur in relationships and marriages.

**MYTH:** Real survivors would report to police immediately.
**FACT:** Survivors report when they're ready. Delayed reporting doesn't mean it didn't happen.

**MYTH:** If there are no visible injuries, it wasn't really assault.
**FACT:** Most sexual assaults don't result in visible physical injuries.

**MYTH:** Men cannot be raped.
**FACT:** Anyone can be a victim of sexual violence, regardless of gender.

**MYTH:** Sexual violence is about uncontrolled sexual desire.
**FACT:** Sexual violence is about power, control, and violence - not sexual desire.

**MYTH:** False reports of sexual violence are common.
**FACT:** False reports are rare (2-8%). The vast majority of reports are true.

**MYTH:** You can tell if someone is lying about being assaulted.
**FACT:** There's no "right" way to react to trauma. Everyone responds differently.

**THE MOST IMPORTANT FACT:**

Sexual violence is NEVER the survivor's fault. The only person responsible is the perpetrator who chose to commit the crime.

You deserve support, care, and justice - no matter the circumstances.
''',
  };
}

class ResourceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> resource;
  final AppLocalizations? t;

  const ResourceDetailScreen({super.key, required this.resource, this.t});

  @override
  Widget build(BuildContext context) {
    final title = resource['title'] as String;
    final subtitle = _getSubtitle(title);

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
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildContentForResource(title),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle(String title) {
    switch (title) {
      case 'What is Sexual Violence':
        return 'Understanding the basics';
      case 'Your Rights After Assault':
        return 'Know your legal protections';
      case 'Health & Medical Support':
        return 'Critical care information';
      case 'Legal Rights & Reporting':
        return 'Understanding the legal process';
      case 'Psychological Support':
        return 'Healing and recovery';
      case 'Myths vs Facts':
        return 'Separating truth from fiction';
      default:
        return 'Important information';
    }
  }

  Widget _buildContentForResource(String title) {
    switch (title) {
      case 'What is Sexual Violence':
        return _buildWhatIsSexualViolenceContent();
      case 'Your Rights After Assault':
        return _buildYourRightsContent();
      case 'Health & Medical Support':
        return _buildHealthSupportContent();
      case 'Legal Rights & Reporting':
        return _buildLegalRightsContent();
      case 'Psychological Support':
        return _buildPsychologicalSupportContent();
      case 'Myths vs Facts':
        return _buildMythsFactsContent();
      default:
        return _buildStandardContent();
    }
  }

  Widget _buildStandardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (resource['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                resource['icon'] as IconData,
                size: 40,
                color: resource['color'] as Color,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  resource['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          resource['content'],
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        _buildSupportCard(),
      ],
    );
  }

  Widget _buildWhatIsSexualViolenceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Knowledge Empowers Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Knowledge Empowers You',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Understanding what sexual violence is helps you recognize it, know your rights, and seek the support you deserve.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Definition Card
        _buildInfoCard(
          'Definition',
          'Sexual violence is any sexual act or attempt to obtain a sexual act by violence or coercion, acts to traffic a person, or acts directed against a person\'s sexuality, regardless of the relationship to the victim.',
          note:
              'Sexual violence can happen to anyone, regardless of age, gender, appearance, or relationship status. It is never the victim\'s fault.',
        ),
        const SizedBox(height: 24),

        // Types Section
        const Text(
          'Types of Sexual Violence',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildTypeCard(
          'Rape',
          'Forced sexual intercourse without consent. This includes situations where the victim is unable to give consent due to age, intoxication, or mental capacity.',
        ),
        _buildTypeCard(
          'Sexual Assault',
          'Unwanted sexual contact including touching, groping, or forced kissing. Any sexual contact without clear consent is assault.',
        ),
        _buildTypeCard(
          'Sexual Harassment',
          'Unwelcome sexual advances, requests for sexual favors, or verbal/physical harassment of a sexual nature. This includes catcalling, inappropriate comments, or sharing explicit images.',
        ),
        _buildTypeCard(
          'Child Sexual Abuse',
          'Any sexual activity with a child. Children cannot legally consent to sexual activity. This includes exploitation, grooming, and exposure to sexual content.',
        ),
        _buildTypeCard(
          'Intimate Partner Violence',
          'Sexual violence by a current or former partner. Being in a relationship does not mean automatic consent. You have the right to say no at any time.',
        ),
        const SizedBox(height: 24),

        // Understanding Consent
        _buildInfoCard(
          'Understanding Consent',
          'Consent is a clear, voluntary agreement to engage in sexual activity. It must be given freely without pressure, threats, or manipulation.',
          color: AppConstants.successColor,
          items: [
            'Freely given: Not pressured, forced, or manipulated',
            'Reversible: Can be withdrawn at any time',
            'Informed: Both parties understand what they\'re agreeing to',
            'Enthusiastic: Active participation, not passive acceptance',
            'Specific: Consent to one act doesn\'t mean consent to all',
          ],
        ),
        const SizedBox(height: 16),

        // When Consent Cannot Be Given
        _buildInfoCard(
          'When Consent Cannot Be Given',
          '',
          color: const Color(0xFFFF6B9D),
          items: [
            'When someone is under the legal age of consent (18 in Kenya)',
            'When someone is intoxicated or under the influence of drugs',
            'When someone is asleep or unconscious',
            'When someone has a mental disability that prevents understanding',
            'When someone is threatened, intimidated, or coerced',
          ],
        ),
        const SizedBox(height: 16),

        // Remember Card
        _buildInfoCard(
          'Remember',
          'Sexual violence is never your fault. No matter what you were wearing, where you were, or what you were doing. The responsibility lies solely with the perpetrator. You deserve support, respect, and justice.',
          borderColor: AppConstants.primaryColor,
        ),
        const SizedBox(height: 16),

        // Need Support Card
        _buildSupportCard(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildYourRightsContent() {
    final color = AppConstants.accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Empowerment Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You Have Rights',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Under Kenyan law, you are protected. The Sexual Offences Act 2006 ensures your rights and holds perpetrators accountable.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.balance,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Fundamental Rights
        _buildInfoCard(
          'Your Fundamental Rights',
          '',
          color: color,
          items: [
            'Right to Medical Care: Free medical treatment at government health facilities, regardless of ability to pay',
            'Right to Privacy: Your identity as a survivor must be protected. Media cannot publish your name without consent',
            'Right to Dignity: You must be treated with respect and dignity by all service providers',
            'Right to Report: You can choose whether or not to report to police. It\'s your decision',
            'Right to Safety: You have the right to protection from further harm and intimidation',
            'Right to Support: You have the right to counseling, support services, and legal aid',
          ],
        ),
        const SizedBox(height: 16),

        // At Police Station
        _buildInfoCard(
          'At the Police Station',
          'When you report, you have specific rights:',
          color: AppConstants.primaryColor,
          items: [
            'You have the right to file a report and get an OB number',
            'You have the right to a female officer if you prefer',
            'You have the right to refuse to answer questions that make you uncomfortable',
            'You have the right to have a support person with you',
            'You have the right to get a copy of your statement',
          ],
        ),
        const SizedBox(height: 16),

        // In Court
        _buildInfoCard(
          'In Court',
          'During legal proceedings, you are protected:',
          color: AppConstants.secondaryColor,
          items: [
            'You have the right to testify in camera (private hearing)',
            'You have the right to be protected from intimidating questions',
            'You have the right to legal representation',
            'You have the right to victim compensation if perpetrator is convicted',
          ],
        ),
        const SizedBox(height: 16),

        // Important Note
        _buildInfoCard(
          'Remember',
          'No one can force you to do anything you don\'t want to do. You are in control of your healing journey. Your rights are protected by law.',
          borderColor: color,
        ),
        const SizedBox(height: 16),

        _buildSupportCard(),
      ],
    );
  }

  Widget _buildHealthSupportContent() {
    final color = AppConstants.successColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Critical Care Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Health Matters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seeking medical care after sexual violence is crucial for your health and safety. Immediate care can prevent serious health issues.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Critical Time Window
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.emergencyRed.withValues(alpha: 0.1),
            border: Border.all(color: AppConstants.emergencyRed, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 48,
                color: AppConstants.emergencyRed,
              ),
              const SizedBox(height: 12),
              const Text(
                'CRITICAL TIME WINDOW',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.emergencyRed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                '72 Hours for PEP',
                'HIV Post-Exposure Prophylaxis (PEP) must be started within 72 hours to prevent HIV infection. It\'s most effective within the first few hours. Take for 28 days.',
                color: AppConstants.emergencyRed,
              ),
              const SizedBox(height: 8),
              _buildInfoCard(
                'Emergency Contraception (120 Hours)',
                'Available up to 120 hours (5 days) after assault to prevent pregnancy. Most effective within 72 hours.',
                color: AppConstants.emergencyRed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Immediate Medical Needs
        _buildInfoCard(
          'Immediate Medical Needs',
          'Critical care needed within the first 72 hours:',
          color: color,
          items: [
            'HIV Post-Exposure Prophylaxis (PEP) - within 72 hours',
            'Emergency Contraception - within 120 hours',
            'STI Prevention - prophylactic treatment',
            'Injury Treatment - treatment for any physical injuries',
            'Forensic Evidence - if you plan to report, forensic examination should be done within 72 hours',
          ],
        ),
        const SizedBox(height: 16),

        // What to Expect at GBVRC
        _buildInfoCard(
          'What to Expect at a GBVRC',
          'When you visit a Gender-Based Violence Recovery Center:',
          color: AppConstants.primaryColor,
          items: [
            'Registration (your information is confidential)',
            'Medical history and examination',
            'Treatment for injuries',
            'HIV and pregnancy tests',
            'Provision of PEP and emergency contraception',
            'STI prophylaxis',
            'Counseling services',
            'Forensic evidence collection (if you consent)',
            'P3 form completion for legal purposes',
          ],
        ),
        const SizedBox(height: 16),

        // Follow-up Care
        _buildInfoCard(
          'Follow-up Care',
          'Important ongoing care you should receive:',
          color: AppConstants.accentColor,
          items: [
            'Return for PEP refills (28-day course)',
            'HIV testing at 6 weeks, 3 months, and 6 months',
            'Pregnancy test after 2-3 weeks',
            'STI screening',
            'Counseling sessions',
            'Medical certificate if needed for legal proceedings',
          ],
        ),
        const SizedBox(height: 16),

        // Important Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: AppConstants.successColor, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Remember: Medical treatment at government facilities is FREE. You don\'t need money for emergency care.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSupportCard(),
      ],
    );
  }

  Widget _buildLegalRightsContent() {
    final color = AppConstants.secondaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Empowerment Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Know Your Legal Options',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Understanding your legal options helps you make informed decisions about reporting. You have the right to justice.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Sexual Offences Act
        _buildInfoCard(
          'The Sexual Offences Act 2006',
          'This law makes all forms of sexual violence illegal in Kenya and provides penalties for perpetrators:',
          color: color,
          items: [
            'Rape: Life imprisonment',
            'Gang rape: Minimum 15 years',
            'Attempted rape: Minimum 10 years',
            'Child sexual offences: Minimum 20 years',
          ],
        ),
        const SizedBox(height: 16),

        // What Happens When You Report
        _buildInfoCard(
          'What Happens When You Report',
          '',
          color: AppConstants.primaryColor,
          items: [
            'At the Police Station: File report at GBV desk, give statement, get OB number, request P3 form',
            'Investigation: Police investigate, interview witnesses, collect evidence, may arrest suspect',
            'Court Process: Case goes to court if sufficient evidence, you may need to testify, hearings can be private',
          ],
        ),
        const SizedBox(height: 16),

        // Important Documents
        _buildInfoCard(
          'Important Documents',
          'Keep these documents safe - they are important for your case:',
          color: AppConstants.accentColor,
          items: [
            'OB Number: Proof you reported to police',
            'P3 Form: Medical-legal evidence form completed by doctor',
            'Medical Certificate: Documents injuries',
            'Statement Copy: Your account of what happened',
          ],
        ),
        const SizedBox(height: 16),

        // Your Rights During Legal Process
        _buildInfoCard(
          'Your Rights During Legal Process',
          '',
          color: AppConstants.warningColor,
          items: [
            'Right to information about case progress',
            'Right to protection from intimidation',
            'Right to legal aid if you can\'t afford lawyer',
            'Right to privacy (no media naming)',
            'Right to victim-friendly procedures',
            'Right to compensation if perpetrator convicted',
          ],
        ),
        const SizedBox(height: 16),

        // Important Note
        _buildInfoCard(
          'Remember',
          'Reporting is your choice. You can report immediately or later. The decision is yours alone. No one can force you to report.',
          borderColor: color,
        ),
        const SizedBox(height: 16),

        _buildSupportCard(),
      ],
    );
  }

  Widget _buildPsychologicalSupportContent() {
    final color = AppConstants.warningColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Empowerment Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Healing is Possible',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sexual violence affects more than just your physical health. Emotional and psychological healing is equally important.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Common Reactions
        _buildInfoCard(
          'Common Reactions',
          'You may experience a range of feelings, all of which are normal:',
          color: color,
          items: [
            'Shock and disbelief',
            'Fear and anxiety',
            'Anger and rage',
            'Guilt and shame (though it\'s NOT your fault)',
            'Sadness and depression',
            'Difficulty trusting others',
            'Flashbacks or nightmares',
            'Changes in appetite or sleep',
            'Difficulty concentrating',
            'Avoiding people or places',
          ],
          note:
              'These are normal reactions to trauma. You are not alone in feeling this way.',
        ),
        const SizedBox(height: 16),

        // How to Cope
        _buildInfoCard(
          'How to Cope',
          'Strategies that can help you heal:',
          color: AppConstants.successColor,
          items: [
            'Talk to someone you trust',
            'Seek professional counseling',
            'Join a support group',
            'Take care of your physical health',
            'Practice self-care activities',
            'Give yourself time to heal',
            'Don\'t blame yourself',
            'Know that healing is possible',
          ],
        ),
        const SizedBox(height: 16),

        // When to Seek Professional Help
        _buildInfoCard(
          'When to Seek Professional Help',
          'Consider seeking help if you experience:',
          color: AppConstants.emergencyRed,
          items: [
            'Thoughts of harming yourself or others',
            'Persistent nightmares or flashbacks',
            'Severe anxiety or depression',
            'Difficulty functioning in daily life',
            'Substance abuse to cope',
            'Feeling stuck in your healing process',
          ],
        ),
        const SizedBox(height: 16),

        // Available Support
        _buildInfoCard(
          'Available Support',
          'Help is available in many forms:',
          color: AppConstants.primaryColor,
          items: [
            'GBVRCs provide free counseling',
            'Helplines available 24/7',
            'Support groups for survivors',
            'Community-based organizations',
            'Faith-based counseling (if you choose)',
            'School counselors (for students)',
          ],
        ),
        const SizedBox(height: 16),

        // Self-Care Tips
        _buildInfoCard(
          'Self-Care Tips',
          'Taking care of yourself is important:',
          color: AppConstants.accentColor,
          items: [
            'Create a safety plan',
            'Establish routines',
            'Exercise regularly',
            'Eat nutritious meals',
            'Get enough sleep',
            'Practice relaxation techniques',
            'Do things you enjoy',
            'Connect with supportive people',
            'Be patient with yourself',
          ],
        ),
        const SizedBox(height: 16),

        // Important Note
        _buildInfoCard(
          'Remember',
          'Healing is not linear. You may have good days and bad days. Both are part of the process. Be kind to yourself.',
          borderColor: color,
        ),
        const SizedBox(height: 16),

        _buildSupportCard(),
      ],
    );
  }

  Widget _buildMythsFactsContent() {
    final color = const Color(0xFFFF6B9D);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Empowerment Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Truth Matters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Many myths about sexual violence exist. Let\'s separate fact from fiction. Knowing the truth helps you understand that what happened is not your fault.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fact_check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Myths vs Facts Cards
        _buildMythFactCard(
          'MYTH',
          'Sexual violence only happens to women and girls.',
          'FACT',
          'While females are more often targeted, males and people of all genders can experience sexual violence.',
        ),
        _buildMythFactCard(
          'MYTH',
          'Sexual violence is usually committed by strangers.',
          'FACT',
          'Most survivors know their attackers - they may be family members, friends, partners, or acquaintances.',
        ),
        _buildMythFactCard(
          'MYTH',
          'If you didn\'t fight back, it wasn\'t really assault.',
          'FACT',
          'Freezing is a common trauma response. Not resisting doesn\'t mean you consented.',
        ),
        _buildMythFactCard(
          'MYTH',
          'What you were wearing caused the assault.',
          'FACT',
          'Clothing does NOT cause sexual violence. The perpetrator\'s decision to assault is the only cause.',
        ),
        _buildMythFactCard(
          'MYTH',
          'If you were drinking or using drugs, you\'re to blame.',
          'FACT',
          'Being intoxicated does NOT give anyone permission to assault you. It\'s still sexual violence.',
        ),
        _buildMythFactCard(
          'MYTH',
          'If you had a previous sexual relationship, it can\'t be rape.',
          'FACT',
          'Anyone can withdraw consent at any time. Rape can occur in relationships and marriages.',
        ),
        _buildMythFactCard(
          'MYTH',
          'Real survivors would report to police immediately.',
          'FACT',
          'Survivors report when they\'re ready. Delayed reporting doesn\'t mean it didn\'t happen.',
        ),
        _buildMythFactCard(
          'MYTH',
          'If there are no visible injuries, it wasn\'t really assault.',
          'FACT',
          'Most sexual assaults don\'t result in visible physical injuries.',
        ),
        _buildMythFactCard(
          'MYTH',
          'Men cannot be raped.',
          'FACT',
          'Anyone can be a victim of sexual violence, regardless of gender.',
        ),
        _buildMythFactCard(
          'MYTH',
          'Sexual violence is about uncontrolled sexual desire.',
          'FACT',
          'Sexual violence is about power, control, and violence - not sexual desire.',
        ),
        _buildMythFactCard(
          'MYTH',
          'False reports of sexual violence are common.',
          'FACT',
          'False reports are rare (2-8%). The vast majority of reports are true.',
        ),
        _buildMythFactCard(
          'MYTH',
          'You can tell if someone is lying about being assaulted.',
          'FACT',
          'There\'s no "right" way to react to trauma. Everyone responds differently.',
        ),
        const SizedBox(height: 16),

        // Most Important Fact
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppConstants.emergencyRed.withValues(alpha: 0.1),
            border: Border.all(color: AppConstants.emergencyRed, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'THE MOST IMPORTANT FACT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.emergencyRed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sexual violence is NEVER the survivor\'s fault. The only person responsible is the perpetrator who chose to commit the crime.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You deserve support, care, and justice - no matter the circumstances.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSupportCard(),
      ],
    );
  }

  Widget _buildMythFactCard(
      String mythLabel, String myth, String factLabel, String fact) {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mythLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.errorColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              myth,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                factLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.successColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fact,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content,
      {String? note, Color? color, List<String>? items, Color? borderColor}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor.withValues(alpha: 0.3), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        (color ?? AppConstants.primaryColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: color ?? AppConstants.primaryColor,
                    size: 18,
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
                    softWrap: true,
                  ),
                ),
              ],
            ),
            if (content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
            if (items != null) ...[
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color ?? AppConstants.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            if (note != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Important: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.successColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppConstants.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppConstants.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppConstants.textSecondaryColor,
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

  Widget _buildSupportCard() {
    return Card(
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppConstants.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Need Support?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'If you\'ve experienced sexual violence, help is available 24/7.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri(
                          scheme: 'tel',
                          path: AppConstants.genderViolenceHotline);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text(
                        'GBV Hotline: ${AppConstants.genderViolenceHotline}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri(
                          scheme: 'tel', path: AppConstants.childHelplineKenya);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text(
                        'Child Helpline: ${AppConstants.childHelplineKenya}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

