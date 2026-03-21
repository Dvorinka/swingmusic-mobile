# SwingMusic Mobile Feature Analysis & Implementation Plan

## Android Original Features (Reference)

### Core Features
- **Home**: Recent plays, favorites, playlists, daily mixes, shuffle all
- **Search**: Top results, search suggestions, view all (tracks/albums/artists), filters
- **Library**: Albums, Playlists, Favorites, Folders, Artists (tabbed interface)
- **Player**: Full playback controls, queue management, shuffle, repeat, crossfade, lyrics, waveform
- **Downloads**: Download management, progress tracking, pause/resume/cancel
- **Settings**: Connection, audio quality, theme, downloads, cache, analytics
- **Analytics**: Listening stats, top tracks/artists, recap experience
- **Auth**: Login, QR code login, session management

### Architecture Components
- **MediaControllerViewModel**: Full playback state management, queue handling
- **SearchViewModel**: Debounced search, top results, view all searches
- **HomeViewModel**: Home data loading, navigation events
- **LibraryViewModel**: Library tabs, data loading
- **ArtistInfoViewModel**: Artist details, albums, tracks
- **AlbumWithInfoViewModel**: Album details, track listing
- **DownloadViewModel**: Download management, web app connection
- **LyricsViewModel**: Synced lyrics, position tracking
- **FoldersViewModel**: Folder navigation, breadcrumb trails

---

## Flutter Mobile Current State

### ✅ Implemented (Real API)
- Basic API service with Dio (`EnhancedApiService`)
- Authentication with token management
- Track/Album/Artist/Playlist models
- Library provider with API integration
- Audio playback service foundation
- Settings service

### ⚠️ Implemented (Mock/Demo Data)
- **Home Screen**: Uses real API but limited features
- **Search Screen**: Mock suggestions, simulated delays
- **Folder Screen**: Hardcoded sample folders/tracks
- **Downloads Screen**: Sample download items
- **Connection Screen**: Simulated discovery/connection
- **Playlists Screen**: Sample playlists
- **QR Screen**: Demo QR codes
- **Analytics Screen**: Mock analytics data
- **Recap Screen**: Simulated recap data
- **Offline Screen**: Sample offline tracks
- **Podcast Screen**: Mock podcast data

### ❌ Missing Features
1. **Lyrics Screen**: Synced lyrics display with position tracking
2. **Waveform Visualization**: Audio waveform display
3. **Queue Management Screen**: Full queue editing
4. **View All Search**: Paginated search results
5. **Web App Connection**: Real pairing code system
6. **Widget Support**: Home screen widgets
7. **Daily Mixes**: Smart playlists
8. **Crossfade**: Real crossfade implementation
9. **Gapless Playback**: Real gapless implementation
10. **Proper State Persistence**: Queue saving/restoration

---

## Implementation Plan

### Phase 1: Replace Mock Data with Real API Calls
1. ✅ Home Screen - Already uses real API
2. 🔨 Search Screen - Add real search suggestions API
3. 🔨 Folder Screen - Connect to real folder API
4. 🔨 Downloads Screen - Connect to real download API
5. 🔨 Connection Screen - Implement real pairing system
6. 🔨 Playlists Screen - Connect to real playlist API

### Phase 2: Implement Missing Screens
1. 🔨 Lyrics Screen - Synced lyrics with position
2. 🔨 Queue Screen - Full queue management
3. 🔨 View All Search - Paginated results
4. 🔨 Waveform Display - Audio visualization

### Phase 3: Advanced Features
1. 🔨 Analytics Dashboard - Real listening stats
2. 🔨 Recap Experience - Year/monthly recaps
3. 🔨 Widget Support - Home screen widgets
4. 🔨 Daily Mixes - Smart playlist generation

### Phase 4: Polish & Testing
1. 🔨 Error handling
2. 🔨 Loading states
3. 🔨 Offline support
4. 🔨 Performance optimization

---

## Files with Mock Data (Need Replacement)

### High Priority
- `lib/features/search/search_screen.dart` - Lines 560-617
- `lib/features/folder/folder_screen.dart` - Lines 32-180
- `lib/features/downloads/download_screen.dart` - Lines 240-342
- `lib/features/playlists/playlists_screen.dart` - Lines 30-80
- `lib/features/connection/connection_screen.dart` - Lines 43-430

### Medium Priority
- `lib/features/analytics/analytics_screen.dart`
- `lib/features/recap/recap_screen.dart`
- `lib/features/offline/offline_screen.dart`
- `lib/features/podcast/screens/podcast_support_screen.dart`

### Low Priority
- `lib/features/qr/qr_screen.dart` - Demo codes handling
- `lib/features/widgets/recap_screen.dart`

---

## Duplicate Code Found

1. **Auth Providers**: 
   - `lib/features/auth/providers/auth_provider.dart`
   - `lib/shared/providers/auth_provider.dart`
   
2. **Search Screens**:
   - `lib/features/search/search_screen.dart`
   - `lib/features/search/screens/search_screen.dart`

3. **Recap Screens**:
   - `lib/features/recap/recap_screen.dart`
   - `lib/features/widgets/recap_screen.dart`

4. **Library Providers**:
   - `lib/shared/providers/library_provider.dart`
   - Multiple feature-specific providers

---

## API Endpoints Needed

### From Android App (Already in EnhancedApiService)
- `/tracks` - Get tracks with filters
- `/albums` - Get albums
- `/artists` - Get artists
- `/playlists` - Get playlists
- `/folders` - Get folder structure
- `/search` - Search with suggestions
- `/lyrics/{trackHash}` - Get lyrics
- `/queue` - Queue management
- `/downloads` - Download management
- `/analytics` - Listening statistics
- `/settings` - User settings
- `/sync` - Library synchronization

### Additional Needed
- `/home` - Home data (recent, favorites, mixes)
- `/artist/{hash}/tracks` - Artist tracks
- `/album/{hash}/tracks` - Album tracks
- `/waveform/{trackHash}` - Waveform data
- `/pairing/generate` - Generate pairing code
- `/pairing/validate` - Validate pairing code

---

## Next Steps

1. Consolidate duplicate providers/screens
2. Implement real API calls for all mock data
3. Add missing screens (lyrics, queue, view-all)
4. Implement proper state management
5. Add error handling and loading states
6. Test with real SwingMusic backend
