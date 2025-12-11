class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App General
      'app_name': 'Binti Salama',
      'app_tagline': 'Safe Girl - Your Confidential Support',

      // Login & Onboarding
      'welcome': 'Welcome',
      'welcome_message':
          'You are safe here. All your information is private and protected.',
      'create_pin': 'Create Your PIN',
      'enter_pin': 'Enter Your PIN',
      'confirm_pin': 'Confirm Your PIN',
      'pin_hint': 'Enter 4-6 digit PIN',
      'forgot_pin': 'Forgot PIN?',
      'forgot_pin_message':
          'For security reasons, if you forgot your PIN, you will need to reinstall the app. This will delete all locally stored data.',
      'login': 'Login',
      'continue_btn': 'Continue',

      // Home Screen
      'home': 'Home',
      'emergency': 'Emergency',
      'quick_access': 'Quick Access',
      'get_help_now': 'Get Help Now',
      'find_services': 'Find Services',
      'first_response': 'First Response',
      'my_records': 'My Records',
      'resources': 'Resources',
      'settings': 'Settings',

      // Panic Button
      'panic_button': 'Emergency Alert',
      'panic_sent': 'Emergency alert sent to your trusted contacts',
      'panic_failed':
          'Failed to send alert. Please try again or call emergency services.',
      'sending_alert': 'Sending emergency alert...',

      // Service Locator
      'services': 'Services',
      'find_nearest': 'Find Nearest Services',
      'all_services': 'All Services',
      'nearest_services': 'Nearest to You',
      'search_services': 'Search services...',
      'call': 'Call',
      'directions': 'Get Directions',
      'service_types': 'Service Types',
      'filter': 'Filter',
      'distance': 'Distance',
      'operating_hours': 'Operating Hours',
      'youth_friendly': 'Youth Friendly',

      // Service Types
      'GBVRC': 'GBV Recovery Center',
      'clinic': 'Health Clinic',
      'police': 'Police GBV Desk',
      'rescue_center': 'Rescue Center',

      // First Response
      'first_response_guide': 'First Response Guide',
      'critical_notice': 'CRITICAL: You have 72 hours for HIV prevention (PEP)',
      'step_1': '1. Get to Safety',
      'step_1_detail':
          'Move to a safe location immediately. Call someone you trust.',
      'step_2': '2. Preserve Evidence',
      'step_2_detail':
          'Do not wash, change clothes, eat, drink, or use bathroom if possible.',
      'step_3': '3. Seek Medical Care',
      'step_3_detail':
          'Go to nearest GBVRC immediately. Request HIV PEP, emergency contraception, and forensic exam.',
      'step_4': '4. Report to Police',
      'step_4_detail':
          'File a report at the police GBV desk. Get OB number and P3 form.',
      'step_5': '5. Document Everything',
      'step_5_detail':
          'Write down what happened while it\'s fresh in your mind.',
      'step_6': '6. Seek Support',
      'step_6_detail':
          'Contact counseling services. You don\'t have to go through this alone.',
      'emergency_hotlines': 'Emergency Hotlines',

      // Incident Log
      'incident_log': 'Incident Log',
      'new_incident': 'New Incident',
      'incident_date': 'Date of Incident',
      'incident_description': 'What Happened',
      'perpetrator': 'Perpetrator Description',
      'witnesses': 'Witnesses',
      'actions_taken': 'Actions Taken',
      'medical_facility': 'Medical Facility Visited',
      'evidence_preserved': 'Evidence Preserved',
      'police_report': 'Police Report Filed',
      'ob_number': 'OB Number',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'export': 'Export Report',
      'search': 'Search',
      'no_incidents': 'No incidents recorded',

      // Trusted Contacts
      'trusted_contacts': 'Trusted Contacts',
      'add_contact': 'Add Contact',
      'contact_name': 'Contact Name',
      'phone_number': 'Phone Number',
      'contact_type': 'Contact Type',
      'emergency_contact': 'Emergency Contact',
      'custom_message': 'Custom Alert Message (Optional)',
      'family': 'Family',
      'friend': 'Friend',
      'mobilizer': 'Community Mobilizer',
      'no_contacts': 'No trusted contacts added',

      // Settings
      'language': 'Language',
      'english': 'English',
      'swahili': 'Kiswahili',
      'panic_trigger': 'Panic Button Trigger',
      'shake': 'Shake Phone',
      'double_tap': 'Double Tap',
      'volume': 'Volume Buttons',
      'notifications': 'Notifications',
      'disguise_mode': 'Disguise Mode',
      'auto_lock': 'Auto-Lock',
      'minutes': 'minutes',
      'change_pin': 'Change PIN',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'delete_account': 'Delete Account',

      // Resources
      'what_is_sv': 'What is Sexual Violence',
      'your_rights': 'Your Rights After Assault',
      'health_support': 'Health & Medical Support',
      'legal_rights': 'Legal Rights & Reporting',
      'psychological_support': 'Psychological Support',
      'myths_facts': 'Myths vs Facts',
      'resources_info': 'Resources & Information',

      // Common Actions
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'edit': 'Edit',
      'update': 'Update',
      'close': 'Close',

      // Messages
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'confirm': 'Confirm',
      'are_you_sure': 'Are you sure?',
      'cannot_undo': 'This action cannot be undone.',
      'language_updated': 'Language updated',

      // First Response Screen - Additional
      'move_to_safe_location':
          'Move to a safe location immediately. If possible, call someone you trust.',
      'leave_dangerous_situation': 'Leave the dangerous situation',
      'go_to_public_place': 'Go to a public place if needed',
      'contact_trusted_person': 'Contact a trusted person',
      'this_crucial_for_medical':
          'This is crucial for medical and legal reasons.',
      'do_not_wash': 'DO NOT wash or bathe',
      'do_not_change_clothes': 'DO NOT change clothes',
      'do_not_eat_drink': 'DO NOT eat, drink, or brush teeth',
      'do_not_use_bathroom': 'DO NOT use the bathroom if possible',
      'do_not_comb_hair': 'DO NOT comb hair',
      'keep_clothes_paper_bag': 'Keep clothes in a paper bag (not plastic)',
      'go_to_gbvrc_72_hours':
          'Go to the nearest GBVRC within 72 hours for PEP (HIV prevention).',
      'request_hiv_pep':
          'Request HIV Post-Exposure Prophylaxis (PEP) - within 72 hours',
      'request_emergency_contraception':
          'Request emergency contraception - within 120 hours',
      'get_treatment_injuries': 'Get treatment for injuries',
      'request_forensic_examination': 'Request forensic examination',
      'get_tested_stis': 'Get tested for STIs',
      'request_counseling_services': 'Request counseling services',
      'file_report_gbv_desk':
          'File a report at the GBV desk. You have the right to be treated with respect.',
      'go_to_police_gbv_desk': 'Go to the nearest police GBV desk',
      'ask_ob_number': 'Ask for an OB (Occurrence Book) number',
      'request_p3_form': 'Request a P3 form (medical-legal form)',
      'get_copy_statement': 'Get a copy of your statement',
      'note_officer_details': 'Note the officer\'s name and badge number',
      'write_while_fresh':
          'Write down what happened while it\'s still fresh in your mind.',
      'date_time_incident': 'Date and time of incident',
      'location_details': 'Location details',
      'description_perpetrator': 'Description of perpetrator',
      'names_witnesses': 'Names of witnesses',
      'what_was_said_done': 'What was said and done',
      'contact_counseling':
          'Contact counseling services. You don\'t have to go through this alone.',
      'preserve_evidence': 'Preserve Evidence',
      'seek_medical_care': 'Seek Medical Care IMMEDIATELY',
      'report_to_police': 'Report to Police',
      'document_everything': 'Document Everything',
      'seek_support': 'Seek Support',

      // Login Screen - Additional
      'too_many_attempts': 'Too many failed attempts. Please wait',
      'incorrect_pin': 'Incorrect PIN',
      'attempts_remaining': 'attempts remaining',
      'login_failed': 'Login failed',
      'enter_your_pin': 'Enter Your PIN',
      'app_icon': 'App Icon',
      'you_are_safe_here':
          'You are safe here. All your information is private and protected.',

      // Incident Log Screen - Additional
      'no_incidents_recorded': 'No incidents recorded',
      'tap_plus_document': 'Tap the + button to document an incident',
      'failed_to_load_incidents': 'Failed to load incidents',
      'search_failed': 'Search failed',

      // Splash Screen
      'privacy_notice':
          'Your privacy is protected. All information is encrypted and secure.',

      // Onboarding Screen
      'welcome_to_app': 'Welcome to Binti Salama',
      'safe_app_for_girls': 'A safe app for girls to report and get support',
      'get_started': 'Get Started',
      'your_journey_to_safety': 'Your Journey to Safety',
      'create_secure_pin': 'Create a secure PIN to protect your account',
      'pin_required': 'PIN Required',
      'find_support_services': 'Find support services near you',
      'services_near_you': 'Services Near You',
      'access_resources': 'Access resources and get guidance',
      'knowledge_is_power': 'Knowledge is Power',

      // Service Locator Screen - Additional
      'no_services_found': 'No services found',
      'enable_location': 'Please enable location services',
      'location_permission_denied': 'Location permission denied',
      'km_away': 'km away',
      'open_now': 'Open Now',
      'closed': 'Closed',
      'phone': 'Phone',
      'address': 'Address',
      'opening_hours': 'Opening Hours',
      'find_services_title': 'Find Services',
      'locate_support_near_you': 'Locate support near you',
      'search_by_name_or_location': 'Search by name or location...',
      'all_services': 'All Services',
      'showing_services': 'Showing {count} services in {county}',
      'filter_by_county': 'Filter by county',
      'clear_filters': 'Clear filters',
      'location_services': 'Location Services',
      'enable_location_description':
          'Enable location to find services nearest to you',
      'enable_location_button': 'Enable Location →',
      'need_help_choosing': 'Need Help Choosing?',
      'need_help_description':
          'All listed services are confidential and trained to support survivors. Youth-friendly services are specially equipped for adolescents.',
      'learn_more_about_services': 'Learn more about services →',
      'call_now': 'Call Now',
      'location_not_available': 'Location not available',
      'your_location': 'Your Location',
      'services_offered': 'Services Offered:',
      'failed_to_load_services': 'Failed to load services',
      'could_not_make_call': 'Could not make phone call',
      'could_not_open_maps': 'Could not open maps',

      // Resources Screen - Detailed Content
      'types_of_sexual_violence': 'Types of Sexual Violence',
      'rape': 'Rape',
      'sexual_assault': 'Sexual Assault',
      'child_sexual_abuse': 'Child Sexual Abuse',
      'sexual_harassment': 'Sexual Harassment',
      'sexual_exploitation': 'Sexual Exploitation',
      'what_is_consent': 'What is Consent?',
      'consent_freely_given':
          'Consent means freely agreeing to sexual activity',
      'consent_must_be': 'Consent must be:',
      'given_freely': 'Given freely without pressure, force, or manipulation',
      'informed': 'Informed - understanding what you\'re consenting to',
      'reversible': 'Reversible - you can change your mind at any time',
      'specific':
          'Specific - consenting to one thing doesn\'t mean consenting to everything',
      'who_cannot_consent': 'Who Cannot Give Consent',
      'children_minors': 'Children and minors',
      'asleep_unconscious': 'Someone who is asleep or unconscious',
      'incapacitated_by_alcohol':
          'Someone who is incapacitated by alcohol or drugs',
      'mental_disabilities': 'Someone with certain mental disabilities',
      'forced_threatened_coerced':
          'Someone who is forced, threatened, or coerced',
      'remember_not_your_fault':
          'Remember: If you didn\'t consent, it\'s not your fault. You have the right to say no at any time.',
      'learn_empower_yourself': 'Learn & Empower Yourself',
      'learn_empower_description':
          'Understanding your rights and options helps you make informed decisions. Knowledge is a powerful tool for healing.',
      'what_is_sexual_violence_title': 'What is Sexual Violence?',
      'what_is_sexual_violence_description':
          'Understanding definitions, types, and consent.',
      'your_rights_after_assault_title': 'Your Rights After Assault',
      'your_rights_after_assault_description':
          'Legal protections and what you\'re entitled to.',
      'health_medical_support_title': 'Health & Medical Support',
      'health_medical_support_description':
          'PEP timeline, GBVRC services, and follow-up care.',
      'legal_rights_reporting_title': 'Legal Rights & Reporting',
      'legal_rights_reporting_description':
          'Sexual Offences Act and court procedures.',
      'psychological_support_title': 'Psychological Support',
      'psychological_support_description':
          'Common reactions, coping strategies, and healing.',
      'myths_vs_facts_title': 'Myths vs Facts',
      'myths_vs_facts_description': 'Debunking common misconceptions.',
      'take_your_time': 'Take Your Time',
      'take_your_time_description':
          'There\'s no rush to read everything at once. Come back to these resources whenever you need them. Healing happens at your own pace.',
      'need_to_talk': 'Need to Talk?',
      'need_to_talk_description':
          'If you need immediate support, our helplines are available 24/7.',

      // Settings Screen - Additional
      'account_settings': 'Account Settings',
      'general': 'General',
      'privacy_security': 'Privacy & Security',
      'hide_app_name': 'Hide app name and icon',
      'enable_notifications': 'Enable app notifications',
      'about_app': 'About Binti Salama',
      'danger_zone': 'Danger Zone',
      'delete_all_data': 'Delete All Data',
      'confirm_pin_change': 'Confirm PIN Change',
      'old_pin': 'Old PIN',
      'new_pin': 'New PIN',
      'confirm_new_pin': 'Confirm New PIN',
      'pin_changed_successfully': 'PIN changed successfully',
      'pins_do_not_match': 'PINs do not match',
      'confirm_account_deletion': 'Confirm Account Deletion',
      'delete_account_warning':
          'This action will delete your account and all data. This cannot be undone.',
      'app_version': 'App Version',
      'last_updated': 'Last Updated',
    },
    'sw': {
      // App General
      'app_name': 'Binti Salama',
      'app_tagline': 'Msichana Salama - Msaada wako wa Siri',

      // Login & Onboarding
      'welcome': 'Karibu',
      'welcome_message':
          'Uko salama hapa. Taarifa zako zote ni za siri na zinaweza kulindwa.',
      'create_pin': 'Unda PIN Yako',
      'enter_pin': 'Weka PIN Yako',
      'confirm_pin': 'Thibitisha PIN Yako',
      'pin_hint': 'Weka nambari 4-6 za PIN',
      'forgot_pin': 'Umesahau PIN?',
      'forgot_pin_message':
          'Kwa sababu za usalama, ikiwa umesahau PIN yako, utahitaji kuinstalia programu upya. Hii itafuta taarifa zote zilizohifadhiwa ndani.',
      'login': 'Ingia',
      'continue_btn': 'Endelea',

      // Home Screen
      'home': 'Nyumbani',
      'emergency': 'Dharura',
      'quick_access': 'Ufikiaji wa Haraka',
      'get_help_now': 'Pata Msaada Sasa',
      'find_services': 'Tafuta Huduma',
      'first_response': 'Hatua za Kwanza',
      'my_records': 'Kumbukumbu Zangu',
      'resources': 'Rasilimali',
      'settings': 'Mipangilio',

      // Panic Button
      'panic_button': 'Tahadhari ya Dharura',
      'panic_sent': 'Ujumbe wa dharura umetumwa kwa watu wako wa kuaminika',
      'panic_failed':
          'Imeshindikana kutuma ujumbe. Tafadhali jaribu tena au piga simu huduma za dharura.',
      'sending_alert': 'Inatuma ujumbe wa dharura...',

      // Service Locator
      'services': 'Huduma',
      'find_nearest': 'Tafuta Huduma za Karibu',
      'all_services': 'Huduma Zote',
      'nearest_services': 'Karibu na Wewe',
      'search_services': 'Tafuta huduma...',
      'call': 'Piga Simu',
      'directions': 'Pata Maelekezo',
      'service_types': 'Aina za Huduma',
      'filter': 'Chuja',
      'distance': 'Umbali',
      'operating_hours': 'Masaa ya Kufanya Kazi',
      'youth_friendly': 'Rafiki wa Vijana',

      // Service Types
      'GBVRC': 'Kituo cha Kupona GBV',
      'clinic': 'Kliniki ya Afya',
      'police': 'Dawati la Polisi la GBV',
      'rescue_center': 'Kituo cha Uokoaji',

      // First Response
      'first_response_guide': 'Mwongozo wa Hatua za Kwanza',
      'critical_notice': 'MUHIMU: Una masaa 72 kwa kuzuia VVU (PEP)',
      'step_1': '1. Enda Mahali Salama',
      'step_1_detail':
          'Hamia mahali salama mara moja. Piga simu mtu unayemwamini.',
      'step_2': '2. Linda Ushahidi',
      'step_2_detail':
          'Usioshe, usibadilishe nguo, usile, usikunywe, au kutumia choo ikiwezekana.',
      'step_3': '3. Tafuta Huduma za Afya',
      'step_3_detail':
          'Nenda GBVRC ya karibu mara moja. Omba VVU PEP, uzuiaji wa dharura wa ujauzito, na uchunguzi wa forensic.',
      'step_4': '4. Ripoti kwa Polisi',
      'step_4_detail':
          'Fanya ripoti kwenye dawati la polisi la GBV. Pata nambari ya OB na fomu ya P3.',
      'step_5': '5. Andika Kila Kitu',
      'step_5_detail': 'Andika kilichotokea wakati bado kipo akilini.',
      'step_6': '6. Tafuta Msaada',
      'step_6_detail':
          'Wasiliana na huduma za ushauri. Huhitaji kupitia hii peke yako.',
      'emergency_hotlines': 'Simu za Dharura',

      // Incident Log
      'incident_log': 'Kumbukumbu ya Tukio',
      'new_incident': 'Tukio Jipya',
      'incident_date': 'Tarehe ya Tukio',
      'incident_description': 'Kilichotokea',
      'perpetrator': 'Maelezo ya Mhalifu',
      'witnesses': 'Mashahidi',
      'actions_taken': 'Hatua Zilizochukuliwa',
      'medical_facility': 'Kituo cha Afya Kilichotembelewa',
      'evidence_preserved': 'Ushahidi Umelindwa',
      'police_report': 'Ripoti ya Polisi Imefanywa',
      'ob_number': 'Nambari ya OB',
      'save': 'Hifadhi',
      'cancel': 'Ghairi',
      'delete': 'Futa',
      'export': 'Toa Ripoti',
      'search': 'Tafuta',
      'no_incidents': 'Hakuna matukio yaliyorekodiwa',

      // Trusted Contacts
      'trusted_contacts': 'Watu wa Kuaminika',
      'add_contact': 'Ongeza Mwasiliani',
      'contact_name': 'Jina la Mwasiliani',
      'phone_number': 'Nambari ya Simu',
      'contact_type': 'Aina ya Mwasiliani',
      'emergency_contact': 'Mwasiliani wa Dharura',
      'custom_message': 'Ujumbe Maalum wa Tahadhari (Hiari)',
      'family': 'Familia',
      'friend': 'Rafiki',
      'mobilizer': 'Mtangazaji wa Jamii',
      'no_contacts': 'Hakuna watu wa kuaminika walioongezwa',

      // Settings
      'language': 'Lugha',
      'english': 'Kiingereza',
      'swahili': 'Kiswahili',
      'panic_trigger': 'Kichocheo cha Kitufe cha Dharura',
      'shake': 'Tikisa Simu',
      'double_tap': 'Bonyeza Mara Mbili',
      'volume': 'Vitufe vya Sauti',
      'notifications': 'Arifa',
      'disguise_mode': 'Hali ya Kujificha',
      'auto_lock': 'Kufunga Kiotomatiki',
      'minutes': 'dakika',
      'change_pin': 'Badilisha PIN',
      'about': 'Kuhusu',
      'privacy_policy': 'Sera ya Faragha',
      'delete_account': 'Futa Akaunti',

      // Resources
      'what_is_sv': 'Vurugu za Kingono ni Nini',
      'your_rights': 'Haki Zako Baada ya Shambulio',
      'health_support': 'Msaada wa Afya na Matibabu',
      'legal_rights': 'Haki za Kisheria na Kuripoti',
      'psychological_support': 'Msaada wa Kisaikolojia',
      'myths_facts': 'Hadithi za Uwongo dhidi ya Ukweli',
      'resources_info': 'Rasilimali na Taarifa',

      // Common Actions
      'yes': 'Ndiyo',
      'no': 'Hapana',
      'ok': 'Sawa',
      'back': 'Rudi',
      'next': 'Ifuatayo',
      'done': 'Imekamilika',
      'edit': 'Hariri',
      'update': 'Sasisha',
      'close': 'Funga',

      // Messages
      'success': 'Mafanikio',
      'error': 'Kosa',
      'warning': 'Onyo',
      'confirm': 'Thibitisha',
      'are_you_sure': 'Una uhakika?',
      'cannot_undo': 'Hatua hii haiwezi kutenduliwa.',
      'language_updated': 'Lugha imesasishwa',

      // First Response Screen - Additional
      'move_to_safe_location':
          'Hamia mahali salama mara moja. Ikiwa inawezekana, piga simu mtu unayemwamini.',
      'leave_dangerous_situation': 'Acha hali hatari',
      'go_to_public_place': 'Nenda mahali pa umma ikiwa inahitajika',
      'contact_trusted_person': 'Wasiliana na mtu unayemwamini',
      'this_crucial_for_medical':
          'Hii ni muhimu kwa sababu za kimatibabu na kisheria.',
      'do_not_wash': 'USIOSHE au kuogelea',
      'do_not_change_clothes': 'USIBADILISHE nguo',
      'do_not_eat_drink': 'USILE, usikunywe, au kusugua meno',
      'do_not_use_bathroom': 'UTUMIE choo ikiwa inawezekana',
      'do_not_comb_hair': 'UITA nywele',
      'keep_clothes_paper_bag':
          'Weka nguo katika mfuko wa karatasi (sio plastiki)',
      'go_to_gbvrc_72_hours':
          'Nenda GBVRC ya karibu ndani ya masaa 72 kwa PEP (kuzuia VVU).',
      'request_hiv_pep': 'Omba VVU PEP - ndani ya masaa 72',
      'request_emergency_contraception':
          'Omba kuzuia dharura wa ujauzito - ndani ya masaa 120',
      'get_treatment_injuries': 'Pata matibabu ya jeraha',
      'request_forensic_examination': 'Omba uchunguzi wa forensic',
      'get_tested_stis': 'Jifanyie uchunguzi wa magonjwa ya zinaa',
      'request_counseling_services': 'Omba huduma za ushauri',
      'file_report_gbv_desk':
          'Fanya ripoti kwenye dawati la GBV. Una haki ya kutibiwa kwa heshima.',
      'go_to_police_gbv_desk': 'Nenda polisi dawati la GBV karibu',
      'ask_ob_number': 'Omba nambari ya OB (Kitabu cha Tukio)',
      'request_p3_form': 'Omba fomu ya P3 (fomu ya kimatibabu-kisheria)',
      'get_copy_statement': 'Pata nakala ya kauli yako',
      'note_officer_details': 'Nuta jina la afisa na nambari ya badge',
      'write_while_fresh': 'Andika kilichotokea wakati bado kipo akilini.',
      'date_time_incident': 'Tarehe na saa ya tukio',
      'location_details': 'Maelezo ya mahali',
      'description_perpetrator': 'Maelezo ya mhalifu',
      'names_witnesses': 'Majina ya mashahidi',
      'what_was_said_done': 'Kile kilichosemwa na kufanywa',
      'contact_counseling':
          'Wasiliana na huduma za ushauri. Huhitaji kupitia hii peke yako.',
      'preserve_evidence': 'Linda Ushahidi',
      'seek_medical_care': 'Tafuta Huduma za Afya HARAKA',
      'report_to_police': 'Ripoti kwa Polisi',
      'document_everything': 'Andika Kila Kitu',
      'seek_support': 'Tafuta Msaada',

      // Login Screen - Additional
      'too_many_attempts': 'Jaribu nyingi sana. Tafadhali subiri',
      'incorrect_pin': 'PIN si sahihi',
      'attempts_remaining': 'jaribu zilizobaki',
      'login_failed': 'Kuingia kumeshindikana',
      'enter_your_pin': 'Weka PIN Yako',
      'app_icon': 'Alama ya Programu',
      'you_are_safe_here':
          'Uko salama hapa. Taarifa zako zote ni za siri na zinaweza kulindwa.',

      // Incident Log Screen - Additional
      'no_incidents_recorded': 'Hakuna matukio yaliyorekodiwa',
      'tap_plus_document': 'Bonyeza kitufe + ili kuandika tukio',
      'failed_to_load_incidents': 'Imeshindikana kupakia matukio',
      'search_failed': 'Utafutaji umeshindikana',

      // Splash Screen
      'privacy_notice':
          'Faragha yako inaweza kulindwa. Taarifa zote zimefichwa na salama.',

      // Onboarding Screen
      'welcome_to_app': 'Karibu kwa Binti Salama',
      'safe_app_for_girls':
          'Programu salama kwa wasichana kuripoti na kupata msaada',
      'get_started': 'Anza',
      'your_journey_to_safety': 'Safari Yako kwa Usalama',
      'create_secure_pin': 'Unda PIN salama kulinda akaunti yako',
      'pin_required': 'PIN Inahitajika',
      'find_support_services': 'Tafuta huduma za msaada karibu na wewe',
      'services_near_you': 'Huduma Karibu na Wewe',
      'access_resources': 'Fikiria rasilimali na pata mwongozo',
      'knowledge_is_power': 'Maarifa ni Nguvu',

      // Service Locator Screen - Additional
      'no_services_found': 'Hakuna huduma zilizoonekana',
      'enable_location': 'Tafadhali wezesha huduma za mahali',
      'location_permission_denied': 'Ruhusa ya mahali ilikataliwa',
      'km_away': 'km mbali',
      'open_now': 'Wazi Sasa',
      'closed': 'Imefungwa',
      'phone': 'Simu',
      'address': 'Anuani',
      'opening_hours': 'Masaa ya Kufunguliwa',
      'find_services_title': 'Tafuta Huduma',
      'locate_support_near_you': 'Tafuta msaada karibu na wewe',
      'search_by_name_or_location': 'Tafuta kwa jina au mahali...',
      'all_services': 'Huduma Zote',
      'showing_services': 'Inaonyesha huduma {count} katika {county}',
      'filter_by_county': 'Chuja kwa kaunti',
      'clear_filters': 'Futa vichujio',
      'location_services': 'Huduma za Mahali',
      'enable_location_description':
          'Wezesha huduma za mahali ili kupata huduma za karibu na wewe',
      'enable_location_button': 'Wezesha Mahali →',
      'need_help_choosing': 'Unahitaji Msaada wa Kuchagua?',
      'need_help_description':
          'Huduma zote zilizoorodheshwa ni za siri na zimefunzwa kusaidia waliosalia. Huduma za kirafiki kwa vijana zimeandaliwa maalum kwa vijana.',
      'learn_more_about_services': 'Jifunze zaidi kuhusu huduma →',
      'call_now': 'Piga Simu Sasa',
      'location_not_available': 'Mahali haipatikani',
      'your_location': 'Mahali Pako',
      'services_offered': 'Huduma Zinazotolewa:',
      'failed_to_load_services': 'Imeshindikana kupakia huduma',
      'could_not_make_call': 'Haiwezekani kupiga simu',
      'could_not_open_maps': 'Haiwezekani kufungua ramani',

      // Resources Screen - Detailed Content
      'types_of_sexual_violence': 'Aina za Vurugu za Kingono',
      'rape': 'Ubakaji',
      'sexual_assault': 'Shambulio la Kingono',
      'child_sexual_abuse': 'Ubakaji wa Watoto',
      'sexual_harassment': 'Taharuki za Kingono',
      'sexual_exploitation': 'Kutumia kwa Jumla Kingono',
      'what_is_consent': 'Idhini ni Nini?',
      'consent_freely_given':
          'Idhini inamaanisha kukubaliana kwa hiari na shughuli za kingono',
      'consent_must_be': 'Idhini lazima iwe:',
      'given_freely':
          'Imetolewa kwa hiari bila kufanyika, kulazimisha, au kucheza ushoga',
      'informed': 'Iliyoambatanisha - Kuelewa kile unachokubali',
      'reversible':
          'Inaweza kubadilika - Unaweza kubadilisha akili yako wakati wowote',
      'specific': 'Maalum - Kukubali kitu hakina maana ya kukubali kila kitu',
      'who_cannot_consent': 'Nani Hawezi Kutoa Idhini',
      'children_minors': 'Watoto na wasimu',
      'asleep_unconscious': 'Mtu aliyefungwa au akiwa bila fahamu',
      'incapacitated_by_alcohol':
          'Mtu akiwa amepoteza akili kwa sababu ya pombe au dawa',
      'mental_disabilities': 'Mtu ana ulemavu fulani wa akili',
      'forced_threatened_coerced': 'Mtu akikuzwa, kutishwa, au kulazimishwa',
      'remember_not_your_fault':
          'Kumbuka: Ikiwa haukukubali, si kuwa yako. Una haki ya kusema hapana wakati wowote.',
      'learn_empower_yourself': 'Jifunze na Jijenge',
      'learn_empower_description':
          'Kuelewa haki zako na chaguzi zako husaidia kufanya maamuzi yenye maarifa. Maarifa ni zana yenye nguvu ya uponyaji.',
      'what_is_sexual_violence_title': 'Vurugu za Kingono ni Nini?',
      'what_is_sexual_violence_description':
          'Kuelewa ufafanuzi, aina, na idhini.',
      'your_rights_after_assault_title': 'Haki Zako Baada ya Shambulio',
      'your_rights_after_assault_description':
          'Ulinzi wa kisheria na kile unachostahili.',
      'health_medical_support_title': 'Msaada wa Afya na Matibabu',
      'health_medical_support_description':
          'Muda wa PEP, huduma za GBVRC, na matibabu ya ufuataji.',
      'legal_rights_reporting_title': 'Haki za Kisheria na Kuripoti',
      'legal_rights_reporting_description':
          'Sheria ya Makosa ya Kingono na taratibu za mahakama.',
      'psychological_support_title': 'Msaada wa Kisaikolojia',
      'psychological_support_description':
          'Mwitikio wa kawaida, mikakati ya kukabiliana, na uponyaji.',
      'myths_vs_facts_title': 'Hadithi za Uwongo dhidi ya Ukweli',
      'myths_vs_facts_description': 'Kukanusha dhana potofu za kawaida.',
      'take_your_time': 'Chukua Muda Wako',
      'take_your_time_description':
          'Hakuna haraka ya kusoma kila kitu mara moja. Rudi kwenye rasilimali hizi wakati wowote unapohitaji. Uponyaji hufanyika kwa kasi yako mwenyewe.',
      'need_to_talk': 'Unahitaji Kuongea?',
      'need_to_talk_description':
          'Ikiwa unahitaji msaada wa haraka, simu zetu za msaada zinapatikana masaa 24/7.',

      // Settings Screen - Additional
      'account_settings': 'Mipangilio ya Akaunti',
      'general': 'Jumla',
      'privacy_security': 'Faragha na Usalama',
      'hide_app_name': 'Ficha jina la programu na alama',
      'enable_notifications': 'Wezesha arifa za programu',
      'about_app': 'Kuhusu Binti Salama',
      'danger_zone': 'Eneo Hatari',
      'delete_all_data': 'Futa Taarifa Zote',
      'confirm_pin_change': 'Thibitisha Badilisha PIN',
      'old_pin': 'PIN ya Zamani',
      'new_pin': 'PIN Mpya',
      'confirm_new_pin': 'Thibitisha PIN Mpya',
      'pin_changed_successfully': 'PIN imebadilishwa kwa mafanikio',
      'pins_do_not_match': 'PIN hazifanani',
      'confirm_account_deletion': 'Thibitisha Kufuta Akaunti',
      'delete_account_warning':
          'Hatua hii itafuta akaunti yako na taarifa zote. Haiwezi kutenduliwa.',
      'app_version': 'Toleo la Programu',
      'last_updated': 'Ilisasishwa Mwisho',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  // Convenience getters for common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get home => translate('home');
  String get services => translate('services');
  String get settings => translate('settings');
  String get emergency => translate('emergency');
  String get yes => translate('yes');
  String get no => translate('no');
  String get save => translate('save');
  String get cancel => translate('cancel');
}

// Helper extension for easy access
extension LocalizationContext on String {
  String localized(String languageCode) {
    final localizations = AppLocalizations(languageCode);
    return localizations.translate(this);
  }
}
