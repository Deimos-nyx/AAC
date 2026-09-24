/// Real starter vocabulary used to populate a brand-new profile so the app
/// is immediately usable — per spec, we never ship empty/placeholder
/// buttons for core functionality.
///
/// Design note: seeding writes a plain, editable `label`/`spoken_phrase`
/// into the buttons table in whichever language the profile is created
/// with. It is NOT a live translation binding — once seeded, a button is
/// just normal data a caregiver can rename like any other (per spec section
/// 3, "the user must be able to customize everything"). If a profile's
/// language is changed later, existing button text is left alone, exactly
/// like a caregiver's own edits would be.
///
/// Translation note: the Nepali glosses below are a practical starting
/// point, not a clinically-reviewed AAC core word list. Several English
/// core words (e.g. "don't") are grammatical particles that don't map onto
/// a single invariant Nepali word — we've picked the closest common usage.
/// Before real-world deployment this list should be reviewed by a
/// Nepali-speaking speech-language pathologist.
library;

class SeedButton {
  final String labelEn;
  final String labelNe;
  final String emoji;
  final String? categoryKey; // null => core vocabulary, shown on every board
  final bool isCore;

  const SeedButton({
    required this.labelEn,
    required this.labelNe,
    required this.emoji,
    this.categoryKey,
    this.isCore = false,
  });

  String labelFor(String localeCode) => localeCode == 'ne' ? labelNe : labelEn;
}

class SeedCategory {
  final String key;
  final String nameEn;
  final String nameNe;
  final String iconEmoji;
  final String colorHex;

  const SeedCategory({
    required this.key,
    required this.nameEn,
    required this.nameNe,
    required this.iconEmoji,
    required this.colorHex,
  });

  String nameFor(String localeCode) => localeCode == 'ne' ? nameNe : nameEn;
}

/// Fringe vocabulary categories, in the order they appear as tabs.
const List<SeedCategory> seedCategories = [
  SeedCategory(
    key: 'food',
    nameEn: 'Food',
    nameNe: 'खाना',
    iconEmoji: '🍽️',
    colorHex: 'FFF6C6C0',
  ),
  SeedCategory(
    key: 'drinks',
    nameEn: 'Drinks',
    nameNe: 'पेय',
    iconEmoji: '🥤',
    colorHex: 'FFBFD9F2',
  ),
  SeedCategory(
    key: 'people',
    nameEn: 'People',
    nameNe: 'मानिसहरू',
    iconEmoji: '🧑',
    colorHex: 'FFFCE7B0',
  ),
  SeedCategory(
    key: 'places',
    nameEn: 'Places',
    nameNe: 'ठाउँहरू',
    iconEmoji: '🏠',
    colorHex: 'FFD9C7EC',
  ),
  SeedCategory(
    key: 'toys',
    nameEn: 'Toys',
    nameNe: 'खेलौना',
    iconEmoji: '🧸',
    colorHex: 'FFFFD9A8',
  ),
  SeedCategory(
    key: 'activities',
    nameEn: 'Activities',
    nameNe: 'गतिविधि',
    iconEmoji: '⚽',
    colorHex: 'FFB9DFC4',
  ),
  SeedCategory(
    key: 'school',
    nameEn: 'School',
    nameNe: 'विद्यालय',
    iconEmoji: '🎒',
    colorHex: 'FFC9E4DE',
  ),
  SeedCategory(
    key: 'therapy',
    nameEn: 'Therapy',
    nameNe: 'थेरापी',
    iconEmoji: '🧩',
    colorHex: 'FFE3E3DD',
  ),
  SeedCategory(
    key: 'feelings',
    nameEn: 'Feelings',
    nameNe: 'भावनाहरू',
    iconEmoji: '😊',
    colorHex: 'FFF3B8CE',
  ),
  SeedCategory(
    key: 'body',
    nameEn: 'Body',
    nameNe: 'शरीर',
    iconEmoji: '🧍',
    colorHex: 'FFBFD9F2',
  ),
  SeedCategory(
    key: 'clothing',
    nameEn: 'Clothing',
    nameNe: 'लुगा',
    iconEmoji: '👕',
    colorHex: 'FFFCE7B0',
  ),
  SeedCategory(
    key: 'animals',
    nameEn: 'Animals',
    nameNe: 'जनावर',
    iconEmoji: '🐶',
    colorHex: 'FFB9DFC4',
  ),
  SeedCategory(
    key: 'social',
    nameEn: 'Social phrases',
    nameNe: 'सामाजिक वाक्यहरू',
    iconEmoji: '👋',
    colorHex: 'FFFFD9A8',
  ),
];

