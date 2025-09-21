# Medication Timetable

A Flutter application for managing medication schedules and user profiles. This app helps users track their medications, set up dosage schedules, and manage multiple user profiles.

## Features

### User Management
- Create and manage multiple user profiles
- Edit user information
- Delete users when no longer needed

### Medication Management
- Add new medications with detailed information
- Edit existing medications
- Delete medications
- View medication details and schedules

### Medication Details
- **Medication Information**: Name, quantity, unit, and duration
- **User Assignment**: Assign medications to specific users
- **Dosage Schedule**: Set frequency (2h/2h, 4h/4h, 6h/6h, 8h/8h, 12h/12h, once daily)
- **Time Management**: Select start time with hour and minute precision
- **Date Range**: Automatic calculation of end date based on duration
- **Schedule Display**: Complete timeline showing all calculated dose times

### Smart Features
- **User Validation**: Prevents adding medications without selecting a user
- **Form Validation**: Save button only enabled when all required fields are completed
- **Pre-selection**: Automatically selects the current user when adding new medications
- **Real-time Updates**: Medication lists refresh automatically after changes

## Screenshots

*Add screenshots of your app here*

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (for iOS development) or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medicationtimetable
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Ensure Android SDK is installed
- Create an Android Virtual Device (AVD) or use a physical device

#### iOS
- Ensure Xcode is installed (macOS only)
- Open iOS Simulator or use a physical device

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── user.dart                      # User data model
│   └── medication.dart                # Medication data model
├── screens/
│   ├── home_screen.dart               # Main screen with medication list
│   ├── user_management_screen.dart    # User CRUD operations
│   ├── medication_management_screen.dart # Add/Edit medications
│   └── medication_details_screen.dart # Medication details view
├── database/
│   └── database_helper.dart           # SQLite database operations
├── widgets/
│   └── timer_picker_dropdown.dart     # Custom time picker widget
└── utils.dart                         # Utility functions
```

## Database Schema

### Users Table
- `id` (INTEGER PRIMARY KEY)
- `name` (TEXT NOT NULL)
- `age` (INTEGER)
- `created_at` (TEXT)

### Medications Table
- `id` (INTEGER PRIMARY KEY)
- `name` (TEXT NOT NULL)
- `quantity` (REAL NOT NULL)
- `unit` (TEXT NOT NULL)
- `days` (INTEGER NOT NULL)
- `frequency` (TEXT NOT NULL)
- `start_time` (TEXT NOT NULL)
- `start_date` (TEXT NOT NULL)
- `end_date` (TEXT NOT NULL)
- `user_id` (INTEGER NOT NULL)
- `created_at` (TEXT)

## Key Features Explained

### Time Window Selection
The app supports various medication frequencies:
- **2h/2h**: Every 2 hours
- **4h/4h**: Every 4 hours
- **6h/6h**: Every 6 hours
- **8h/8h**: Every 8 hours
- **12h/12h**: Every 12 hours
- **Once daily**: Once per day

### Schedule Calculation
The app automatically calculates all dose times based on:
- Start time (hour and minute)
- Selected frequency
- Start date
- Number of days

### User Experience
- **Intuitive Navigation**: Easy navigation between screens
- **Form Validation**: Smart validation prevents incomplete submissions
- **Responsive Design**: Works on various screen sizes
- **Real-time Updates**: Changes reflect immediately across screens

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0          # SQLite database
  path: ^1.8.3             # Path manipulation
  intl: ^0.18.1            # Internationalization and date formatting
  path_provider: ^2.1.1    # File system paths
```

## Development

### Code Style
- Follows Flutter/Dart conventions
- Uses proper widget composition
- Implements proper state management
- Includes error handling

### Database Operations
- All database operations are handled through `DatabaseHelper`
- Proper error handling and transaction management
- CRUD operations for both users and medications

### State Management
- Uses `StatefulWidget` for local state management
- Proper lifecycle management
- Real-time UI updates

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, please contact [eduardohenriqueassis1973@gmail.com]

## Acknowledgments

- Flutter team for the amazing framework
- SQLite team for the database engine
- All contributors and testers

---

**Note**: This app is designed for personal medication management. Always consult with healthcare professionals for medical advice.
