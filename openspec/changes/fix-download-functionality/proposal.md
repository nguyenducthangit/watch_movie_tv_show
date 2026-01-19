# Proposal: Fix Download Functionality

**Change ID:** `fix-download-functionality`  
**Status:** 🟡 Draft  
**Author:** Antigravity Agent  
**Created:** 2026-01-19

## Problem Statement

The watch movie/TV show app has a download feature for offline viewing, but it has several issues that prevent it from being production-ready:

1. **HLS quality selection hardcoded** - Always selects first variant (line 69 in hls_download_service.dart)
2. **No quality selection flow** - Users can't choose which quality to download
3. **Incomplete pause/resume** - Infrastructure exists but not fully wired
4. **No retry mechanism** - Failed downloads don't auto-retry with backoff
5. **Limited error messaging** - Generic errors don't help users troubleshoot
6. **No concurrent control UI** - Max concurrent downloads enforced but no user feedback

## Current State Analysis

### Services Layer
- **DownloadService** (`lib/app/services/download_service.dart`):
  - Handles both MP4 and HLS downloads
  - Uses `background_downloader` for MP4
  - Delegates to HLSDownloadService for m3u8 streams
  - State: active/completed downloads tracked via Rx observables
  - Storage: Persistent via StorageService

- **HLSDownloadService** (`lib/app/services/hls_download_service.dart`):
  - Parses master/media playlists
  - Downloads encryption keys + segments sequentially
  - Rewrites playlist with local paths
  - **ISSUE:** Line 68 hardcodes variant selection

### UI Layer
- **DownloadButton** (`lib/features/downloads/widgets/download_button.dart`):
  - Shows 3 states: not downloaded, downloading, downloaded
  - Opens QualitySheet bottom sheet for selection
  - **Missing:** Quality sheet implementation incomplete

- **QualitySheet** (`lib/features/downloads/widgets/quality_sheet.dart`):
  - Exists but needs review for HLS variant selection

## Proposed Solution

### Phase 1: Complete Quality Selection (MVP)
1. Update `QualitySheet` to show HLS variants when available
2. Pass selected variant to `HLSDownloadService.startHLSDownload()`
3. Modify HLS service to accept variant parameter instead of hardcoding

### Phase 2: Enhanced UX
1. Add retry logic with exponential backoff
2. Improve error messages (network, storage, format errors)
3. Show concurrent download limit feedback
4. Wire pause/resume buttons in download progress UI

### Phase 3: Polish (Optional)
1. Download speed estimation
2. Battery-aware downloading (pause on low battery)
3. WiFi-only option

## User Review Required

> [!IMPORTANT]
> **Breaking Changes:** None - this is enhancement only
> 
> **Key Decision:** Should we implement all phases or MVP only?
> - MVP (Phase 1): ~2-3 hours
> - Full (Phase 1+2): ~5-6 hours
> - All phases: ~8-10 hours

## Success Criteria

- [ ] Users can select HLS quality variant before download
- [ ] Downloads complete successfully for both MP4 and HLS
- [ ] Failed downloads show helpful error messages
- [ ] Concurrent download limit communicated clearly
- [ ] Downloaded videos playback offline

## Open Questions

1. Should HLS variant selection show bandwidth/resolution labels?
2. Do we need download history/logs for debugging?
3. Should we add download queue management UI?
