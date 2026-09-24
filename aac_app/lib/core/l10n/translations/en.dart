/// English (base) UI strings. Every other locale map must contain the same
/// keys — this is enforced by a debug-mode check in AppLocalizations.
const Map<String, String> enStrings = {
  // App
  'appName': 'VoicePath',

  // Home / profile selection
  'whoIsCommunicating': 'Who is communicating?',
  'addProfile': 'Add profile',
  'editProfile': 'Edit profile',
  'newProfile': 'New profile',
  'profileName': 'Name',
  'deleteProfile': 'Delete profile',
  'deleteProfileConfirm':
      'This removes the profile and its saved vocabulary from this device.',

  // Navigation
  'board': 'Board',
  'textMode': 'Text',
  'categories': 'Categories',
  'settings': 'Settings',
  'caregiver': 'Caregiver',

  // Board / sentence bar
  'speak': 'Speak',
  'delete': 'Delete',
  'clear': 'Clear',
  'repeat': 'Repeat',
  'stop': 'Stop',
  'tapToBuildSentence': 'Tap words to build a sentence',
  'allCategories': 'All',

  // Text mode
  'typeMessage': 'Type a message',
  'predictions': 'Suggestions',

  // Vocabulary editor
  'editButton': 'Edit button',
  'addButton': 'Add button',
  'label': 'Label',
  'spokenPhrase': 'Spoken phrase (optional)',
  'chooseImage': 'Choose image',
  'takePhoto': 'Take photo',
  'chooseFromGallery': 'Choose from gallery',
  'useIcon': 'Use symbol',
  'category': 'Category',
  'newCategory': 'New category',
  'categoryName': 'Category name',
  'gridSize': 'Grid size',
  'save': 'Save',
  'cancel': 'Cancel',
  'moveButton': 'Move',
  'deleteButtonConfirm': 'Remove this button from the board?',

  // Caregiver
  'enterPin': 'Enter PIN',
  'setPin': 'Set a PIN',
  'confirmPin': 'Confirm PIN',
  'pinIncorrect': 'Incorrect PIN',
  'pinTooShort': 'PIN must be at least 4 digits',
  'pinMismatch': 'PINs do not match',
  'unlockWithBiometrics': 'Unlock with biometrics',
  'caregiverSettings': 'Caregiver settings',
  'lockEditing': 'Lock editing with PIN',
  'disableLockConfirm': 'Turn off the PIN lock for this profile?',
  'exitCaregiverMode': 'Exit caregiver mode',

  // Settings
  'appearance': 'Appearance',
  'highContrast': 'High contrast',
  'fontSize': 'Text size',
  'buttonSize': 'Button size',
  'buttonSpacing': 'Button spacing',
  'reducedAnimation': 'Reduce animation',
  'language': 'Language',
  'voice': 'Voice',
  'speechRate': 'Speech rate',
  'pitch': 'Pitch',
  'volume': 'Volume',
  'ttsSettings': 'Speech settings',
  'accessibility': 'Accessibility',
  'testVoice': 'Test voice',

  // Backup
  'backupRestore': 'Backup & restore',
  'exportBackup': 'Export backup',
  'importBackup': 'Import backup',
  'backupSuccess': 'Backup saved',
  'restoreSuccess': 'Profile restored',
  'restoreConfirm':
      'Importing will add this backup as a new profile on this device.',
  'exportDataDescription':
      'Save a copy of this profile\'s vocabulary and settings as a file you control.',

  // Privacy
  'deleteAllData': 'Delete all data on this device',
  'deleteAllDataConfirm':
      'This permanently removes every profile, vocabulary item, and setting from this device. This cannot be undone.',

  // Errors (kept plain-language; no technical detail shown to users)
  'somethingWentWrong': 'Something went wrong. Please try again.',
  'imageUnavailable': 'Image unavailable',
  'speechUnavailable': 'Speech is unavailable right now',
  'noVocabularyYet': 'No buttons here yet. Open Caregiver mode to add some.',
  'ok': 'OK',
  'retry': 'Retry',
};