/// Core vocabulary — pinned on every board regardless of selected category,
/// per spec section 2. Ordering matters for motor planning, so this list is
/// the canonical order new profiles get.
const List<SeedButton> seedCoreButtons = [
  SeedButton(labelEn: 'I', labelNe: 'म', emoji: '🙋', isCore: true),
  SeedButton(labelEn: 'you', labelNe: 'तिमी', emoji: '🫵', isCore: true),
  SeedButton(labelEn: 'want', labelNe: 'चाहनु', emoji: '🤲', isCore: true),
  SeedButton(labelEn: "don't", labelNe: 'होइन', emoji: '🚫', isCore: true),
  SeedButton(labelEn: 'more', labelNe: 'थप', emoji: '➕', isCore: true),
  SeedButton(labelEn: 'help', labelNe: 'मद्दत', emoji: '🆘', isCore: true),
  SeedButton(labelEn: 'stop', labelNe: 'रोक', emoji: '✋', isCore: true),
  SeedButton(labelEn: 'go', labelNe: 'जानु', emoji: '🏃', isCore: true),
  SeedButton(labelEn: 'come', labelNe: 'आउनु', emoji: '👋', isCore: true),
  SeedButton(labelEn: 'like', labelNe: 'मनपर्छ', emoji: '👍', isCore: true),
  SeedButton(
    labelEn: "don't like",
    labelNe: 'मन पर्दैन',
    emoji: '👎',
    isCore: true,
  ),
  SeedButton(labelEn: 'yes', labelNe: 'हो', emoji: '✅', isCore: true),
  SeedButton(labelEn: 'no', labelNe: 'होइन', emoji: '❌', isCore: true),
  SeedButton(labelEn: 'what', labelNe: 'के', emoji: '❓', isCore: true),
  SeedButton(labelEn: 'where', labelNe: 'कहाँ', emoji: '📍', isCore: true),
  SeedButton(labelEn: 'who', labelNe: 'को', emoji: '🧑‍🤝‍🧑', isCore: true),
  SeedButton(labelEn: 'why', labelNe: 'किन', emoji: '❔', isCore: true),
  SeedButton(labelEn: 'finished', labelNe: 'सकियो', emoji: '🏁', isCore: true),
  SeedButton(labelEn: 'again', labelNe: 'फेरि', emoji: '🔁', isCore: true),
  SeedButton(labelEn: 'open', labelNe: 'खोल्नु', emoji: '🔓', isCore: true),
  SeedButton(labelEn: 'close', labelNe: 'बन्द', emoji: '🔒', isCore: true),
  SeedButton(labelEn: 'eat', labelNe: 'खानु', emoji: '🍴', isCore: true),
  SeedButton(labelEn: 'drink', labelNe: 'पिउनु', emoji: '🥤', isCore: true),
];

