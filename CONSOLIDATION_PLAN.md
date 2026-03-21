# Mobile Architecture Consolidation Plan

## Current State - Two Parallel Stacks

### Active Stack (used by main.dart)
- `SwingApiClient` - HTTP client with Dio
- `SessionController` - Auth state management
- `LibraryController` - Library data management
- `PlayerController` - Playback state
- `OfflineManager` - Offline sync
- Entry: `RootGateScreen` → `AppShell`

### Legacy Stack (in shared/providers and features/)
- `EnhancedApiService` - Duplicate HTTP client
- `AuthProvider` - Duplicate auth state
- `LibraryProvider` - Duplicate library state
- `AudioProvider` - Audio state
- Entry: `AppRouter` with go_router

## Consolidation Strategy

### Phase 1: Migrate Feature Screens
1. Update `features/home/home_screen.dart` to use `LibraryController`
2. Update `features/library/library_screen.dart` to use `LibraryController`
3. Update `features/auth/screens/login_screen.dart` to use `SessionController`
4. Update `features/settings/screens/settings_screen.dart` to use `SessionController`
5. Update all other feature screens accordingly

### Phase 2: Remove Legacy Files
1. Remove `shared/providers/auth_provider.dart`
2. Remove `shared/providers/library_provider.dart`
3. Remove `data/services/enhanced_api_service.dart`
4. Keep `shared/providers/audio_provider.dart` (no controller equivalent)
5. Keep `shared/providers/analytics_provider.dart` (no controller equivalent)

### Phase 3: Update Routing
1. Remove `shared/routes/app_router.dart` (go_router based)
2. Keep navigation in `AppShell` and `RootGateScreen` (provider-based)

## Migration Pattern

### Before (Legacy)
```dart
import '../../shared/providers/library_provider.dart';

// In widget:
_libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
await _libraryProvider.loadTracks();
```

### After (Active)
```dart
import '../../app/state/library_controller.dart';

// In widget:
_libraryController = Provider.of<LibraryController>(context, listen: false);
await _libraryController.loadFolder(r'$home');
```

## Files to Update

### Feature Screens (import changes needed)
- `features/home/home_screen.dart`
- `features/library/library_screen.dart`
- `features/auth/screens/login_screen.dart`
- `features/auth/screens/qr_login_screen.dart`
- `features/settings/screens/settings_screen.dart`
- `features/qr/qr_screen.dart`

### Files to Remove (after migration)
- `shared/providers/auth_provider.dart`
- `shared/providers/library_provider.dart`
- `data/services/enhanced_api_service.dart`
- `shared/routes/app_router.dart`

### Files to Keep
- `shared/providers/audio_provider.dart` - No controller equivalent
- `shared/providers/analytics_provider.dart` - No controller equivalent
- All controller files in `app/state/`
- All service files in `app/services/`

## Benefits
1. Single source of truth for API client
2. Consistent state management across app
3. Reduced code duplication
4. Simpler dependency graph
5. Better offline support (controllers use OfflineManager)
