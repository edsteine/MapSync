Here's the polished and corrected final version of your README:

---

# Offline Maps Flutter Application

A Flutter application demonstrating offline map capabilities using the Mapbox SDK.

---

## Overview

This app provides offline map functionality, enabling users to download regions, manage offline data, and fetch dynamic map markers from a REST API. Built on clean architecture principles, it ensures optimized performance and maintainability.

---

## Features

### Core Features
- Offline maps with tile caching.
- MVVM pattern using Riverpod.
- Optimized map rendering and interaction.
- Extensive testing suite.

### Map Features
- Interactive maps using the Mapbox SDK.
- Dynamic markers fetched via API.
- Offline region download with progress tracking.
- Offline region and cache management.

### Customization
- Light/dark theme support.
- Push notifications for download updates.

---

## API for Map Markers

The app dynamically fetches map markers from the following endpoint:

```http
GET /api/markers
Host: https://w-project-u75x.onrender.com/api/v1/locations/?page=1&page_size=10
```

### Sample Response:
```json
{
  "count": 142,
  "next": "https://w-project-u75x.onrender.com/api/v1/locations/?page=2&page_size=10",
  "previous": null,
  "results": [
    {
      "id": "93694f80-2cc7-46b4-9d92-58f68e39da1c",
      "name": "Résidence El Majd",
      "description": "",
      "geometry": {
        "type": "Point",
        "coordinates": [
          -7.6350943,
          33.5726499
        ]
      },
      "created_at": "2024-12-31T03:50:28.721740Z",
      "updated_at": "2024-12-31T03:50:28.721749Z",
      "is_deleted": false
    },
]
}
```

---

## Architecture

### Layered Design
1. **Presentation Layer:** MVVM pattern with Riverpod for state management.
2. **Domain Layer:** Encapsulates business logic and entities.
3. **Data Layer:** Manages data sources and repositories.

### Folder Organization
```plaintext
lib/
├── core/
│   ├── config/
│   ├── utils/
│   ├── performance/
│   └── services/
├── features/
│   ├── map/
│   ├── settings/
│   └── offline_map/
└── shared/
```

---

## Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/edsteine/wmobile.git
   cd wmobile
   ```

2. **Configure Mapbox Token and API Endpoint:**
   Update `lib/core/config/app_config.dart`:
   ```dart
   class AppConfig {
       static String get mapboxAccessToken =>
           dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '<YOUR_MAPBOX_ACCESS_TOKEN>';
       static String get apiBaseUrl =>
           dotenv.env['API_BASE_URL'] ?? '<YOUR_API_BASE_URL>';
   }
   ```
   Add the following to a `.env` file:
   ```plaintext
   MAPBOX_ACCESS_TOKEN=<YOUR_MAPBOX_ACCESS_TOKEN>
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## Testing

### Unit Tests
Run specific module tests:
```bash
flutter test test/core/services
flutter test test/core/utils
flutter test test/core/performance
flutter test test/features/map
flutter test test/features/settings
flutter test test/features/offline_map
flutter test test/shared/widgets
```

### Integration Tests
Test offline features and map functionality:
```bash
flutter test test/integration/
```

### Manual Testing Checklist
- Offline map downloading and region management.
- API marker fetching.
- Theme and cache management.

---

## Troubleshooting

- **Maps not loading:** Verify your Mapbox token and app permissions.
- **Download issues:** Check storage space and device permissions.
- **Marker issues:** Ensure API connectivity and valid JSON responses.
- **Offline notifications:** Functional but may need enhancement for improved user experience.

---

## Acknowledgments

Gratitude to:
- Google AI Studio, and Claude for assistance in code and documentation.
