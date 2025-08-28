# Table Design Standardization Guide

## Overview
This document outlines the standardized design patterns that should be applied to all tables across the FlareLine application to ensure consistency and professional appearance.

## Standardized Components

### 1. Header Section
```dart
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[Page Title]',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '[Page Description]',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      Row(
        children: [
          SizedBox(
            width: 120,
            child: Obx(() => ButtonWidget(
              btnText: provider.isLoading ? 'Loading...' : 'Refresh',
              type: 'secondary',
              onTap: provider.isLoading ? null : () {
                provider.refreshData();
              },
            )),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 140,
            child: ButtonWidget(
              btnText: 'Add [Item]',
              type: 'primary',
              onTap: () {
                _showAddForm(context);
              },
            ),
          ),
        ],
      ),
    ],
  ),
)
```

### 2. Summary Section
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.blue.shade200),
  ),
  child: Row(
    children: [
      Icon(
        Icons.[relevant_icon],
        color: Colors.blue.shade600,
        size: 24,
      ),
      const SizedBox(width: 12),
      Text(
        '${items.length} [item]${items.length == 1 ? '' : 's'} found',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
      const Spacer(),
      Text(
        'Last updated: ${DateTime.now().toString().substring(0, 19)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade600,
        ),
      ),
    ],
  ),
)
```

### 3. DataTable Configuration
```dart
LayoutBuilder(
  builder: (context, constraints) {
    return Container(
      width: double.infinity,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith(
          (states) => GlobalColors.lightGray,
        ),
        horizontalMargin: constraints.maxWidth > 1200 ? 24 : 16,
        showBottomBorder: true,
        showCheckboxColumn: false,
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: constraints.maxWidth > 1200 ? 16 : 14,
        ),
        dividerThickness: 1,
        columnSpacing: constraints.maxWidth > 1200 ? 32 : 24,
        dataTextStyle: TextStyle(
          fontSize: constraints.maxWidth > 1200 ? 15 : 14,
          color: Colors.black87,
        ),
        dataRowMinHeight: 80,
        dataRowMaxHeight: 80,
        headingRowHeight: 60,
        // ... columns and rows
      ),
    );
  },
)
```

### 4. DataCell Styling Patterns

#### Avatar + Text Pattern (for Name/Title columns)
```dart
DataCell(
  Container(
    constraints: BoxConstraints(
      minWidth: constraints.maxWidth > 1200 ? 180 : 150,
      maxWidth: constraints.maxWidth > 1200 ? 220 : 200,
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            item.name.isNotEmpty ? item.name[0].toUpperCase() : 'X',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          radius: constraints.maxWidth > 1200 ? 20 : 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: constraints.maxWidth > 1200 ? 15 : 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (item.subtitle != null)
                Text(
                  item.subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

#### Tag-Style Pattern (for Status/Role columns)
```dart
DataCell(
  Container(
    constraints: BoxConstraints(
      minWidth: constraints.maxWidth > 1200 ? 140 : 120,
      maxWidth: constraints.maxWidth > 1200 ? 200 : 180,
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.[color].shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.[color].shade200,
          width: 1,
        ),
      ),
      child: Text(
        item.status,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: constraints.maxWidth > 1200 ? 14 : 13,
          color: Colors.[color].shade700,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ),
)
```

#### Action Buttons Pattern
```dart
DataCell(
  Container(
    constraints: BoxConstraints(
      minWidth: constraints.maxWidth > 1200 ? 120 : 100,
      maxWidth: constraints.maxWidth > 1200 ? 140 : 120,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit,
            size: constraints.maxWidth > 1200 ? 22 : 20,
          ),
          onPressed: () {
            _showEditForm(context, item);
          },
          tooltip: 'Edit [Item]',
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.delete,
            size: constraints.maxWidth > 1200 ? 22 : 20,
          ),
          onPressed: () {
            _showDeleteConfirmation(context, item);
          },
          tooltip: 'Delete [Item]',
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
        ),
      ],
    ),
  ),
)
```

### 5. Empty State Pattern
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.[relevant_icon]_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      const SizedBox(height: 16),
      Text(
        'No [items] found',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Get started by adding your first [item]',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
        ),
      ),
      const SizedBox(height: 16),
      ButtonWidget(
        btnText: 'Add First [Item]',
        type: 'primary',
        onTap: () {
          _showAddForm(context);
        },
      ),
    ],
  ),
)
```

### 6. Error State Pattern
```dart
Center(
  child: Padding(
    padding: const EdgeInsets.all(32.0),
    child: Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          'Error loading [items]: ${snapshot.error}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ButtonWidget(
          btnText: 'Retry',
          type: 'secondary',
          onTap: () {
            provider.refreshData();
          },
        ),
      ],
    ),
  ),
)
```

## Color Scheme

### Primary Colors
- **Blue**: `Colors.blue.shade50` to `Colors.blue.shade800` (for primary actions, company info)
- **Green**: `Colors.green.shade50` to `Colors.green.shade700` (for success states, department info)
- **Purple**: `Colors.purple.shade50` to `Colors.purple.shade700` (for roles, special statuses)
- **Orange**: `Colors.orange.shade50` to `Colors.orange.shade700` (for warnings, industry info)
- **Red**: `Colors.red.shade50` to `Colors.red.shade700` (for delete actions, errors)

### Text Colors
- **Primary**: `Colors.black87`
- **Secondary**: `Colors.grey[600]`
- **Muted**: `Colors.grey[500]`
- **Light**: `Colors.grey[400]`

## Responsive Breakpoints

- **Desktop**: `constraints.maxWidth > 1200`
- **Tablet**: `constraints.maxWidth <= 1200`

### Responsive Values
- **Font Sizes**: 16px (desktop) / 14px (tablet)
- **Icon Sizes**: 22px (desktop) / 20px (tablet)
- **Avatar Radius**: 20px (desktop) / 18px (tablet)
- **Margins**: 24px (desktop) / 16px (tablet)
- **Spacing**: 32px (desktop) / 24px (tablet)

## Implementation Checklist

- [ ] Header section with consistent styling
- [ ] Summary section with count and timestamp
- [ ] Responsive DataTable configuration
- [ ] Consistent DataCell styling patterns
- [ ] Proper action button styling
- [ ] Empty and error state handling
- [ ] Responsive constraints and spacing
- [ ] Consistent color scheme application
- [ ] Proper icon usage and sizing
- [ ] Tooltip implementation for actions

## Files to Standardize

1. ✅ `lib/pages/companies/company_management_page.dart` - COMPLETED
2. ✅ `lib/pages/courses/course_management_page.dart` - COMPLETED
3. ✅ `lib/pages/departments/department_management_page.dart` - COMPLETED
4. ✅ `lib/pages/specializations/specialization_management_page.dart` - COMPLETED
5. ✅ `lib/pages/training_centers/training_center_management_page.dart` - COMPLETED
6. ✅ `lib/pages/training_programs/training_program_management_page.dart` - COMPLETED
7. ✅ `lib/pages/users/user_management_page.dart` - REFERENCE IMPLEMENTATION