/// Fringe vocabulary, grouped by category key (see [seedCategories]).
const List<SeedButton> seedFringeButtons = [
  // Food
  SeedButton(labelEn: 'rice', labelNe: 'भात', emoji: '🍚', categoryKey: 'food'),
  SeedButton(
    labelEn: 'bread',
    labelNe: 'रोटी',
    emoji: '🍞',
    categoryKey: 'food',
  ),
  SeedButton(
    labelEn: 'vegetables',
    labelNe: 'तरकारी',
    emoji: '🥦',
    categoryKey: 'food',
  ),
  SeedButton(
    labelEn: 'fruit',
    labelNe: 'फलफूल',
    emoji: '🍎',
    categoryKey: 'food',
  ),
  SeedButton(
    labelEn: 'egg',
    labelNe: 'अन्डा',
    emoji: '🥚',
    categoryKey: 'food',
  ),
  SeedButton(
    labelEn: 'snack',
    labelNe: 'खाजा',
    emoji: '🍪',
    categoryKey: 'food',
  ),
  SeedButton(
    labelEn: 'noodles',
    labelNe: 'चाउचाउ',
    emoji: '🍜',
    categoryKey: 'food',
  ),

  // Drinks
  SeedButton(
    labelEn: 'water',
    labelNe: 'पानी',
    emoji: '💧',
    categoryKey: 'drinks',
  ),
  SeedButton(
    labelEn: 'milk',
    labelNe: 'दूध',
    emoji: '🥛',
    categoryKey: 'drinks',
  ),
  SeedButton(
    labelEn: 'juice',
    labelNe: 'जुस',
    emoji: '🧃',
    categoryKey: 'drinks',
  ),
  SeedButton(
    labelEn: 'tea',
    labelNe: 'चिया',
    emoji: '🍵',
    categoryKey: 'drinks',
  ),

  // People
  SeedButton(
    labelEn: 'mom',
    labelNe: 'आमा',
    emoji: '👩',
    categoryKey: 'people',
  ),
  SeedButton(
    labelEn: 'dad',
    labelNe: 'बुबा',
    emoji: '👨',
    categoryKey: 'people',
  ),
  SeedButton(
    labelEn: 'friend',
    labelNe: 'साथी',
    emoji: '🧑‍🤝‍🧑',
    categoryKey: 'people',
  ),
  SeedButton(
    labelEn: 'teacher',
    labelNe: 'शिक्षक',
    emoji: '🧑‍🏫',
    categoryKey: 'people',
  ),
  SeedButton(
    labelEn: 'sister',
    labelNe: 'दिदी',
    emoji: '👧',
    categoryKey: 'people',
  ),
  SeedButton(
    labelEn: 'brother',
    labelNe: 'दाइ',
    emoji: '👦',
    categoryKey: 'people',
  ),
  SeedButton(
    labelEn: 'doctor',
    labelNe: 'डाक्टर',
    emoji: '🩺',
    categoryKey: 'people',
  ),

  // Places
  SeedButton(
    labelEn: 'home',
    labelNe: 'घर',
    emoji: '🏠',
    categoryKey: 'places',
  ),
  SeedButton(
    labelEn: 'school',
    labelNe: 'विद्यालय',
    emoji: '🏫',
    categoryKey: 'places',
  ),
  SeedButton(
    labelEn: 'park',
    labelNe: 'पार्क',
    emoji: '🌳',
    categoryKey: 'places',
  ),
  SeedButton(
    labelEn: 'bathroom',
    labelNe: 'शौचालय',
    emoji: '🚻',
    categoryKey: 'places',
  ),
  SeedButton(
    labelEn: 'outside',
    labelNe: 'बाहिर',
    emoji: '🌤️',
    categoryKey: 'places',
  ),
  SeedButton(
    labelEn: 'store',
    labelNe: 'पसल',
    emoji: '🏪',
    categoryKey: 'places',
  ),

  // Toys
  SeedButton(labelEn: 'ball', labelNe: 'बल', emoji: '⚽', categoryKey: 'toys'),
  SeedButton(labelEn: 'car', labelNe: 'गाडी', emoji: '🚗', categoryKey: 'toys'),
  SeedButton(
    labelEn: 'blocks',
    labelNe: 'ब्लक',
    emoji: '🧱',
    categoryKey: 'toys',
  ),
  SeedButton(
    labelEn: 'book',
    labelNe: 'किताब',
    emoji: '📖',
    categoryKey: 'toys',
  ),
  SeedButton(
    labelEn: 'puzzle',
    labelNe: 'पजल',
    emoji: '🧩',
    categoryKey: 'toys',
  ),

  // Activities
  SeedButton(
    labelEn: 'play',
    labelNe: 'खेल्नु',
    emoji: '🎮',
    categoryKey: 'activities',
  ),
  SeedButton(
    labelEn: 'read',
    labelNe: 'पढ्नु',
    emoji: '📚',
    categoryKey: 'activities',
  ),
  SeedButton(
    labelEn: 'draw',
    labelNe: 'चित्र बनाउनु',
    emoji: '🎨',
    categoryKey: 'activities',
  ),
  SeedButton(
    labelEn: 'sing',
    labelNe: 'गाउनु',
    emoji: '🎤',
    categoryKey: 'activities',
  ),
  SeedButton(
    labelEn: 'watch TV',
    labelNe: 'टिभी हेर्नु',
    emoji: '📺',
    categoryKey: 'activities',
  ),

  // School
  SeedButton(
    labelEn: 'pencil',
    labelNe: 'पेन्सिल',
    emoji: '✏️',
    categoryKey: 'school',
  ),
  SeedButton(
    labelEn: 'homework',
    labelNe: 'गृहकार्य',
    emoji: '📝',
    categoryKey: 'school',
  ),
  SeedButton(
    labelEn: 'classroom',
    labelNe: 'कक्षाकोठा',
    emoji: '🏫',
    categoryKey: 'school',
  ),
  SeedButton(
    labelEn: 'backpack',
    labelNe: 'झोला',
    emoji: '🎒',
    categoryKey: 'school',
  ),
  SeedButton(
    labelEn: 'recess',
    labelNe: 'विश्राम',
    emoji: '🛝',
    categoryKey: 'school',
  ),

  // Therapy
  SeedButton(
    labelEn: 'my turn',
    labelNe: 'मेरो पालो',
    emoji: '🙋',
    categoryKey: 'therapy',
  ),
  SeedButton(
    labelEn: 'your turn',
    labelNe: 'तिम्रो पालो',
    emoji: '👉',
    categoryKey: 'therapy',
  ),
  SeedButton(
    labelEn: 'break',
    labelNe: 'विश्राम',
    emoji: '⏸️',
    categoryKey: 'therapy',
  ),
  SeedButton(
    labelEn: 'good job',
    labelNe: 'राम्रो काम',
    emoji: '🌟',
    categoryKey: 'therapy',
  ),
  SeedButton(
    labelEn: 'try again',
    labelNe: 'फेरि प्रयास',
    emoji: '🔄',
    categoryKey: 'therapy',
  ),

  // Feelings
  SeedButton(
    labelEn: 'happy',
    labelNe: 'खुशी',
    emoji: '😊',
    categoryKey: 'feelings',
  ),
  SeedButton(
    labelEn: 'sad',
    labelNe: 'दुखी',
    emoji: '😢',
    categoryKey: 'feelings',
  ),
  SeedButton(
    labelEn: 'angry',
    labelNe: 'रिसाएको',
    emoji: '😠',
    categoryKey: 'feelings',
  ),
  SeedButton(
    labelEn: 'scared',
    labelNe: 'डराएको',
    emoji: '😨',
    categoryKey: 'feelings',
  ),
  SeedButton(
    labelEn: 'tired',
    labelNe: 'थकित',
    emoji: '😴',
    categoryKey: 'feelings',
  ),
  SeedButton(
    labelEn: 'sick',
    labelNe: 'बिरामी',
    emoji: '🤒',
    categoryKey: 'feelings',
  ),
  SeedButton(
    labelEn: 'hurt',
    labelNe: 'दुखेको',
    emoji: '🤕',
    categoryKey: 'feelings',
  ),

  // Body
  SeedButton(
    labelEn: 'head',
    labelNe: 'टाउको',
    emoji: '🗣️',
    categoryKey: 'body',
  ),
  SeedButton(
    labelEn: 'stomach',
    labelNe: 'पेट',
    emoji: '🫃',
    categoryKey: 'body',
  ),
  SeedButton(labelEn: 'hand', labelNe: 'हात', emoji: '✋', categoryKey: 'body'),
  SeedButton(
    labelEn: 'foot',
    labelNe: 'खुट्टा',
    emoji: '🦶',
    categoryKey: 'body',
  ),
  SeedButton(
    labelEn: 'tooth',
    labelNe: 'दाँत',
    emoji: '🦷',
    categoryKey: 'body',
  ),
  SeedButton(labelEn: 'ear', labelNe: 'कान', emoji: '👂', categoryKey: 'body'),
  SeedButton(
    labelEn: 'eye',
    labelNe: 'आँखा',
    emoji: '👁️',
    categoryKey: 'body',
  ),

  // Clothing
  SeedButton(
    labelEn: 'shirt',
    labelNe: 'शर्ट',
    emoji: '👕',
    categoryKey: 'clothing',
  ),
  SeedButton(
    labelEn: 'pants',
    labelNe: 'पाइन्ट',
    emoji: '👖',
    categoryKey: 'clothing',
  ),
  SeedButton(
    labelEn: 'shoes',
    labelNe: 'जुत्ता',
    emoji: '👟',
    categoryKey: 'clothing',
  ),
  SeedButton(
    labelEn: 'jacket',
    labelNe: 'ज्याकेट',
    emoji: '🧥',
    categoryKey: 'clothing',
  ),
  SeedButton(
    labelEn: 'socks',
    labelNe: 'मोजा',
    emoji: '🧦',
    categoryKey: 'clothing',
  ),

  // Animals
  SeedButton(
    labelEn: 'dog',
    labelNe: 'कुकुर',
    emoji: '🐶',
    categoryKey: 'animals',
  ),
  SeedButton(
    labelEn: 'cat',
    labelNe: 'बिरालो',
    emoji: '🐱',
    categoryKey: 'animals',
  ),
  SeedButton(
    labelEn: 'bird',
    labelNe: 'चरा',
    emoji: '🐦',
    categoryKey: 'animals',
  ),
  SeedButton(
    labelEn: 'cow',
    labelNe: 'गाई',
    emoji: '🐄',
    categoryKey: 'animals',
  ),
  SeedButton(
    labelEn: 'fish',
    labelNe: 'माछा',
    emoji: '🐟',
    categoryKey: 'animals',
  ),

  // Social phrases
  SeedButton(
    labelEn: 'hello',
    labelNe: 'नमस्ते',
    emoji: '👋',
    categoryKey: 'social',
  ),
  SeedButton(
    labelEn: 'goodbye',
    labelNe: 'फेरि भेटौंला',
    emoji: '🙏',
    categoryKey: 'social',
  ),
  SeedButton(
    labelEn: 'please',
    labelNe: 'कृपया',
    emoji: '🙏',
    categoryKey: 'social',
  ),
  SeedButton(
    labelEn: 'thank you',
    labelNe: 'धन्यवाद',
    emoji: '💐',
    categoryKey: 'social',
  ),
  SeedButton(
    labelEn: 'sorry',
    labelNe: 'माफ गर्नुहोस्',
    emoji: '😔',
    categoryKey: 'social',
  ),
  SeedButton(
    labelEn: 'I love you',
    labelNe: 'म तिमीलाई माया गर्छु',
    emoji: '❤️',
    categoryKey: 'social',
  ),
];
