# Localization Helper - Quick Reference

## ✅ Already Localized Screens
- `home_screen.dart` - Welcome, emergency, quick access
- `splash_screen.dart` - App name, tagline, privacy notice
- `login_screen.dart` - Welcome, PIN labels, forgot PIN
- `settings_screen.dart` - All sections and labels
- `incident_log_screen.dart` - Empty state messages
- `first_response_screen.dart` - AppBar title

## 📋 Remaining Screens & Quick Fix

For each remaining screen, add these 2 lines near the top of the `build()` method:

```dart
final languageProvider = Provider.of<LanguageProvider?>(context);
final t = languageProvider?.t;
```

Then wrap all Text widgets like this:
```dart
// Instead of:
Text('Label')

// Use:
Text(t?.translate('label_key') ?? 'Label')
```

## 🎯 Common String Replacements

### First Response Screen (first_response_screen.dart)
```dart
// Step titles
'step_1' through 'step_6'

// Action items
'leave_dangerous_situation', 'do_not_wash', 'request_hiv_pep', 
'go_to_police_gbv_desk', 'date_time_incident', 'contact_counseling'

// Descriptions
'move_to_safe_location', 'this_crucial_for_medical', 'go_to_gbvrc_72_hours'
```

### Resources Screen (resources_screen.dart)
```dart
// Main titles
'what_is_sv', 'your_rights', 'health_support', 'legal_rights',
'psychological_support', 'myths_facts'

// Content labels
'types_of_sexual_violence', 'rape', 'sexual_assault', 'what_is_consent',
'who_cannot_consent', 'children_minors', 'remember_not_your_fault'
```

### Service Locator Screen (service_locator_screen.dart)
```dart
// Main labels
'find_services', 'find_nearest', 'search_services', 'all_services',
'nearest_services', 'km_away', 'open_now', 'closed'

// Service details
'phone', 'address', 'opening_hours', 'youth_friendly', 'no_services_found'
```

### Onboarding Screen (onboarding_screen.dart)
```dart
// Onboarding content
'welcome_to_app', 'safe_app_for_girls', 'get_started',
'your_journey_to_safety', 'create_secure_pin', 'pin_required',
'find_support_services', 'services_near_you', 'access_resources',
'knowledge_is_power'
```

## 🚀 Batch Replace Template

For each screen, save this as a template and customize:

```dart
// ADD TO IMPORTS:
import '../services/language_provider.dart';

// ADD TO BUILD METHOD:
@override
Widget build(BuildContext context) {
  final languageProvider = Provider.of<LanguageProvider?>(context);
  final t = languageProvider?.t;
  
  // Then wrap all Text with: t?.translate('key') ?? 'fallback'
}
```

## ✨ Keys Already in localization.dart

All 200+ translation keys exist. Use them freely:
- App navigation: `home`, `emergency`, `resources`, `settings`, `services`
- Common actions: `save`, `cancel`, `delete`, `edit`, `update`, `back`, `next`
- Status messages: `success`, `error`, `warning`, `confirm`
- Settings: `language`, `english`, `swahili`, `notifications`, `auto_lock`

## 📝 Example: Complete Replacement

### BEFORE:
```dart
Text('Find Services'),
Text('Nearest Services'),
Text('Search services...'),
```

### AFTER:
```dart
Text(t?.translate('find_services') ?? 'Find Services'),
Text(t?.translate('nearest_services') ?? 'Nearest Services'),
Text(t?.translate('search_services') ?? 'Search services...'),
```

## 🎓 Testing Localization

1. Run app: `flutter run`
2. Open Settings
3. Change Language → Kiswahili
4. Navigate to localized screens - should see Swahili text immediately!
5. Change back to English - should update instantly

## 💡 Pro Tip

You can do bulk find-replace in VS Code:
- Open Find & Replace (Ctrl+H)
- Find: `Text\('([^']*)'\)`
- Replace with: `Text(t?.translate('$1') ?? '$1')`

This regex will catch basic cases. Manual verification needed for edge cases.

---

**Status**: 5 critical screens done, 4+ screens ready for localization. 
**All translations**: ✅ Complete in localization.dart
**Provider system**: ✅ Working and propagating changes
**Next step**: Apply the pattern above to remaining screens when ready
