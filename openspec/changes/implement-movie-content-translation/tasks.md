# Tasks - Movie Content Translation

## Translation Service Layer
- [ ] **Create `TranslationService`** - Core service for translation API integration
  - [ ] Implement API client for translation service (LibreTranslate or Google Translate)
  - [ ] Create method `translateText(String text, String targetLang, String sourceLang)` 
  - [ ] Add batch translation support `translateBatch(List<String> texts, String targetLang)`
  - [ ] Implement error handling and retry logic with exponential backoff
  - [ ] Add language code mapping (LanguageCode enum → API language codes)

- [ ] **Create `TranslationCache`** - Cache layer for translated content
  - [ ] Implement cache using Hive or SharedPreferences
  - [ ] Create cache key format: `movie_id:field_name:target_lang`
  - [ ] Add cache expiration (e.g., 30 days)
  - [ ] Implement LRU eviction when cache exceeds 1000 entries
  - [ ] Add cache invalidation on source content update

## Data Model Updates
- [ ] **Extend `VideoItem` model**
  - [ ] Add optional `translatedTitle` field
  - [ ] Add optional `translatedDescription` field
  - [ ] Update `copyWith` method to include new fields
  - [ ] Ensure backward compatibility (fields nullable)

- [ ] **Create `TranslatedMovie` wrapper** (alternative approach)
  - [ ] Create wrapper class holding original + translated content
  - [ ] Method to get title/description based on current language
  - [ ] Preserve original `VideoItem` immutability

## Controller Integration
- [ ] **Create `TranslationController`**
  - [ ] Extend `BaseController` per project structure
  - [ ] Inject `TranslationService` and `TranslationCache`
  - [ ] Method `translateMovie(VideoItem movie, LanguageCode targetLang)`
  - [ ] Method `translateMovieList(List<VideoItem> movies, LanguageCode targetLang)`
  - [ ] Implement loading states during translation
  - [ ] Handle errors and fallback to original text

- [ ] **Update `LanguageController`**
  - [ ] Trigger translation refresh on language change in `onSubmit()`
  - [ ] Notify home/detail controllers to refresh translations
  - [ ] Use GetX reactive updates or event bus

- [ ] **Update `HomeController`** (if exists, or relevant movie list controller)
  - [ ] Listen to language change events
  - [ ] Translate visible movies on language change
  - [ ] Implement lazy loading translation for scrolled items
  - [ ] Preserve scroll position during refresh

- [ ] **Update `DetailController`** 
  - [ ] Translate movie details when page loads
  - [ ] Check cache first before calling API
  - [ ] Update UI reactively when translation completes

## UI Updates
- [ ] **Update home screen movie cards**
  - [ ] Display `translatedTitle` if available, else original `title`
  - [ ] Show loading shimmer during translation
  - [ ] Handle long translated titles (ellipsis/multiline)

- [ ] **Update detail page**
  - [ ] Display `translatedTitle` and `translatedDescription`
  - [ ] Show original title as subtitle (optional - "Original: ...")
  - [ ] Add loading indicator for translation in progress

- [ ] **Add translation error handling UI**
  - [ ] Show toast/snackbar on translation failure
  - [ ] Fallback to original text with subtle indicator icon

## Configuration & Dependencies
- [ ] **Add translation service configuration**
  - [ ] Add API endpoint and key to environment config (if Google Translate)
  - [ ] Or configure self-hosted LibreTranslate URL
  - [ ] Add to `lib/app/config/environment.dart` or similar

- [ ] **Update `pubspec.yaml`**
  - [ ] Add `http` or `dio` dependency if not present (already have `dio`)
  - [ ] Add `hive` and `hive_flutter` for cache (or use existing SharedPreferences)

## Testing & Verification
- [ ] **Unit Tests**
  - [ ] Test `TranslationService.translateText()` with mock API
  - [ ] Test `TranslationCache` cache hit/miss scenarios
  - [ ] Test `TranslationController.translateMovie()` flow
  - [ ] Test language code mapping accuracy

- [ ] **Integration Tests**
  - [ ] Test end-to-end translation flow from language selection to display
  - [ ] Test cache persistence across app restarts
  - [ ] Test batch translation performance with 20+ movies

- [ ] **Manual Testing**
  - [ ] Switch language in settings → verify home screen movies translate
  - [ ] Open movie detail → verify title and description translate
  - [ ] Test with poor network → verify fallback to original text
  - [ ] Test scroll performance with 100+ movies

## Documentation
- [ ] **Update README** (if exists)
  - [ ] Document translation service setup instructions
  - [ ] Add API key configuration steps

- [ ] **Code comments**
  - [ ] Document translation cache format and expiration logic
  - [ ] Add inline comments for language code mappings

---

## Task Execution Order
1. **Foundation**: Translation service + cache (can be tested in isolation)
2. **Models**: Update `VideoItem` with translated fields
3. **Controllers**: Create `TranslationController`, update existing controllers
4. **UI**: Update views to display translated content
5. **Testing**: Unit → Integration → Manual
6. **Polish**: Error handling, loading states, performance optimization
