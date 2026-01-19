# Tasks: Fix Download Functionality

## Phase 1: MVP - Quality Selection

- [x] Review & fix QualitySheet widget
  - [x] Add HLS variant display with resolution/bandwidth  
  - [x] Update onSelected callback to pass variant info
- [x] Update HLSDownloadService
  - [x] Add variant parameter to startHLSDownload()
  - [x] Remove hardcoded variant selection (line 69)
  - [x] Select user-chosen variant from master playlist
- [ ] Test HLS quality selection flow
  - [ ] Test with m3u8 stream
  - [ ] Verify correct variant downloads
  - [ ] Check playlist rewriting works

## Phase 2: UX Enhancements

- [x] Add retry logic
  - [x] Implement exponential backoff for failed segments
  - [x] Add max retry count (3 attempts)
- [x] Improve error messages
  - [x] Network errors → "Check your connection"
  - [x] Storage errors → "Free up space"
  - [x] Format errors → "Unsupported video format"
- [x] Concurrent download feedback
  - [x] Show snackbar when limit reached
  - [x] Display active download count
- [ ] Wire pause/resume UI
  - [ ] Add pause button in downloading state
  - [ ] Add resume option in failed/paused state

## Phase 3: Optional Polish

- [ ] Download speed estimation
- [ ] Battery-aware pausing
- [ ] WiFi-only download option
- [ ] Download queue management UI

## Testing Checklist

- [ ] MP4 download → complete → playback
- [ ] HLS download → complete → playback  
- [ ] Cancel during download
- [ ] Delete completed download
- [ ] Multiple concurrent downloads
- [ ] Offline playback verification
