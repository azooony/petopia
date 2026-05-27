// Static state survives widget rebuilds and navigation within a session.
// Two independent rotation axes:
//   • _visitCount  — increments only on actual navigation events (Home enter/re-enter).
//                    Drives the banner TEXT+BUTTON (9 cases) via [bannerIndex].
//   • _allIdx / _dogIdx / _catIdx — advance on every navigation AND category change.
//                    Drive the PET IMAGE shown inside the banner.
class BannerRotation {
  static const _all = [
    'cat1HP', 'dog1HP', 'cat2HP', 'dog2HP', 'cat3HP', 'dog3HP',
    'cat4HP', 'dog4HP', 'cat5HP', 'dog5HP', 'cat6HP', 'dog6HP',
    'cat7HP', 'dog7HP',
  ];
  static const _dogs = [
    'dog1HP', 'dog2HP', 'dog3HP', 'dog4HP', 'dog5HP', 'dog6HP', 'dog7HP',
  ];
  static const _cats = [
    'cat1HP', 'cat2HP', 'cat3HP', 'cat4HP', 'cat5HP', 'cat6HP', 'cat7HP',
  ];

  // Image indices — one per filter state.
  static int _allIdx = -1;
  static int _dogIdx = -1;
  static int _catIdx = -1;

  // Visit counter — drives the 9-case banner content rotation.
  // Starts at -1 so the first [advanceBannerIndex] call lands on index 0.
  static int _visitCount = -1;

  /// Index into the 9 BannerContent items.  Call [advanceBannerIndex] first.
  static int get bannerIndex => (_visitCount < 0 ? 0 : _visitCount) % 9;

  /// Call this once per navigation event (initState / didPopNext) BEFORE [advance].
  /// Do NOT call on category change — that would rotate the text unexpectedly.
  static void advanceBannerIndex() {
    _visitCount++;
  }

  /// Advances the image for [category] and returns the asset path.
  /// Called on navigation events AND on category changes.
  static String advance(String? category) {
    if (category == 'Dogs') {
      _dogIdx = (_dogIdx + 1) % _dogs.length;
      return 'assets/images/${_dogs[_dogIdx]}.png';
    } else if (category == 'Cats') {
      _catIdx = (_catIdx + 1) % _cats.length;
      return 'assets/images/${_cats[_catIdx]}.png';
    } else {
      _allIdx = (_allIdx + 1) % _all.length;
      return 'assets/images/${_all[_allIdx]}.png';
    }
  }

  /// Returns the *next* image path without advancing — used for preloading only.
  static String peek(String? category) {
    final list = _listFor(category);
    final next = (_idxFor(category) + 1) % list.length;
    return 'assets/images/${list[next]}.png';
  }

  static List<String> _listFor(String? category) {
    if (category == 'Dogs') return _dogs;
    if (category == 'Cats') return _cats;
    return _all;
  }

  static int _idxFor(String? category) {
    if (category == 'Dogs') return _dogIdx;
    if (category == 'Cats') return _catIdx;
    return _allIdx;
  }
}
