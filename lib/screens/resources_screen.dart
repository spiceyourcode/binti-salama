import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources & Information'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildResourceCard(
            context,
            title: 'What is Sexual Violence',
            icon: Icons.info,
            color: AppConstants.primaryColor,
            onTap: () => _showResourceDetails(context, _whatIsSexualViolence),
          ),
          _buildResourceCard(
            context,
            title: 'Your Rights After Assault',
            icon: Icons.balance,
            color: AppConstants.accentColor,
            onTap: () => _showResourceDetails(context, _yourRights),
          ),
          _buildResourceCard(
            context,
            title: 'Health & Medical Support',
            icon: Icons.local_hospital,
            color: AppConstants.successColor,
            onTap: () => _showResourceDetails(context, _healthSupport),
          ),
          _buildResourceCard(
            context,
            title: 'Legal Rights & Reporting',
            icon: Icons.gavel,
            color: AppConstants.secondaryColor,
            onTap: () => _showResourceDetails(context, _legalRights),
          ),
          _buildResourceCard(
            context,
            title: 'Psychological Support',
            icon: Icons.psychology,
            color: AppConstants.warningColor,
            onTap: () => _showResourceDetails(context, _psychologicalSupport),
          ),
          _buildResourceCard(
            context,
            title: 'Myths vs Facts',
            icon: Icons.fact_check,
            color: AppConstants.primaryColor,
            onTap: () => _showResourceDetails(context, _mythsFacts),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showResourceDetails(BuildContext context, Map<String, dynamic> resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceDetailScreen(resource: resource),
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

  const ResourceDetailScreen({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (resource['color'] as Color).withOpacity(0.1),
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
          ],
        ),
      ),
    );
  }
}

