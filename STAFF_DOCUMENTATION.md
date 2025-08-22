# E-School SaaS - Staff Management System Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Key Components](#key-components)
4. [State Management](#state-management)
5. [API Integration](#api-integration)
6. [UI Customization](#ui-customization)
7. [Authentication & Authorization](#authentication--authorization)
8. [Feature Modules](#feature-modules)
9. [Getting Started](#getting-started)

## Project Overview
E-School SaaS Staff Management is a comprehensive school management system built with Flutter, specifically designed for teachers and staff members. The application follows a clean architecture pattern and uses BLoC (Cubit) for state management.

## Project Structure
```
lib/
├── app/                    # Application setup and configuration
│   ├── app.dart           # Main app configuration
│   ├── appTranslation.dart # Localization setup
│   └── routes.dart        # Route definitions
│
├── cubits/                 # State management
│   ├── authentication/    # Authentication-related cubits
│   ├── chat/             # Chat feature cubits
│   └── teacherAcademics/ # Teacher-specific cubits
│
├── data/                   # Data layer
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
│
├── ui/                     # User interface components
│   ├── screens/          # Application screens
│   ├── widgets/          # Reusable widgets
│   └── styles/           # Theme and style definitions
│
└── utils/                 # Utility functions and constants
```

## Key Components

### 1. Authentication System
- Managed through `AuthCubit`
- Secure token-based authentication
- Role-based access control for staff members
- Password change and profile management

### 2. Teacher Academics Module
- Class and section management
- Attendance tracking
- Lesson planning and management
- Assignment creation and grading
- Exam result management
- Timetable management

### 3. Staff Management Features
- Leave management system
- Payroll access
- Staff profiles
- Document management
- Notifications system

### 4. Communication Tools
- Internal chat system
- Announcement management
- Notification system
- Parent-teacher communication

## State Management

### 1. Cubit Implementation
The application uses BLoC pattern through Cubits for state management. Key Cubits include:

```dart
// Authentication
- AuthCubit
- StaffAllowedPermissionsAndModulesCubit

// Teacher Academics
- TeacherMyTimetableCubit
- TeacherAttendanceCubit
- TeacherAssignmentsCubit

// Communication
- SocketSettingCubit
- ChatMessagesCubit
- NotificationsCubit
```

### 2. State Flow
```dart
// Example of state flow in a Cubit
class TeacherAttendanceCubit extends Cubit<TeacherAttendanceState> {
  final TeacherRepository repository;
  
  Future<void> markAttendance(AttendanceData data) async {
    emit(TeacherAttendanceLoading());
    try {
      final result = await repository.markAttendance(data);
      emit(TeacherAttendanceSuccess(result));
    } catch (e) {
      emit(TeacherAttendanceError(e.toString()));
    }
  }
}
```

## API Integration

### 1. Repository Pattern
```dart
// Example repository implementation
class TeacherRepository {
  final ApiService _apiService;
  
  Future<ApiResponse> markAttendance(AttendanceData data) async {
    try {
      final response = await _apiService.post('/attendance/mark', data.toJson());
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
```

### 2. API Service Configuration
- Base URL configuration in environment files
- Token management for authenticated requests
- Error handling and response parsing
- Retry mechanisms for failed requests

## UI Customization

### 1. Theme Configuration
The application uses a customizable theme system:

```dart
// In ui/styles/colors.dart
final customColorsExtension = CustomColors(
  primaryColor: Color(0xFF4C4C6D),
  secondaryColor: Color(0xFF1B9C85),
  backgroundColor: Colors.white,
  // Add custom colors as needed
);
```

### 2. Screen Customization
Each screen follows a modular approach:
- Base screen structure in `ui/screens/`
- Reusable widgets in `ui/widgets/`
- Custom components for specific features

## Authentication & Authorization

### 1. Login Flow
```dart
// Login process
1. User enters credentials
2. AuthCubit validates and makes API call
3. JWT token stored in secure storage
4. User permissions loaded
5. Home screen navigation
```

### 2. Permission Management
- Role-based access control
- Feature-level permissions
- Module access restrictions

## Feature Modules

### 1. Teacher Academics
- Class management
- Attendance tracking
- Assignment management
- Exam management
- Result processing

### 2. Staff Management
- Leave application
- Payroll access
- Profile management
- Document management

### 3. Communication
- Internal messaging
- Announcements
- Notifications
- Parent communication

## Getting Started

### Prerequisites
1. Flutter SDK
2. Firebase project setup
3. IDE (VS Code or Android Studio)

### Setup Steps
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase using provided `firebase_options.dart`
4. Update API endpoints in repository classes

### Configuration
1. Environment Setup:
   - Update Firebase configuration
   - Configure API endpoints
   - Set up school-specific settings

2. Feature Configuration:
   - Enable/disable modules
   - Configure permissions
   - Set up notification services

## Common Customization Scenarios

### 1. Adding New Features
1. Create necessary models in `data/models/`
2. Implement repository in `data/repositories/`
3. Create Cubit for state management
4. Add UI components
5. Update routes

### 2. Modifying Existing Features
1. Locate relevant Cubit and repository
2. Update state management logic
3. Modify UI components
4. Test changes thoroughly

### 3. UI Theme Changes
1. Update colors in `ui/styles/colors.dart`
2. Modify widget themes
3. Update custom components

## Security Best Practices

1. Data Security:
   - Secure storage for sensitive data
   - Encryption for local storage
   - Secure API communication

2. Authentication:
   - Token management
   - Session handling
   - Secure password storage

## Testing

1. Unit Tests:
   - Repository tests
   - Cubit logic tests
   - Utility function tests

2. Widget Tests:
   - UI component tests
   - Integration tests
   - User flow tests

## Deployment

1. Build Process:
   ```bash
   flutter build apk --release  # For Android
   flutter build ios           # For iOS
   ```

2. Release Configuration:
   - Version management
   - API endpoint configuration
   - Feature toggles

## Support and Maintenance

1. Error Handling:
   - Logging implementation
   - Error tracking
   - Performance monitoring

2. Updates:
   - Dependency management
   - Version control
   - Backward compatibility
