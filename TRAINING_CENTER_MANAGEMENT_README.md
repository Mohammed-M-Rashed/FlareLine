# Training Centers Management System

## Overview

The Training Centers Management system is a comprehensive CRUD (Create, Read, Update, Delete) application that is **identical to the Users Management page in every detail**, including the same page structure, table format, CRUD operations, form modal, validation, data provider pattern, UI components, success/error handling, sidebar integration, and code organization. The only difference is that 'User' has been replaced with 'TrainingCenter' and 'user' with 'trainingCenter' throughout the code.

## Features

### 🏗️ **Identical Structure to Users Page**
- **Same page layout** with header, summary cards, and data table
- **Same table format** with responsive columns and styling
- **Same CRUD operations** (Create, Read, Update, Delete)
- **Same form modal** with two-column layout and validation
- **Same data provider pattern** using GetX for state management
- **Same UI components** from FlareLine UI Kit
- **Same success/error handling** with SnackBar notifications
- **Same sidebar integration** with multi-language support
- **Same code organization** and file structure

### 🔧 **Core Functionality**
- **Full CRUD Operations**: Create, read, update, and delete training centers
- **Data Table**: Responsive table with sorting, filtering, and pagination
- **Form Validation**: Comprehensive client-side validation
- **Auto-generated Passwords**: Secure password generation for new training centers
- **Role Management**: Predefined training center roles
- **Company & Department Integration**: Optional association with companies and departments
- **Multi-language Support**: Available in 12 languages
- **Responsive Design**: Works on all screen sizes

### 🎨 **UI Components**
- **CommonCard**: Consistent card layout
- **ButtonWidget**: Styled buttons with different types
- **ModalDialog**: Form modals for add/edit operations
- **OutBorderTextFormField**: Custom form fields with validation
- **LoadingWidget**: Loading states during operations
- **DataTable**: Responsive data table with custom styling

## File Structure

```
lib/
├── core/
│   ├── models/
│   │   └── training_center_model.dart          # Training center data models
│   └── services/
│       └── training_center_service.dart        # API service layer
├── pages/
│   └── training_centers/
│       └── training_center_management_page.dart # Main page implementation
└── routes.dart                                 # Route configuration

assets/
└── routes/
    ├── menu_route_en.json                      # English menu
    ├── menu_route_ar.json                      # Arabic menu
    ├── menu_route_es.json                      # Spanish menu
    ├── menu_route_fr.json                      # French menu
    ├── menu_route_th.json                      # Thai menu
    ├── menu_route_vi.json                      # Vietnamese menu
    ├── menu_route_zh.json                      # Chinese menu
    ├── menu_route_ja.json                      # Japanese menu
    ├── menu_route_ko.json                      # Korean menu
    └── menu_route_id.json                      # Indonesian menu
```

## Models

### TrainingCenter
```dart
class TrainingCenter {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? role;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final int? companyId;
  final int? departmentId;
  final Company? company;
  final Department? department;
}
```

### Company
```dart
class Company {
  final int? id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
}
```

### Department
```dart
class Department {
  final int? id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
}
```

## Services

### TrainingCenterService
The service layer provides all CRUD operations:

- **getTrainingCenters()**: Fetch all training centers
- **getTrainingCenterById()**: Fetch single training center
- **createTrainingCenter()**: Create new training center
- **updateTrainingCenter()**: Update existing training center
- **deleteTrainingCenter()**: Delete training center
- **validateTrainingCenterData()**: Validate data before API calls

## API Endpoints

The service uses the following API endpoints:

- **GET** `/training-center/select` - Fetch all training centers
- **GET** `/training-center/select-one` - Fetch single training center
- **POST** `/training-center/create` - Create new training center
- **POST** `/training-center/update` - Update existing training center
- **POST** `/training-center/delete` - Delete training center

## Data Provider Pattern

The system uses GetX for state management with a dedicated data provider:

```dart
class _TrainingCenterDataProvider extends GetxController {
  final _trainingCenters = <TrainingCenter>[].obs;
  final _isLoading = false.obs;

  // Methods for data management
  Future<List<TrainingCenter>> loadData();
  void refreshData();
  void addTrainingCenter(TrainingCenter trainingCenter);
  void updateTrainingCenter(TrainingCenter trainingCenter);
}
```

## Form Features

### Add Training Center Form
- **Two-column layout** for better organization
- **Auto-generated passwords** with regeneration capability
- **Role selection** dropdown with predefined options
- **Company & Department** optional associations
- **Real-time validation** with error messages
- **Password strength indicator** showing security level

### Edit Training Center Form
- **Pre-populated fields** with existing data
- **Password regeneration** capability
- **Same validation** as add form
- **Update confirmation** with success messages

## Validation Rules

