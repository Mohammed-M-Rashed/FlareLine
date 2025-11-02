import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/company_model.dart';
import 'package:flareline/core/services/company_service.dart';
import 'package:flareline/core/services/country_service.dart';
import 'package:flareline/core/services/city_service.dart';
import 'package:flareline/core/models/country_model.dart';
import 'package:flareline/core/models/city_model.dart';
import 'package:flareline/core/widgets/company_image_picker.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:toastification/toastification.dart';

import 'package:get/get.dart';
import 'dart:convert'; // Added for base64Decode
import 'package:collection/collection.dart'; // Added for firstWhereOrNull
import 'dart:typed_data'; // Added for Uint8List
import 'dart:async'; // Added for Completer
import 'package:file_picker/file_picker.dart'; // Added for PlatformFile

class CompanyManagementPage extends LayoutWidget {
  const CompanyManagementPage({super.key});


  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        CompanyManagementWidget(),
      ],
    );
  }
}

class CompanyManagementWidget extends StatefulWidget {
  const CompanyManagementWidget({super.key});

  @override
  State<CompanyManagementWidget> createState() => _CompanyManagementWidgetState();
}

class _CompanyManagementWidgetState extends State<CompanyManagementWidget> {
  late CityDataProvider _cityDataProvider;

  @override
  void initState() {
    super.initState();
    // Initialize the data provider early to start loading data
    _cityDataProvider = Get.put(CityDataProvider(), permanent: true);
  }

