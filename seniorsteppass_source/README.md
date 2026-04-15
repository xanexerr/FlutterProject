# SeniorStepPass - Senior Project Management System

A Flutter application that simplifies senior project management and internship tracking for students and administrators.

## 🎯 Features

### Core Features
- **User Management** - Admin panel for managing students and user roles
- **Project Management** - Create, manage, and request projects
- **Internship Tracking** - Browse and select internship opportunities
- **Project Requests** - Request to join projects with approval workflow
- **Review System** - Submit and view internship reviews with ratings

### Recent Updates (Latest Session)

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

#### Review Rating System ⭐
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

#### User Profiles in Reviews 👤
- Display reviewer's profile picture in feedback cards
- Show user initials if no profile picture available
- Graceful fallback to default avatar
- User name and department display

#### Project Management 🚀
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

## 🏗️ Project Structure

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

## 📱 Key Screens

1. **Profile Screen** - Display user info, projects, and internships
2. **Internship Detail** - Browse internship with reviews and ratings
3. **Review Form** - Submit internship feedback with ratings and images
4. **Admin Dashboard** - User, project, and company management
5. **Project Requests** - Request and approve project membership

## 🔧 Technical Stack

- **Framework**: Flutter
- **Backend**: Firebase Firestore
- **Image Storage**: Cloudinary
- **State Management**: Inherited Widget / Provider
- **UI Components**: Material Design

## 📊 Database Schema

### Collections
- `users` - User profiles and settings
- `projects` - Project information and members
- `internships` - Internship opportunities
- `reviews` - Internship reviews and ratings
- `companies` - Company information

### Subcollections
- `users/{userId}/projects` - User's joined/created projects
- `users/{userId}/project_requests` - Project join requests

## 🚀 Firebase Configuration

- Project: `senior-pass-step`
- Region: Asia Southeast 1
- Authentication: Email/Password
- Cloud Storage: gs://senior-pass-step.appspot.com

## 🎨 Theming

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

## 🔐 Security Notes

- Firebase rules restrict access to authenticated users
- Student ID used as document ID for users
- Review status requires admin approval before display
- Profile pictures stored on Cloudinary

## 📝 Version History

### Latest (April 16, 2026)
- [de52210] Add image upload to Cloudinary in internship review and display review images with expand functionality
- [779e84b] Auto-sync joined projects to users subcollection when found in members map
- [a61fb53] Fix collection name from Project to projects for member search

### Previous
- User management with profile pictures
- Project approval workflow
- Firebase login and authentication

## 🤝 Contributing

Contact development team for contribution guidelines.

## 📄 License

All rights reserved.
