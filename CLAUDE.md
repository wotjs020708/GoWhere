# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GoWhere is an iOS application that helps users discover random locations in Korean cities and find nearby restaurants. Built with SwiftUI targeting iOS 17.0+, it uses Swift 5.0 and follows Clean Architecture with MVVM-C (Model-View-ViewModel-Coordinator) pattern.

Bundle ID: `com.jaesuneo.GoWhere`

### Features

- **Onboarding Flow**: Interactive onboarding with haptic feedback
- **City Selection**: Choose from 20+ major Korean cities or select nationwide (전국)
- **Random Location Generation**: Algorithm-based random coordinate generation within city boundaries
- **Map Integration**: MapKit-based visualization with animated markers
- **Address Resolution**: Detailed addresses at 시·구·동 (city·district·dong) level
- **Restaurant Search**: Dong-level Naver search for precise local recommendations
- **Location History**: Persistent storage of generated locations with map visualization and swipe-to-delete
- **Dual Tab Interface**: Separate tabs for city selection/generation and history viewing
- **Haptic Feedback**: Rich haptic effects throughout the app for better UX

## Architecture: Clean Architecture + MVVM-C

### Layer Structure

```
GoWhere/
├── Domain/                          # Business Logic Layer
│   ├── Entities/
│   │   ├── City.swift               # City model with predefined Korean cities (Codable)
│   │   └── RandomLocation.swift    # Generated location with 시·구·동 address (Codable)
│   ├── RepositoryInterfaces/
│   │   └── LocationHistoryRepositoryProtocol.swift  # History repository contract
│   └── UseCases/
│       ├── GenerateRandomLocationUseCase.swift      # Random coordinate generation
│       ├── SaveLocationHistoryUseCase.swift         # Save location to history
│       ├── FetchLocationHistoryUseCase.swift        # Fetch history list
│       └── DeleteLocationHistoryUseCase.swift       # Delete from history
├── Data/                            # Data Layer
│   └── Repositories/
│       └── LocationHistoryRepository.swift  # UserDefaults-based persistence
├── Presentation/                    # Presentation Layer (MVVM-C)
│   ├── Coordinators/
│   │   └── AppCoordinator.swift    # Navigation and dependency injection
│   └── Scenes/
│       ├── Onboarding/             # 3-page onboarding flow
│       ├── MainTab/                # TabView with dual-tab interface
│       ├── CitySelection/          # City grid with search and nationwide option
│       ├── History/                # History list and map with swipe-to-delete
│       └── RandomLocationMap/      # Map view with dong-level location
└── Common/
    ├── Utils/
    │   ├── HapticManager.swift     # Centralized haptic feedback
    │   └── DistrictResolver.swift  # District and dong resolution
    └── Extensions/
        └── CLLocationCoordinate2D+Codable.swift  # Codable conformance
```

### Key Principles

1. **Domain Layer**
   - `City`: Predefined list of 20+ Korean cities with coordinates, search radius, and nationwide option (Codable for persistence)
   - `RandomLocation`: Generated location with city, coordinate, district, dong, and intelligent search query (Codable)
   - `GenerateRandomLocationUseCase`: Circular distribution algorithm; handles nationwide by picking random city first
   - `LocationHistoryRepositoryProtocol`: Repository contract for CRUD operations on location history

2. **Data Layer**
   - `LocationHistoryRepository`: UserDefaults-based persistence storing up to 100 locations as JSON
   - Stores most recent locations first with automatic limit enforcement

3. **Presentation Layer** (MVVM-C)
   - **AppCoordinator**: Manages onboarding state, navigation flow, and dependency injection for all repositories/use cases
   - **ViewModels**: Marked with `@MainActor`, handle user interactions, haptic feedback, and async operations
   - **Views**: SwiftUI with HIG-compliant design, animations, and haptic triggers
   - **MainTabView**: Dual-tab interface with city selection and history tabs

4. **User Flow**
   - Onboarding (first launch) → TabView → City Selection Tab (choose city or nationwide) → Random Generation (with haptic + auto-save to history) → Map View (dong-level address) → Dong-level Naver Search
   - History Tab: View all saved locations on map with pins, swipe to delete from list

### Haptic Feedback

`HapticManager.shared` provides:
- `light()`, `medium()`, `heavy()`: Impact feedback
- `success()`, `warning()`, `error()`: Notification feedback
- `selection()`: Selection change feedback
- `randomizingEffect(completion:)`: Special 8-step progressive haptic effect for location generation

### Address Resolution

`DistrictResolver` provides:
- District (구) resolution for 7 major cities: Seoul, Busan, Daegu, Incheon, Gwangju, Daejeon, Ulsan
- Dong (동) resolution with pseudo-generation for demo (production should use CLGeocoder)
- Real district boundaries with fallback to city name for cities without district data

### Persistence

- **Location History**: Stored in UserDefaults as JSON-encoded array
- **Codable Extensions**: CLLocationCoordinate2D, City, and RandomLocation all implement Codable
- **Capacity**: Maximum 100 locations, newest first
- **Thread Safety**: All repository operations are async and performed on background threads

## Building and Running

### Build the project
```bash
xcodebuild -project GoWhere.xcodeproj -scheme GoWhere -configuration Debug build
```

### Build for release
```bash
xcodebuild -project GoWhere.xcodeproj -scheme GoWhere -configuration Release build
```

### Clean build artifacts
```bash
xcodebuild -project GoWhere.xcodeproj -scheme GoWhere clean
```

### Run on simulator
```bash
xcodebuild -project GoWhere.xcodeproj -scheme GoWhere -destination 'platform=iOS Simulator,name=iPhone 15' run
```

## Development Guidelines

### Adding a New City

1. Add to `City.cities` array in Domain/Entities/City.swift
2. Include name, latitude, longitude, and appropriate search radius
3. Optionally add district data to DistrictResolver for 구-level subdivision
4. Cities automatically appear in CitySelectionView grid

### Adding a New Scene

1. Create Scene folder under Presentation/Scenes/
2. Create ViewModel (inject use cases, weak coordinator reference)
3. Create SwiftUI View with HIG-compliant design
4. Add route to `AppRoute` enum in AppCoordinator
5. Add factory method in AppCoordinator to build the scene
6. Add navigation method for routing

### ViewModel Guidelines

- Always mark ViewModels with `@MainActor`
- Use `@Published` properties for state
- Inject use cases via initializer
- Hold weak reference to coordinator for navigation
- Keep business logic in use cases, not ViewModels

### Navigation

- AppCoordinator manages onboarding state via UserDefaults
- Navigation uses SwiftUI NavigationStack with typed routes
- Routes: `.randomLocation(RandomLocation)`
- Methods: `navigate(to:)`, `pop()`, `popToRoot()`, `completeOnboarding()`

### External Integrations

- **Naver Search**: RandomLocation generates dong-level search URL with intelligent query (dong → district → city fallback)
- Opened via `UIApplication.shared.open()` from map view

### Known Limitations

- **Dong-level Address**: Currently uses pseudo-generation based on coordinate hashing for demo purposes
  - Production should use CLGeocoder's `reverseGeocodeLocation` for real dong names
- **iOS 17 Map API**: Some MapKit APIs are deprecated in iOS 17
  - Current implementation still works but should migrate to MapContentBuilder API
- **Persistence**: UserDefaults limited to ~100 locations; consider CoreData for larger datasets

## Configuration

- **Min iOS Version**: 17.0
- **Concurrency**: Swift 6 concurrency with MainActor isolation enabled
- **Localization**: String catalog generation enabled