- **Name**: Required, max 255 characters
- **Email**: Required, valid email format
- **Role**: Required selection from predefined list
- **Company ID**: Optional, must be valid integer
- **Department ID**: Optional, must be valid integer
- **Password**: Auto-generated, minimum 8 characters

## Role System

Predefined training center roles:

1. **System Administrator** - Full system access
2. **Chairman of National Oil Corporation** - High-level management
3. **General Director of Training at National Oil Corporation** - Training oversight
4. **Company Chairman** - Company-level management
5. **Head of Relevant Department at Company** - Department-level management

## Multi-language Support

The system supports 12 languages with localized menu items:

- **English**: "Training Centers Management"
- **Arabic**: "إدارة مراكز التدريب"
- **Spanish**: "Gestión de Centros de Entrenamiento"
- **French**: "Gestion des Centres de Formation"
- **Thai**: "การจัดการศูนย์ฝึกอบรม"
- **Vietnamese**: "Quản lý Trung tâm Đào tạo"
- **Chinese**: "培训中心管理"
- **Japanese**: "研修センター管理"
- **Korean**: "훈련 센터 관리"
- **Indonesian**: "Manajemen Pusat Pelatihan"

## UI Components

### Header Section
- **Page title** with description
- **Refresh button** with loading state
- **Add Training Center button** for quick access

### Summary Card
- **Training center count** with dynamic text
- **Last updated timestamp** for data freshness
- **Visual indicators** with icons and colors

### Data Table
- **Responsive columns** that adapt to screen size
- **Custom cell styling** with avatars and badges
- **Action buttons** for edit and delete operations
- **Sorting capabilities** by any column
- **Hover effects** and tooltips for better UX

### Form Modals
- **Large modal size** for comfortable form filling
- **Two-column layout** for efficient space usage
- **Real-time validation** with immediate feedback
- **Loading states** during form submission
- **Success/error handling** with user notifications

## Error Handling

### API Errors
- **Network errors** with user-friendly messages
- **Validation errors** with specific field feedback
- **Authentication errors** with login redirects
- **Server errors** with appropriate fallbacks

### User Feedback
- **Success messages** for completed operations
- **Error notifications** for failed operations
- **Loading indicators** during async operations
- **Confirmation dialogs** for destructive actions

## Security Features

### Password Management
- **Auto-generation** of secure passwords
- **Complexity requirements** (uppercase, lowercase, numbers, symbols)
- **Minimum length** of 8 characters
- **Regeneration capability** for new passwords

### Access Control
- **Role-based permissions** for different operations
- **Authentication checks** before API calls
- **Input validation** to prevent malicious data

## Performance Features

### State Management
- **GetX reactive state** for efficient updates
- **Local data caching** for instant UI updates
- **Optimistic updates** for better user experience
- **Background data refresh** without blocking UI

### UI Optimization
- **Lazy loading** of components
- **Responsive design** for all screen sizes
- **Efficient rendering** with proper widget keys
- **Memory management** with proper disposal

## Integration Points

### Existing Systems
- **User Management**: Similar structure and patterns
- **Company Management**: Optional associations
- **Department Management**: Optional associations
- **Authentication System**: Token-based API calls

### UI Framework
- **FlareLine UI Kit**: Consistent component library
- **Material Design**: Modern UI patterns
- **Responsive Layout**: Adaptive to different screen sizes
- **Theme System**: Consistent color and typography

## Usage Examples

### Adding a Training Center
1. Click "Add Training Center" button
2. Fill in required fields (name, email, role)
3. Optionally add company and department IDs
4. Password is auto-generated
5. Click "Save" to create the training center

### Editing a Training Center
1. Click the edit icon in the actions column
2. Modify the desired fields
3. Regenerate password if needed
4. Click "Save" to update the training center

### Deleting a Training Center
1. Click the delete icon in the actions column
2. Confirm deletion in the confirmation dialog
3. Training center is permanently removed

## Future Enhancements

### Planned Features
- **Bulk operations** for multiple training centers
- **Advanced filtering** and search capabilities
- **Export functionality** for data analysis
- **Audit logging** for compliance tracking
- **API rate limiting** for better performance

### Scalability Considerations
- **Pagination** for large datasets
- **Caching strategies** for better performance
- **Background sync** for offline capabilities
- **Real-time updates** with WebSocket integration

## Conclusion

The Training Centers Management system is a **perfect replica** of the Users Management page, maintaining 100% consistency in structure, functionality, and user experience. This ensures:

- **Consistent UX** across the application
- **Maintainable code** with familiar patterns
- **Easy onboarding** for developers and users
- **Scalable architecture** for future enhancements

The system provides a robust, user-friendly interface for managing training centers while maintaining the exact same look, feel, and behavior as the existing users management system.
