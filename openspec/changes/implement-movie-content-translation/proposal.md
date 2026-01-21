# Movie Content Translation

## Overview
Enable automatic translation of movie content (title, description) when users select their preferred language in the language settings. Currently, the app supports 7 languages for UI translation (en, es, hi, de, fr, id, pt), but movie content from the Ophim API is only in Vietnamese. This change will translate movie metadata on-the-fly based on the selected language.

## Background Context
- **Current State**: The app has a language selection feature in `lib/features/language` that only translates UI strings via GetX localization
- **Movie Data Source**: Movies come from Ophim API (Vietnamese) with fields `name`, `originName`, and `content` in `MovieModel`
- **Supported Languages**: 7 languages defined in `LanguageCode` enum and `MTranslations`

## Problem Statement
When users select a language (e.g., English, Spanish), only the app UI changes language. Movie titles and descriptions remain in Vietnamese, creating a poor user experience for non-Vietnamese speakers.

## Proposed Solution
Integrate a translation service (LibreTranslate or Google Translate API) to automatically translate movie metadata when:
1. User selects a language in language settings
2. Movie list is displayed on home screen
3. Movie details are viewed

The translation will be cached to minimize API calls and improve performance.

## User Impact
- **Positive**: Users can read movie titles and descriptions in their preferred language
- **Performance**: Slight delay on first load (mitigated by caching)
- **Network**: Additional API calls for translation (cached after first request)

## Technical Approach
1. **Translation Service**: Create `TranslationService` with LibreTranslate or Google Translate integration
2. **Cache Layer**: Implement translation cache using SharedPreferences or Hive
3. **Model Extension**: Extend `VideoItem` and `MovieModel` with translated fields
4. **Language Integration**: Hook into existing `LanguageController` to trigger translation refresh
5. **UI Updates**: Update movie list and detail pages to display translated content

## Dependencies
- Translation API (LibreTranslate self-hosted or Google Translate API)
- Cache storage (SharedPreferences or Hive - already in project)
- Network connectivity

## Open Questions
> [!IMPORTANT]
> **User Input Required**
> 1. **Which translation service should we use?**
>    - LibreTranslate (open-source, free self-hosted option - requires server setup)
>    - Google Translate API (paid, more accurate - requires API key and billing)
>    - Other preference?
> 
> 2. **Performance vs Freshness Trade-off**
>    - How long should translations be cached? (e.g., 7 days, 30 days, permanent)
>    - Should we translate all movies on home screen or only visible ones?
> 
> 3. **Fallback Behavior**
>    - If translation fails, should we show original Vietnamese text or show an error?
