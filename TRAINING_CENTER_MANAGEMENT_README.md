# Training Centers Management System

## Overview

The Training Centers Management system is a comprehensive CRUD (Create, Read, Update) application that integrates with the new Training Centers API. The system follows the same architecture and design patterns as the Companies Management page, ensuring consistency across the application.

## Features

### 🏗️ **Consistent Architecture**
- **Same page layout** with header, summary cards, and data table
- **Same table format** with responsive columns and styling
- **Same CRUD operations** (Create, Read, Update)
- **Same form modal** with validation and error handling
- **Same data provider pattern** using GetX for state management
- **Same UI components** from FlareLine UI Kit
- **Same success/error handling** with toast notifications
- **Same permission system** with role-based access control

### 🔧 **Core Functionality**
- **Full CRUD Operations**: Create, read, and update training centers
- **Data Table**: Responsive table with sorting and filtering
- **Form Validation**: Comprehensive client-side and server-side validation
- **Role-based Access**: Only System Administrators can manage training centers
- **Real-time API Integration**: All operations use live API endpoints
- **Error Handling**: Comprehensive error handling with bilingual messages
- **Responsive Design**: Works on all screen sizes

### 🎨 **UI Components**
- **CommonCard**: Consistent card layout
- **ButtonWidget**: Styled buttons with different types
- **ModalDialog**: Form modals for add/edit operations
- **OutBorderTextFormField**: Custom form fields with validation
- **LoadingWidget**: Loading states for better UX
- **Toast Notifications**: Success, error, and info messages

## API Integration

### **New API Endpoints**
The system integrates with the following Training Centers API endpoints:

- `POST /api/training-center/create` - Create a new training center
- `POST /api/training-center/select` - Retrieve all training centers
- `POST /api/training-center/update` - Update an existing training center

### **API Response Format**
All API responses follow the standardized format:
```json
{
    "data": [...], // Array of training centers or single object
    "m_ar": "Arabic message",
    "m_en": "English message",
    "status_code": 200
}
```

### **Authentication**
- **JWT Bearer Token** required for all operations
- **System Administrator role** required for all operations
- Automatic token validation and error handling

## Data Model

### **Training Center Fields**
- `id`: Primary key (auto-increment, integer)
- `name`: Training center name (string, max 255 characters, required)
- `email`: Unique email address (string, unique, required)
- `phone`: Contact phone number (string, max 20 characters, required)
- `address`: Physical address (text, required)
- `website`: Website URL (string, nullable, max 255 characters, optional)
- `description`: Description (text, nullable, optional)
- `status`: Status (enum: 'pending', 'approved', 'rejected', default: 'pending')
- `created_at`: Creation timestamp (automatically managed)
- `updated_at`: Last update timestamp (automatically managed)

### **Request Models**
- `TrainingCenterCreateRequest`: For creating new training centers
- `TrainingCenterUpdateRequest`: For updating existing training centers
- `TrainingCenterListResponse`: For listing training centers
- `TrainingCenterResponse`: For single training center operations

## File Structure

```
lib/
├── core/
│   ├── models/
│   │   └── training_center_model.dart          # Training center data models
│   ├── services/
│   │   └── training_center_service.dart        # API service for training centers
│   └── config/
│       └── api_endpoints.dart                  # API endpoint configuration
└── pages/
    └── training_centers/
        └── training_center_management_page.dart # Main UI component
```

## Usage

### **Accessing Training Center Management**

1. Navigate to the Training Center Management page
2. The system automatically checks if the current user has System Administrator role
3. If authorized, the full interface is displayed
4. If not authorized, a permission denied message is shown

### **Creating a Training Center**

1. Click the "Add Training Center" button
2. Fill in the required fields:
   - **Training Center Name** (required, max 255 characters)
   - **Email Address** (required, valid email format, unique)
   - **Phone Number** (required, max 20 characters)
   - **Address** (required)
3. Fill in optional fields:
   - **Website** (valid URL format, max 255 characters)
   - **Description** (unlimited text)
   - **Status** (pending/approved/rejected, defaults to pending)
4. Click "Create Training Center" to save
5. The system will show a success message and refresh the training center list