  @override
  void dispose() {
    // Don't dispose the provider here as it might be used elsewhere
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<CompanyDataProvider>(
          init: CompanyDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, CompanyDataProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage system companies and their information',
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
                            onTap: provider.isLoading ? null : () async {
                              try {
                                await provider.refreshData();
                                _showSuccessToast('Companies data refreshed successfully');
                              } catch (e, stackTrace) {
                                print('═══════════════════════════════════════');
                                print('❌ [Company Management] Refresh Error');
                                print('═══════════════════════════════════════');
                                print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
                                print('🔴 Error Type: ${e.runtimeType}');
                                print('📝 Error Message: ${e.toString()}');
                                print('📍 Stack Trace:');
                                print(stackTrace.toString());
                                print('═══════════════════════════════════════');
                                _showErrorToast('خطأ في تحديث بيانات الشركات: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (CompanyService.hasCompanyManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'Add Company',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddCompanyForm(context);
                                  },
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  if (!CompanyService.hasCompanyManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage companies. Only System Administrators can access this functionality.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Obx(() {
                    if (provider.isLoading) {
                      return const LoadingWidget();
                    }

                    final companies = provider.companies;

                    if (companies.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد شركات',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding your first company',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ButtonWidget(
                              btnText: 'Add First Company',
                              type: 'primary',
                              onTap: () {
                                _showAddCompanyForm(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company count and summary
                        CountSummaryWidgetEn(
                          count: companies.length,
                          itemName: 'company',
                          itemNamePlural: 'companies',
                          icon: Icons.business,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        
                        // Data table
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              width: double.infinity,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.resolveWith(
                                  (states) => GlobalColors.lightGray,
                                ),
                                horizontalMargin: 12,
                                showBottomBorder: true,
                                showCheckboxColumn: false,
                                headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                dividerThickness: 1,
                                columnSpacing: 8,
                                dataTextStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                dataRowMinHeight: 60,
                                dataRowMaxHeight: 60,
                                headingRowHeight: 50,
                                columns: [
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Name',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Country',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Phone',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'API URL',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Actions',
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                ],
                                rows: provider.pagedCompanies
                                    .map((company) => DataRow(
                                          onSelectChanged: (selected) {},
                                          cells: [
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 120,
                                                  maxWidth: 180,
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Company Logo or Placeholder
                                                    (company.image != null && company.image!.isNotEmpty)
                                                        ? _buildCompanyImage(company.image!)
                                                        : _buildCompanyPlaceholder(company.name),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        company.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                child: GetBuilder<CityDataProvider>(
                                                  builder: (cityProvider) {
                                                    String countryName = _getCountryNameSync(company, cityProvider);
                                                    return Text(
                                                      countryName,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black87,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 100,
                                                  maxWidth: 150,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  child: Text(
                                                    company.phone ?? 'No phone',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 11,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 100,
                                                  maxWidth: 150,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  child: Text(
                                                    company.apiUrl ?? 'No API URL',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 11,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // View button
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.visibility,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      _showViewCompanyDialog(context, company);
                                                    },
                                                    tooltip: 'View Details',
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: Colors.grey.shade50,
                                                      foregroundColor: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Edit button
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      _showEditCompanyForm(context, company);
                                                    },
                                                    tooltip: 'Edit Company',
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: Colors.blue.shade50,
                                                      foregroundColor: Colors.blue.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Pagination controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Rows per page:',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: provider.rowsPerPage,
                              items: const [10, 20, 50]
                                  .map((n) => DropdownMenuItem<int>(
                                        value: n,
                                        child: Text('$n', style: TextStyle(fontSize: 12)),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) provider.setRowsPerPage(value);
                              },
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Page ${provider.currentPage + 1} of ${provider.totalPages}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 20),
                              onPressed: provider.currentPage > 0
                                  ? () => provider.prevPage()
                                  : null,
                              tooltip: 'Previous page',
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 20),
                              onPressed: (provider.currentPage + 1) < provider.totalPages
                                  ? () => provider.nextPage()
                                  : null,
                              tooltip: 'Next page',
                            ),
                          ],
                        ),
                      ],
                    );
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCompanyForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final apiUrlController = TextEditingController();
    String? selectedImageBase64; // Store selected image as BASE64 (for display)
    PlatformFile? selectedImageFile; // Store selected image file (for upload)
    int? selectedCountryId;
    int? selectedCityId;

    ModalDialog.show(
      context: context,
      title: 'Add New Company',
      showTitle: true,
      modalType: ModalType.large, // Changed to large to accommodate image picker
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false; // Loading state for form submission
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.7, // Full screen height
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Logo Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Company Logo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: CompanyImagePicker(
                                  width: 200,
                                  height: 200,
                                  onImageChanged: (String? base64Image) {
                                    selectedImageBase64 = base64Image;
                                  },
                                  onImageFileChanged: (PlatformFile? imageFile) {
                                    selectedImageFile = imageFile;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Company Information Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Company Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Name Field
                              OutBorderTextFormField(
                                labelText: 'Company Name',
                                hintText: 'Enter company name',
                                controller: nameController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a company name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Company name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Address Field
                              OutBorderTextFormField(
                                labelText: 'Address',
                                hintText: 'Enter company address',
                                controller: addressController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a company address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Country Dropdown
                              _buildCountryDropdown(
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCountryId = value;
                                  selectedCityId = null; // Reset city when country changes
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                              
                              // City Dropdown
                              _buildCityDropdown(
                                selectedCityId: selectedCityId,
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCityId = value;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                               
                              // Phone Field
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Phone number must start with 091, 092, 093, 094, or 120 and contain exactly 7 digits after the prefix (e.g., 0911234567)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutBorderTextFormField(
                                labelText: 'Phone Number',
                                hintText: 'Enter company phone number (e.g., 0911234567)',
                                controller: phoneController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: _validatePhoneNumber,
                              ),
                              const SizedBox(height: 16),
                               
                              // API URL Field
                              OutBorderTextFormField(
                                labelText: 'API URL',
                                hintText: 'Enter company API URL (optional)',
                                controller: apiUrlController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    // Basic URL validation
                                    final uri = Uri.tryParse(value.trim());
                                    if (uri == null || !uri.hasAbsolutePath) {
                                      return 'Please enter a valid URL';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Loading Overlay
                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Creating Company...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please wait while we process your request',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      onSaveTap: () async {
        if (formKey.currentState!.validate()) {
          // Set loading state using a callback approach
          final completer = Completer<void>();
          
          // Show loading state
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Creating Company...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = CompanyCreateRequest(
              name: nameController.text.trim(),
              address: addressController.text.trim(),
              phone: phoneController.text.trim(),
              apiUrl: apiUrlController.text.trim().isEmpty ? null : apiUrlController.text.trim(), // Include API URL if provided
              image: null, // Don't send base64 in request when using multipart
              countryId: selectedCountryId,
              cityId: selectedCityId,
            );
            
            final response = await CompanyService.createCompany(
              request,
              imageFile: selectedImageFile, // Pass image file for multipart upload
            );
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<CompanyDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn);
            } else {
              print('═══════════════════════════════════════');
              print('❌ [Company Management] Create Company Failed');
              print('═══════════════════════════════════════');
              print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
              print('🔴 Success: ${response.success}');
              print('📝 Message (EN): ${response.messageEn}');
              print('📝 Message (AR): ${response.messageAr}');
              print('🔢 Status Code: ${response.statusCode}');
              print('═══════════════════════════════════════');
              throw Exception(response.messageEn);
            }
          } catch (e, stackTrace) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            print('═══════════════════════════════════════');
            print('❌ [Company Management] Create Company Exception');
            print('═══════════════════════════════════════');
            print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
            print('🔴 Error Type: ${e.runtimeType}');
            print('📝 Error Message: ${e.toString()}');
            print('📍 Stack Trace:');
            print(stackTrace.toString());
            print('═══════════════════════════════════════');
            
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  void _showEditCompanyForm(BuildContext context, Company company) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: company.name);
    final addressController = TextEditingController(text: company.address);
    final phoneController = TextEditingController(text: company.phone);
    final apiUrlController = TextEditingController(text: company.apiUrl); // Initialize with existing API URL
    String? selectedImageBase64 = company.image; // Initialize with existing image (for display)
    PlatformFile? selectedImageFile; // Store new image file (for upload)
    int? selectedCountryId = company.countryId;
    int? selectedCityId = company.cityId;

    ModalDialog.show(
      context: context,
      title: 'Edit Company',
      showTitle: true,
      modalType: ModalType.large, // Changed to large to accommodate image picker
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false; // Loading state for form submission
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.7, // Full screen height
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Logo Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Company Logo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: CompanyImagePicker(
                                  width: 200,
                                  height: 200,
                                  initialImage: company.image, // Pass existing image
                                  onImageChanged: (String? base64Image) {
                                    selectedImageBase64 = base64Image;
                                  },
                                  onImageFileChanged: (PlatformFile? imageFile) {
                                    selectedImageFile = imageFile;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Company Information Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Company Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Name Field
                              OutBorderTextFormField(
                                labelText: 'Company Name',
                                hintText: 'Enter company name',
                                controller: nameController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a company name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Company name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Address Field
                              OutBorderTextFormField(
                                labelText: 'Address',
                                hintText: 'Enter company address',
                                controller: addressController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a company address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Country Dropdown
                              _buildCountryDropdown(
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCountryId = value;
                                  selectedCityId = null; // Reset city when country changes
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                              
                              // City Dropdown
                              _buildCityDropdown(
                                selectedCityId: selectedCityId,
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCityId = value;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                               
                              // Phone Field
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Phone number must start with 091, 092, 093, 094, or 120 and contain exactly 7 digits after the prefix (e.g., 0911234567)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutBorderTextFormField(
                                labelText: 'Phone Number',
                                hintText: 'Enter company phone number (e.g., 0911234567)',
                                controller: phoneController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: _validatePhoneNumber,
                              ),
                              const SizedBox(height: 16),
                               
                              // API URL Field
                              OutBorderTextFormField(
                                labelText: 'API URL',
                                hintText: 'Enter company API URL (optional)',
                                controller: apiUrlController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    // Basic URL validation
                                    final uri = Uri.tryParse(value.trim());
                                    if (uri == null || !uri.hasAbsolutePath) {
                                      return 'Please enter a valid URL';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Loading Overlay
                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Updating Company...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please wait while we process your request',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      onSaveTap: () async {
        if (formKey.currentState!.validate()) {
          // Show loading state
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Updating Company...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = CompanyUpdateRequest(
              id: company.id!,
              name: nameController.text.trim(),
              address: addressController.text.trim(),
              phone: phoneController.text.trim(),
              apiUrl: apiUrlController.text.trim(), // Include API URL
              image: null, // Don't send base64 in request when using multipart
              countryId: selectedCountryId,
              cityId: selectedCityId,
            );
            
            final response = await CompanyService.updateCompany(
              request,
              imageFile: selectedImageFile, // Pass image file for multipart upload
            );
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<CompanyDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn);
            } else {
              print('═══════════════════════════════════════');
              print('❌ [Company Management] Update Company Failed');
              print('═══════════════════════════════════════');
              print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
              print('🆔 Company ID: ${company.id}');
              print('🔴 Success: ${response.success}');
              print('📝 Message (EN): ${response.messageEn}');
              print('📝 Message (AR): ${response.messageAr}');
              print('🔢 Status Code: ${response.statusCode}');
              print('═══════════════════════════════════════');
              throw Exception(response.messageEn);
            }
          } catch (e, stackTrace) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            print('═══════════════════════════════════════');
            print('❌ [Company Management] Update Company Exception');
            print('═══════════════════════════════════════');
            print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
            print('🆔 Company ID: ${company.id}');
            print('🔴 Error Type: ${e.runtimeType}');
            print('📝 Error Message: ${e.toString()}');
            print('📍 Stack Trace:');
            print(stackTrace.toString());
            print('═══════════════════════════════════════');
            
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Company company) {
    ModalDialog.show(
      context: context,
      title: 'Confirm Deletion',
      showTitle: true,
      modalType: ModalType.medium,
      child: Column(
        children: [
          Text(
            'Are you sure you want to delete "${company.name}"? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonWidget(
                btnText: 'Cancel',
                type: 'secondary',
                onTap: () {
                  Get.back();
                },
              ),
              // Delete functionality removed - not supported in new API
              // ButtonWidget(
              //   btnText: 'Delete',
              //   type: 'danger',
              //   onTap: () async {
              //     // Delete company functionality not available in current API
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCompanyDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  // Widget _buildCompanyImage(String imageUrl) {
  //   return Container(
  //     width: 40,
  //     height: 40,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey.shade300),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(8),
  //       child: Image.network(
  //         imageUrl,
  //         width: 40,
  //         height: 40,
  //         fit: BoxFit.cover,
  //         loadingBuilder: (context, child, loadingProgress) {
  //           if (loadingProgress == null) return child;
  //           return Center(
  //             child: SizedBox(
  //               width: 20,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 value: loadingProgress.expectedTotalBytes != null
  //                     ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
  //                     : null,
  //               ),
  //             ),
  //           );
  //         },
  //         errorBuilder: (context, error, stackTrace) {
  //           return _buildCompanyPlaceholder('Error');
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Build full image URL from server
  String _buildCompanyImageUrl(String imageFileName) {
    const baseUrl = 'https://noc.justhost.ly/backend-api/storage/app/public/';
    // Remove any leading slashes or spaces from imageFileName
    final cleanFileName = imageFileName.trim().replaceFirst(RegExp(r'^/'), '');
    return '$baseUrl$cleanFileName';
  }

  Widget _buildCompanyImage(String imageFileName) {
    final imageUrl = _buildCompanyImageUrl(imageFileName);
    
    print('🖼️ [Company Image] Building image widget');
    print('   📁 Image file name: $imageFileName');
    print('   🔗 Full URL: $imageUrl');
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('✅ [Company Image] Image loaded successfully: $imageUrl');
              return child;
            }
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ [Company Image] Error loading image: $imageUrl');
            print('   Error: $error');
            return _buildCompanyPlaceholder('خطأ');
          },
        ),
      ),
    );
  }

  Widget _buildCompanyPlaceholder(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Validates phone number format according to business rules
  /// Must start with 091, 092, 093, 094, or 120 and contain exactly 7 digits after prefix
  String? _validatePhoneNumber(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Please enter a phone number';
    }
    
    final phoneNumber = value.toString().trim();
    
    // Check if phone number starts with valid prefixes
    final validPrefixes = ['091', '092', '093', '094', '120'];
    bool hasValidPrefix = false;
    
    for (String prefix in validPrefixes) {
      if (phoneNumber.startsWith(prefix)) {
        hasValidPrefix = true;
        break;
      }
    }
    
    if (!hasValidPrefix) {
      return 'Phone number must start with 091, 092, 093, 094, or 120';
    }
    
    // Check if the remaining part after prefix contains exactly 7 digits
    String remainingPart = '';
    if (phoneNumber.startsWith('091') || phoneNumber.startsWith('092') || 
        phoneNumber.startsWith('093') || phoneNumber.startsWith('094')) {
      remainingPart = phoneNumber.substring(3); // Remove 3-digit prefix
    } else if (phoneNumber.startsWith('120')) {
      remainingPart = phoneNumber.substring(3); // Remove 3-digit prefix
    }
    
    // Check if remaining part contains exactly 7 digits
    if (remainingPart.length != 7) {
      return 'Phone number must contain exactly 7 digits after the prefix';
    }
    
    // Check if remaining part contains only digits
    if (!RegExp(r'^[0-9]{7}$').hasMatch(remainingPart)) {
      return 'Phone number must contain only digits after the prefix';
    }
    
    return null; // Validation passed
  }

  /// Shows a success toast notification for company operations in Arabic
  void _showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an error toast notification for company operations in Arabic
  void _showErrorToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  /// Helper method to get country name for a company synchronously
  String _getCountryNameSync(Company company, CityDataProvider cityProvider) {
    // First check if country name is already available from API response
    if (company.countryName != null && company.countryName!.isNotEmpty) {
      return company.countryName!;
    }
    
    // If no country name but we have country ID, try to get it from the provider
    if (company.countryId != null && cityProvider.countries.isNotEmpty) {
      final country = cityProvider.countries.firstWhereOrNull(
        (c) => c.id == company.countryId,
      );
      if (country != null) {
        return country.name;
      }
    }
    
    return 'No country';
  }

  /// Helper method to get city name for a company synchronously
  String _getCityNameSync(Company company, CityDataProvider cityProvider) {
    // First check if city name is already available from API response
    if (company.cityName != null && company.cityName!.isNotEmpty) {
      return company.cityName!;
    }
    
    // If no city name but we have city ID, try to get it from the provider
    if (company.cityId != null && cityProvider.cities.isNotEmpty) {
      final city = cityProvider.cities.firstWhereOrNull(
        (c) => c.id == company.cityId,
      );
      if (city != null) {
        return city.name;
      }
    }
    
    return 'No city';
  }

  /// Builds country dropdown widget with data loading
  Widget _buildCountryDropdown({
    required int? selectedCountryId,
    required Function(int?) onChanged,
    required bool enabled,
    required StateSetter setModalState,
  }) {
    return GetBuilder<CityDataProvider>(
      builder: (cityProvider) {
        // Ensure data is loaded
        if (cityProvider.countries.isEmpty && !cityProvider.isLoadingCountries) {
          // Trigger loading if not already started
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cityProvider.loadCountries();
          });
        }
        
        // Show loading indicator while data is being fetched
        if (cityProvider.isLoadingCountries || (cityProvider.countries.isEmpty && !cityProvider.isLoadingCountries)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Country',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: cityProvider.isLoadingCountries 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Loading countries...',
                        style: TextStyle(color: Colors.grey),
                      ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<int>(
                value: selectedCountryId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                ),
                hint: const Text('Select Country'),
                items: cityProvider.countries.map((Country country) {
                  return DropdownMenuItem<int>(
                    value: country.id,
                    child: Text(country.name),
                  );
                }).toList(),
                onChanged: enabled ? (int? value) {
                  setModalState(() {
                    onChanged(value);
                  });
                  cityProvider.setSelectedCountry(value);
                } : null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a country';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds city dropdown widget with data loading and filtering
  Widget _buildCityDropdown({
    required int? selectedCityId,
    required int? selectedCountryId,
    required Function(int?) onChanged,
    required bool enabled,
    required StateSetter setModalState,
  }) {
    return GetBuilder<CityDataProvider>(
      builder: (cityProvider) {
        // Ensure cities are loaded
        if (cityProvider.cities.isEmpty && !cityProvider.isLoading) {
          // Trigger loading if not already started
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cityProvider.refreshData();
          });
        }
        
        final filteredCities = cityProvider.cities
            .where((city) => city.countryId == selectedCountryId)
            .toList();
        
        // Show loading indicator while cities are being fetched
        if (cityProvider.isLoading || (cityProvider.cities.isEmpty && !cityProvider.isLoading)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: cityProvider.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Loading cities...',
                        style: TextStyle(color: Colors.grey),
                      ),
                ),
              ),
            ],
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<int>(
                value: selectedCityId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                ),
                hint: Text(selectedCountryId == null ? 'Select Country First' : 'Select City'),
                items: filteredCities.map((City city) {
                  return DropdownMenuItem<int>(
                    value: city.id,
                    child: Text(city.name),
                  );
                }).toList(),
                onChanged: enabled && selectedCountryId != null ? (int? value) {
                  setModalState(() {
                    onChanged(value);
                  });
                } : null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showViewCompanyDialog(BuildContext context, Company company) {
    ModalDialog.show(
      context: context,
      title: 'Company Details',
      showTitle: true,
      modalType: ModalType.large,
      showCancel: false, // Disable default buttons
      footer: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 120,
              child: ButtonWidget(
                btnText: 'Cancel',
                textColor: FlarelineColors.darkBlackText,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Information Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Company Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Company Name', company.name),
                        if (company.address != null && company.address!.isNotEmpty)
                          _buildDetailRow('Address', company.address!),
                        GetBuilder<CityDataProvider>(
                          builder: (cityProvider) {
                            final countryName = _getCountryNameSync(company, cityProvider);
                            if (countryName != 'No country') {
                              return _buildDetailRow('Country', countryName);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        GetBuilder<CityDataProvider>(
                          builder: (cityProvider) {
                            final cityName = _getCityNameSync(company, cityProvider);
                            if (cityName != 'No city') {
                              return _buildDetailRow('City', cityName);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        if (company.phone != null && company.phone!.isNotEmpty)
                          _buildDetailRow('Phone', company.phone!),
                        if (company.apiUrl != null && company.apiUrl!.isNotEmpty)
                          _buildDetailRow('API URL', company.apiUrl!),
                        if (company.image != null && company.image!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Company Logo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _buildCompanyImageUrl(company.image!),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / 
                                              loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        if (company.createdAt != null)
                          _buildDetailRow('Created At', _formatCompanyDate(company.createdAt)),
                        if (company.updatedAt != null)
                          _buildDetailRow('Updated At', _formatCompanyDate(company.updatedAt)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyDataProvider extends GetxController {
  final _companies = <Company>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  int get totalItems => _companies.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  List<Company> get pagedCompanies {
    if (totalItems == 0) return const <Company>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedCompanies;
    }
    if (end > totalItems) end = totalItems;
    return _companies.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<List<Company>> loadData() async {
    try {
      _isLoading.value = true;
      final response = await CompanyService.getAllCompanies();
      
      if (response.success) {
        _companies.value = response.data;
        _currentPage.value = 0; // reset page on new data
        
        // Debug: Print company images
        print('═══════════════════════════════════════');
        print('📊 [Company Management] Loaded ${response.data.length} companies');
        print('═══════════════════════════════════════');
        for (var company in response.data) {
          print('   🏢 ${company.name}: image = ${company.image ?? "null"}');
        }
        print('═══════════════════════════════════════');
        
        return response.data;
      } else {
        print('═══════════════════════════════════════');
        print('❌ [Company Management] Load Data Failed');
        print('═══════════════════════════════════════');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
        print('🔴 Success: ${response.success}');
        print('📝 Message (EN): ${response.messageEn}');
        print('📝 Message (AR): ${response.messageAr}');
        print('🔢 Status Code: ${response.statusCode}');
        print('═══════════════════════════════════════');
        throw Exception(response.messageEn);
      }
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌ [Company Management] Load Data Exception');
      print('═══════════════════════════════════════');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('🔴 Error Type: ${e.runtimeType}');
      print('📝 Error Message: ${e.toString()}');
      print('📍 Stack Trace:');
      print(stackTrace.toString());
      print('═══════════════════════════════════════');
      _companies.clear();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    try {
      await loadData();
      update();
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌ [Company Management] Refresh Data Exception');
      print('═══════════════════════════════════════');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('🔴 Error Type: ${e.runtimeType}');
      print('📝 Error Message: ${e.toString()}');
      print('📍 Stack Trace:');
      print(stackTrace.toString());
      print('═══════════════════════════════════════');
      rethrow;
    }
  }


  void setRowsPerPage(int value) {
    _rowsPerPage.value = value;
    _currentPage.value = 0;
    update();
  }

  void nextPage() {
    if ((currentPage + 1) * rowsPerPage < totalItems) {
      _currentPage.value++;
      update();
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      _currentPage.value--;
      update();
    }
  }
}
