# Company Management System

This document describes the implementation of the company management functionality for the FlareLine application.

## Overview

The company management system allows System Administrators to create, view, and update company information through a Flutter-based user interface that integrates with a Laravel backend API.

## Features

- **Create Companies**: Add new companies with name, address, and phone number
- **View Companies**: Display all companies in a data table format
- **Update Companies**: Edit existing company information
- **Role-based Access Control**: Only System Administrators can access company management
- **Real-time API Integration**: All operations use live API endpoints
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Form Validation**: Client-side validation for all input fields

## API Endpoints

The system integrates with the following Laravel API endpoints:

- `POST /api/company/create` - Create a new company
- `POST /api/company/select` - Retrieve all companies
- `POST /api/company/update` - Update an existing company

## File Structure

```
lib/
├── core/
│   ├── models/
│   │   └── company_model.dart          # Company data models
│   └── services/
│       └── company_service.dart        # API service for companies
└── pages/
    └── companies/
        └── company_management_page.dart # Main UI component
```

## Models

### Company
- `id`: Unique identifier (auto-generated)
- `name`: Company name (required, max 255 characters)
- `address`: Company address (required)
- `phone`: Phone number (required, max 20 characters)
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

### API Response Models
- `CompanyListResponse`: Response for listing companies
- `CompanyResponse`: Response for single company operations
- `CompanyCreateRequest`: Request payload for creating companies
- `CompanyUpdateRequest`: Request payload for updating companies

## Usage

### Accessing Company Management

1. Navigate to the Company Management page
2. The system automatically checks if the current user has System Administrator role
3. If authorized, the full interface is displayed
4. If not authorized, a permission denied message is shown

### Creating a Company

1. Click the "Add Company" button
2. Fill in the required fields:
   - Company Name (required, max 255 characters)
   - Address (required)
   - Phone Number (required, max 20 characters)
3. Click "Save" to create the company
4. The system will show a success message and refresh the company list

### Editing a Company

1. Click the edit icon (pencil) next to any company in the table
2. Modify the desired fields
3. Click "Save" to update the company
4. The system will show a success message and refresh the data

### Viewing Companies

- All companies are automatically loaded when the page loads
- Companies are displayed in a data table with columns for:
  - Name (with company initial avatar)
  - Address
  - Phone Number
  - Creation Date
  - Actions (Edit button)

## Permission System

### Required Role
- **System Administrator** (`system_administrator`)

### Access Control
- The system checks user roles through the `AuthController`
- Only users with the `system_administrator` role can:
  - View the company management interface
  - Create new companies
  - Edit existing companies
  - View company data

### Unauthorized Access
- Users without proper permissions see a clear message explaining the restriction
- No company data is displayed to unauthorized users
- The "Add Company" button is hidden for unauthorized users

## Error Handling

### Network Errors
- Connection failures are caught and displayed to the user
- Retry functionality is provided for failed data loading operations

### Validation Errors
- Client-side validation prevents invalid data submission
- Server-side validation errors are parsed and displayed
- Field-specific error messages guide users to correct issues

### Authentication Errors
- Missing or invalid tokens trigger appropriate error messages
- Users are guided to re-authenticate if needed

## Technical Implementation

### State Management
- Uses GetX for state management
- `CompanyDataProvider` manages company data and loading states
- Reactive updates ensure UI stays synchronized with data

### API Integration
- HTTP requests use Bearer token authentication
- All endpoints require valid JWT tokens
- Response parsing handles both success and error cases
- Proper error handling for various HTTP status codes

### UI Components
- Built using FlareLine UI Kit components
- Responsive design that works on different screen sizes
- Modal dialogs for create/edit operations
- Data table for displaying company information

## Configuration

### API Base URL
The system is configured to use `http://127.0.0.1:8000/api` as the base URL for API calls. This can be modified in the `CompanyService` class.

### Validation Rules
- Company Name: Required, maximum 255 characters
- Address: Required
- Phone Number: Required, maximum 20 characters

## Dependencies

The company management system requires the following Flutter packages:
- `get`: State management
- `http`: API communication
- `flareline_uikit`: UI components

## Future Enhancements

Potential improvements for future versions:
- Company logo upload functionality
- Advanced search and filtering
- Bulk operations (import/export)
- Company hierarchy management
- Audit logging for company changes
- Company status management (active/inactive)

## Troubleshooting

### Common Issues

1. **Permission Denied Error**
   - Ensure the current user has the `system_administrator` role
   - Check that the user is properly authenticated

2. **API Connection Errors**
   - Verify the Laravel backend is running
   - Check the API base URL configuration
   - Ensure network connectivity

3. **Validation Errors**
   - Check that all required fields are filled
   - Verify field length limits are not exceeded
   - Ensure proper data format for each field

### Debug Information
- The system includes comprehensive logging for debugging
- Check console output for detailed error information
- API request/response details are logged for troubleshooting

## Support

For technical support or questions about the company management system, please refer to the development team or create an issue in the project repository.