### **Editing a Training Center**

1. Click the edit icon (pencil) next to any training center in the table
2. Modify the desired fields
3. Click "Update Training Center" to save changes
4. The system will show a success message and refresh the data

### **Viewing Training Centers**

- All training centers are automatically loaded when the page loads
- Training centers are displayed in a data table with columns for:
  - **Training Center** (name with icon and description)
  - **Email** (contact email address)
  - **Phone** (contact phone number)
  - **Address** (physical address)
  - **Website** (clickable URL or N/A)
  - **Status** (pending/approved/rejected with color coding)
  - **Created** (creation date)
  - **Actions** (Edit button)

## Permission System

### **Required Role**
- **System Administrator** (`system_administrator`)

### **Access Control**
- The system checks user roles through the `AuthController`
- Only users with the `system_administrator` role can:
  - View the training center management interface
  - Create new training centers
  - Edit existing training centers
  - View training center data

### **Unauthorized Access**
- Users without proper permissions see a clear message explaining the restriction
- No training center data is displayed to unauthorized users
- The "Add Training Center" button is hidden for unauthorized users

## Error Handling

### **Network Errors**
- Connection failures are caught and displayed to the user
- Retry functionality is provided for failed data loading operations
- User-friendly error messages in both Arabic and English

### **Validation Errors**
- Client-side validation prevents invalid data submission
- Server-side validation errors are displayed to the user
- Field-specific error messages for better user experience

### **API Errors**
- HTTP status codes are properly handled
- Error messages from the API are displayed to the user
- Fallback error messages for unexpected errors

## Validation Rules

### **Create Training Center**
- `name`: Required, string, maximum 255 characters
- `email`: Required, valid email format, must be unique
- `phone`: Required, string, maximum 20 characters
- `address`: Required, string
- `website`: Optional, valid URL format, maximum 255 characters
- `description`: Optional, string
- `status`: Optional, must be either 'pending', 'approved', or 'rejected'

### **Update Training Center**
- `id`: Required, must exist in training_centers table
- `name`: Optional, string, maximum 255 characters
- `email`: Optional, valid email format, must be unique (excluding current record)
- `phone`: Optional, string, maximum 20 characters
- `address`: Optional, string
- `website`: Optional, valid URL format, maximum 255 characters
- `description`: Optional, string
- `status`: Optional, must be either 'pending', 'approved', or 'rejected'

## Dependencies

### **Required Modules**
- **Users**: For authentication and authorization
- **Training Centers**: Core entity for the system

### **Related Modules**
- **Training Center Branches**: Extensions of training centers
- **Course Offerings**: Can be associated with training centers
- **Companies**: May have relationships with training centers
- **Specializations**: May be offered at specific training centers

### **Database Dependencies**
- `training_centers` table must exist
- `users` table for authentication
- Foreign key constraints ensure data integrity

## Notes and Considerations

### **Status Management**
- Training centers can be marked as 'pending', 'approved', or 'rejected'
- Status changes affect the approval workflow of the center in the system
- Default status is 'pending' when creating new centers

### **Data Consistency**
- All operations use database transactions
- Email addresses must be unique across all training centers
- Error handling includes proper rollback mechanisms

### **Authorization**
- Only users with System Administrator role can manage training centers
- All endpoints require valid JWT authentication
- Role-based access control is enforced at the middleware level

### **Response Format**
- All responses include bilingual messages (Arabic and English)
- Consistent data structure across all endpoints
- HTTP status codes indicate operation success/failure
- Error messages provide clear guidance for troubleshooting

## Implementation Details

### **State Management**
- Uses GetX for reactive state management
- `TrainingCenterDataProvider` handles data operations
- Observable lists for real-time UI updates

### **API Service**
- `TrainingCenterService` handles all API communications
- Automatic token management and authentication
- Comprehensive error handling and validation

### **UI Components**
- Responsive design with mobile-first approach
- Consistent styling using FlareLine UI Kit
- Accessibility features for better user experience

This documentation provides a complete reference for the Training Centers Management system, which follows the same architecture and design patterns as the Companies Management page while integrating with the new Training Centers API.
