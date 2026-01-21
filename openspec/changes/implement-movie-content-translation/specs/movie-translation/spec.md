# Movie Translation Capability

## Overview
This spec defines the capability to translate movie content (titles, descriptions) from Vietnamese to user-selected languages in real-time, integrating with the existing language selection feature.

---

## ADDED Requirements

### Requirement: Translation Service Integration
The system SHALL integrate with a translation API service to translate movie content fields.

#### Scenario: Translate movie title from Vietnamese to English
**Given** a movie with Vietnamese title "Truyền Thuyết Về Công Chúa Hải Tặng"  
**And** user has selected English as their language  
**When** the movie is displayed  
**Then** the title should be translated to "The Legend of the Princess Sea"  
**And** the translation should be cached for future requests

#### Scenario: Translate movie description
**Given** a movie with Vietnamese description  
**And** user has selected Spanish language  
**When** the movie detail page is loaded  
**Then** the description should be translated to Spanish  
**And** display translated text within 2 seconds

#### Scenario: Handle translation API failure gracefully
**Given** translation API is unavailable  
**When** attempting to translate movie content  
**Then** system should display original Vietnamese text  
**And** log the error for monitoring  
**And** retry translation on next language switch

---

### Requirement: Translation Caching
The system SHALL cache translated content to minimize API calls and improve performance.

#### Scenario: Use cached translation for repeated movie views
**Given** a movie title has been translated to English and cached  
**When** user views the same movie again in English  
**Then** the cached translation should be used  
**And** no API call should be made

#### Scenario: Invalidate cache when source content changes
**Given** a cached translation exists for a movie  
**When** the movie's source content is updated from API  
**Then** the cached translation should be invalidated  
**And** new translation should be requested on next view

#### Scenario: Cache size management
**Given** translation cache exceeds 1000 entries  
**When** new translation is added  
**Then** least recently used translations should be evicted  
**And** cache size should stay under limit

---

### Requirement: Language Selection Integration
The system SHALL automatically translate movie content when user changes language preference.

#### Scenario: Refresh translations on language change
**Given** user is viewing home screen with movies in English  
**When** user changes language to French in settings  
**Then** all movie titles and descriptions should refresh with French translations  
**And** display loading indicator during translation

#### Scenario: Preserve scroll position during translation refresh
**Given** user has scrolled to movie #50 on home screen  
**When** language is changed  
**Then** scroll position should be preserved after translations load  
**And** user sees translated content at same scroll location

---

### Requirement: Translated Content Display
The system SHALL display translated movie content in all movie-related UI components.

#### Scenario: Display translated content on home screen
**Given** user selected German language  
**When** home screen loads  
**Then** all movie titles should be in German  
**And** movie cards should show German titles

#### Scenario: Display translated content on detail page
**Given** user opens movie detail page  
**And** user selected Portuguese language  
**When** detail page loads  
**Then** movie title should be in Portuguese  
**And** description should be in Portuguese  
**And** other metadata (actors, directors) should remain in original language

---

### Requirement: Performance Optimization
The system SHALL optimize translation loading to maintain smooth UI performance.

#### Scenario: Lazy load translations for visible movies only
**Given** home screen displays 20 movies in viewport  
**And** total 100 movies in list  
**When** screen loads  
**Then** only visible 20 movies should be translated immediately  
**And** remaining movies translate as user scrolls

#### Scenario: Batch translation requests
**Given** 10 movies need translation  
**When** translation service is called  
**Then** movies should be batched into single API request  
**And** reduce network overhead

---

## Dependencies
- `lib/features/language` - Language selection feature
- `lib/app/translations` - GetX localization setup
- `lib/app/data/models/video_item.dart` - Movie model
- `lib/app/data/models/movie_model.dart` - Movie API model
- Translation API (LibreTranslate or Google Translate)

## Related Capabilities
- **UI Localization**: Existing GetX translations for UI strings must remain independent of movie content translation
