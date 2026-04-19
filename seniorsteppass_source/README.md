# SeniorStepPass - Senior Project Management System

A Flutter application that simplifies senior project management and internship tracking for students and administrators.

## Features

### Core Features
- **User Management** - Admin panel for managing students and user roles
- **Project Management** - Create, manage, and request projects
- **Internship Tracking** - Browse and select internship opportunities
- **Project Requests** - Request to join projects with approval workflow
- **Review System** - Submit and view internship reviews with ratings

### Recent Updates (Latest Session)

#### Project Links Feature 🔗
- **"More About Project" Button**: 
  - Located below project images and above team section
  - Styled with AppTheme.info color (blue button)
  - Fetches project links from Firebase 'links' field (supports both String and List types)
  - Automatically adds `https://` if URL missing scheme
  - Opens links directly in default browser using `url_launcher`
  - Error handling with user feedback

#### Project Navigation System 
- **Landing Page Buttons**: 
  - Left side project buttons use category filters
  - Right side internship buttons use search
  - Smooth navigation with proper state management
  - Uses ValueKey to clear search/filters on navbar navigation
- **Search vs Filter Distinction**:
  - ProjectMainScreen: Supports both search (initialFilters) and category filters (initialCategoryFilters)
  - InternshipMainScreen: Supports search with initialFilters
  - Category badges on ProjectDetailScreen are clickable links to filter projects

#### Image Upload & Display 📸
- **Internship Reviews**: Upload review images to Cloudinary
  - Pick images from gallery
  - Automatic upload on review submission
  - Square image display (120x120 px)
  - Tap to expand fullscreen viewer
  - Error handling with fallback placeholder

- **Review Display**: Show images in feedback cards
  - `internship_detail_screen.dart`: Display uploaded review images
  - Tap image to view fullscreen
  - Graceful error handling

#### Review Rating System 
- **Unified Rating Calculation**: Calculate average from individual ratings
  - Workload Rating
  - Environment Rating
  - Mentorship Rating
  - Benefits Rating
  - Average displayed as star count
- **Applied to**:
  - `internship_detail_screen.dart` - Feedback section
  - `review_moderation_screen.dart` - Admin moderation
  - Consistent rating display across app

#### User Profiles in Reviews 
- Display reviewer's profile picture in feedback cards
- Show user initials if no profile picture available
- Graceful fallback to default avatar
- User name and department display

#### Project Management 
- **Owner Badge**: Red circle with star icon for owned projects
- **Auto-sync Joined Projects**: 
  - Automatically sync projects where user is a team member
  - Check members map in projects collection
  - Save to `users/{userId}/projects` subcollection
  - No duplicate projects displayed
- **Display Joined Projects**: Show both owned and joined projects on profile

**Previous Features:**
- Firebase Firestore integration
- Cloud Storage for project/company images
- Responsive design
- Admin moderation dashboard

## Project Structure

```
lib/
├── models/
│   ├── project_model.dart
│   ├── company_model.dart
│   └── favorites_manager.dart
├── screens/
│   ├── admin/
│   │   ├── user_management_screen.dart
│   │   ├── review_moderation_screen.dart
│   │   └── company_management_screen.dart
│   ├── internship/
│   │   ├── internship_list_screen.dart
│   │   ├── internship_detail_screen.dart
│   │   └── internship_review_form.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── internship_review_form.dart
│   └── project_main/
│       ├── project_submission.dart
│       └── project_requests_notification_screen.dart
├── services/
│   ├── cloudinary_service.dart
│   ├── database_service.dart
│   ├── current_user_service.dart
│   └── [...other services]
└── theme/
    └── app_theme.dart
```

## Key Screens

1. **Profile Screen** - Display user info, owned and joined projects, and internships
2. **Project Detail** - Browse project details with team members, links, and clickable category filters
3. **Internship Detail** - Browse internship with reviews, ratings, and reviewer information
4. **Review Form** - Submit internship feedback with ratings and images
5. **Admin Dashboard** - User, project, and company management
6. **Project Requests** - Request and approve project membership
7. **Landing Page** - Navigate to projects (with category filters) or internships (with search)

## Technical Stack

- **Framework**: Flutter
- **Backend**: Firebase Firestore
- **Image Storage**: Cloudinary
- **URL Launcher**: url_launcher (for opening project links in browser)
- **State Management**: Inherited Widget / Provider
- **UI Components**: Material Design

##  Database Schema

### Collections
- `users` - User profiles and settings
- `projects` - Project information and members
- `internships` - Internship opportunities
- `reviews` - Internship reviews and ratings
- `companies` - Company information

### Subcollections
- `users/{userId}/projects` - User's joined/created projects
- `users/{userId}/project_requests` - Project join requests

## Firebase Configuration

- Project: `senior-pass-step`
- Region: Asia Southeast 1
- Authentication: Email/Password
- Cloud Storage: gs://senior-pass-step.appspot.com

## Theming

Custom theme with:
- Primary Color: Teal (#1B7F7E)
- Secondary Color: Orange/Amber
- Success: Green
- Warning: Yellow
- Bad/Error: Red

## 📹 Usage

### Android Emulator
```bash
flutter run
```

### Web (Chrome)
```bash
flutter run -d chrome
```

### Web (Edge)
```bash
flutter run -d edge
```

## Security Notes

- Firebase rules restrict access to authenticated users
- Student ID used as document ID for users
- Review status requires admin approval before display
- Profile pictures stored on Cloudinary

## Version History

### Latest (April 19, 2026)
- [1f91b05] Add url_launcher package and implement 'More about project' button to open links in browser
- [d537259] Update project buttons on landing page to use category filter instead of search
- [060c991] Fix overflow in internship review form with Flexible widgets

### Previous Sessions
- [de52210] Add image upload to Cloudinary in internship review and display review images with expand functionality
- [779e84b] Auto-sync joined projects to users subcollection when found in members map
- [a61fb53] Fix collection name from Project to projects for member search

### Earlier
- User management with profile pictures
- Project approval workflow
- Firebase login and authentication

## Contributing

Contact development team for contribution guidelines.

## License

All rights reserved.
