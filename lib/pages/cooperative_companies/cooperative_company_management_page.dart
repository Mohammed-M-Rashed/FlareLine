import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/cooperative_company_model.dart';
import 'package:flareline/core/services/cooperative_company_service.dart';
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

class CooperativeCompanyManagementPage extends LayoutWidget {
  const CooperativeCompanyManagementPage({super.key});

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        CooperativeCompanyManagementWidget(),
      ],
    );
  }
}

class CooperativeCompanyManagementWidget extends StatefulWidget {
  const CooperativeCompanyManagementWidget({super.key});

  @override
  State<CooperativeCompanyManagementWidget> createState() => _CooperativeCompanyManagementWidgetState();
}

class _CooperativeCompanyManagementWidgetState extends State<CooperativeCompanyManagementWidget> {
  late CityDataProvider _cityDataProvider;

  @override
  void initState() {
    super.initState();
    print('🚀 [CooperativeCompany] Initializing Cooperative Company Management Widget');
    // Initialize the data provider early to start loading data
    _cityDataProvider = Get.put(CityDataProvider(), permanent: true);
    print('✅ [CooperativeCompany] CityDataProvider initialized successfully');
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
        child: GetBuilder<CooperativeCompanyDataProvider>(
          init: CooperativeCompanyDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, CooperativeCompanyDataProvider provider) {
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cooperative Company Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage cooperative companies in the system',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
                                _showSuccessToast('Cooperative companies data refreshed successfully');
                              } catch (e) {
                                print('❌ [CooperativeCompany] Error refreshing data: $e');
                                print('📍 [CooperativeCompany] Stack trace: ${StackTrace.current}');
                                _showErrorToast('خطأ في تحديث بيانات الشركات التعاونية: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (CooperativeCompanyService.hasCooperativeCompanyManagementPermission()) {
                              return SizedBox(
                                width: 180,
                                child: ButtonWidget(
                                  btnText: 'Add Cooperative Company',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddCooperativeCompanyForm(context);
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
                  if (!CooperativeCompanyService.hasCooperativeCompanyManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage cooperative companies. Only Administrators can access this functionality.',
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
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Cooperative Companies Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding the first cooperative company to the system.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ButtonWidget(
                              btnText: 'Add First Cooperative Company',
                              type: 'primary',
                              onTap: () => _showAddCooperativeCompanyForm(context),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildCooperativeCompaniesTable(context, provider, constraints);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCooperativeCompaniesTable(BuildContext context, CooperativeCompanyDataProvider provider, BoxConstraints constraints) {
    final companies = provider.pagedCompanies;

    return Column(
      children: [
        // Summary widget
        CountSummaryWidgetEn(
          count: provider.companies.length,
          itemName: 'cooperative company',
          itemNamePlural: 'cooperative companies',
          icon: Icons.business,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        
        // Data table
        Container(
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
                    'Actions',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
            ],
            rows: companies.map((item) => DataRow(
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
                        item.image != null && item.image!.isNotEmpty
                            ? _buildCompanyImage(item.image!)
                            : _buildCompanyPlaceholder(item.name),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
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
                DataCell(_buildCountryCell(item)),
                DataCell(_buildPhoneCell(item)),
                DataCell(_buildActionsCell(context, item)),
              ],
            )).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Pagination
        _buildPagination(provider),
      ],
    );
  }

  // Build full image URL from server
  String _buildCompanyImageUrl(String imageFileName) {
    const baseUrl = 'https://noc.justhost.ly/backend-api/storage/app/public/';
    // Remove any leading slashes or spaces from imageFileName
    final cleanFileName = imageFileName.trim().replaceFirst(RegExp(r'^/'), '');
    return '$baseUrl$cleanFileName';
  }

  Widget _buildCompanyImage(String imageFileName) {
    final imageUrl = _buildCompanyImageUrl(imageFileName);
    
    print('🖼️ [Cooperative Company Image] Building image widget');
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
              print('✅ [Cooperative Company Image] Image loaded successfully: $imageUrl');
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
            print('❌ [Cooperative Company Image] Error loading image: $imageUrl');
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
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildCountryCell(CooperativeCompany company) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 200,
      ),
      child: GetBuilder<CityDataProvider>(
        builder: (cityProvider) {
          String countryName = _getCountryNameSync(company, cityProvider);
          return Text(
            countryName,
            style: const TextStyle(
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
    );
  }

  Widget _buildPhoneCell(CooperativeCompany company) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 150,
      ),
      child: Text(
        company.phone,
        style: const TextStyle(
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }


  Widget _buildActionsCell(BuildContext context, CooperativeCompany company) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View button
        IconButton(
          icon: const Icon(
            Icons.visibility,
            size: 18,
          ),
          onPressed: () {
            _showCompanyDetails(context, company);
          },
          tooltip: 'View Details',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade50,
            foregroundColor: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 10),
        
        // Edit button
        IconButton(
          icon: const Icon(
            Icons.edit,
            size: 18,
          ),
          onPressed: () {
            _showEditCooperativeCompanyForm(context, company);
          },
          tooltip: 'Edit Cooperative Company',
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(CooperativeCompanyDataProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Rows per page selector
        Row(
          children: [
            Text(
              'Rows per page:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: provider.rowsPerPage,
              items: [5, 10, 25, 50].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  provider.setRowsPerPage(newValue);
                }
              },
            ),
          ],
        ),
        
        // Pagination controls
        Row(
          children: [
            Text(
              'Page ${provider.currentPage + 1} of ${provider.totalPages}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: provider.currentPage > 0 ? provider.prevPage : null,
              tooltip: 'Previous page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: provider.currentPage < provider.totalPages - 1 ? provider.nextPage : null,
              tooltip: 'Next page',
            ),
          ],
        ),
      ],
    );
  }

  void _showAddCooperativeCompanyForm(BuildContext context) {
    print('');
    print('🚀 [CooperativeCompany] OPENING ADD FORM');
    print('═══════════════════════════════════════');
    print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔧 Operation: Opening Add Cooperative Company Form');
    print('👤 User Action: Add new cooperative company');
    print('═══════════════════════════════════════');
    print('');
    
    _logDebugInfo('Opening Add Cooperative Company Form');
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
      title: 'Add New Cooperative Company',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
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
                              
                              // Logo upload section (moved to first position)
                              Text(
                                'Company Logo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CompanyImagePicker(
                                onImageChanged: (String? base64Image) {
                                  setModalState(() {
                                    selectedImageBase64 = base64Image;
                                  });
                                },
                                onImageFileChanged: (PlatformFile? imageFile) {
                                  setModalState(() {
                                    selectedImageFile = imageFile;
                                  });
                                },
                                initialImage: selectedImageBase64,
                              ),
                              const SizedBox(height: 16),
                              
                              // Company Name field
                              OutBorderTextFormField(
                                labelText: 'Company Name *',
                                hintText: 'Enter company name',
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter company name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Address field
                              OutBorderTextFormField(
                                labelText: 'Address *',
                                hintText: 'Enter company address',
                                controller: addressController,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter company address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Country Dropdown
                              _buildCountryDropdown(
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  print('🌍 [CooperativeCompany] Country selection changed from $selectedCountryId to $value');
                                  selectedCountryId = value;
                                  selectedCityId = null; // Reset city when country changes
                                  print('🏙️ [CooperativeCompany] City selection reset to null due to country change');
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
                                  print('🏙️ [CooperativeCompany] City selection changed from $selectedCityId to $value');
                                  selectedCityId = value;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                              
                              // Phone field
                              OutBorderTextFormField(
                                labelText: 'Phone *',
                                hintText: 'Enter company phone',
                                controller: phoneController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter company phone';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // API URL field
                              OutBorderTextFormField(
                                labelText: 'API URL',
                                hintText: 'Enter API URL (optional)',
                                controller: apiUrlController,
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
                                'Creating Cooperative Company...',
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
                      const Text('Creating Cooperative Company...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = CooperativeCompanyCreateRequest(
              name: nameController.text.trim(),
              address: addressController.text.trim(),
              phone: phoneController.text.trim(),
              image: null, // Don't send base64 in request when using multipart
              apiUrl: apiUrlController.text.trim().isNotEmpty ? apiUrlController.text.trim() : null,
              countryId: selectedCountryId,
              cityId: selectedCityId,
            );
            
            // Print request body to terminal
            print('');
            print('═══════════════════════════════════════════════════════════');
            print('📤 [CooperativeCompany] CREATE REQUEST - OUTGOING DATA');
            print('═══════════════════════════════════════════════════════════');
            print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
            print('🔧 Operation: Create Cooperative Company');
            print('📋 Request Body:');
            final requestJson = request.toJson();
            requestJson.forEach((key, value) {
              if (key == 'image' && value != null) {
                print('   • $key: [Base64 Image Data - ${(value as String).length} characters]');
              } else {
                print('   • $key: $value');
              }
            });
            print('📊 Form Data Summary:');
            print('   • Company Name: "${nameController.text.trim()}"');
            print('   • Address: "${addressController.text.trim()}"');
            print('   • Phone: "${phoneController.text.trim()}"');
            print('   • API URL: "${apiUrlController.text.trim().isNotEmpty ? apiUrlController.text.trim() : 'Not provided'}"');
            print('   • Country ID: $selectedCountryId');
            print('   • City ID: $selectedCityId');
            print('   • Has Image: ${selectedImageFile != null}');
            print('   • Image File: ${selectedImageFile?.name ?? "None"} (${selectedImageFile?.size ?? 0} bytes)');
            print('═══════════════════════════════════════════════════════════');
            print('');
            
            print('🌐 [CooperativeCompany] Making API call to create cooperative company...');
            final response = await CooperativeCompanyService.createCooperativeCompany(
              request,
              imageFile: selectedImageFile, // Pass image file for multipart upload
            );
            
            // Print response from server
            print('');
            print('═══════════════════════════════════════════════════════════');
            print('📥 [CooperativeCompany] CREATE RESPONSE - INCOMING DATA');
            print('═══════════════════════════════════════════════════════════');
            print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
            print('🔧 Operation: Create Cooperative Company Response');
            print('✅ Success: ${response.success}');
            print('📨 Response Data:');
            if (response.data != null) {
              print('   • Company ID: ${response.data}');
            } else {
              print('   • No data returned');
            }
            print('📝 Messages:');
            print('   • Arabic: ${response.messageAr ?? 'No message'}');
            print('   • English: ${response.messageEn ?? 'No message'}');
            print('📊 Status Code: ${response.statusCode}');
            print('═══════════════════════════════════════════════════════════');
            print('');
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<CooperativeCompanyDataProvider>().refreshData();
              
              // Close modal
              Get.back();
              
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Cooperative company created successfully');
            } else {
              throw Exception(response.messageEn ?? 'Failed to create cooperative company');
            }
          } catch (e) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            print('❌ [CooperativeCompany] Error creating cooperative company: $e');
            print('📍 [CooperativeCompany] Stack trace: ${StackTrace.current}');
            print('📋 [CooperativeCompany] Request data: name=${nameController.text.trim()}, address=${addressController.text.trim()}, phone=${phoneController.text.trim()}, countryId=$selectedCountryId, cityId=$selectedCityId');
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  void _showEditCooperativeCompanyForm(BuildContext context, CooperativeCompany company) {
    print('');
    print('✏️ [CooperativeCompany] OPENING EDIT FORM');
    print('═══════════════════════════════════════');
    print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    print('🔧 Operation: Opening Edit Cooperative Company Form');
    print('👤 User Action: Edit existing cooperative company');
    print('🆔 Company ID: ${company.id}');
    print('🏢 Company Name: ${company.name}');
    print('📍 Current Address: ${company.address}');
    print('📞 Current Phone: ${company.phone}');
    print('🌍 Current Country ID: ${company.countryId}');
    print('🏙️ Current City ID: ${company.cityId}');
    print('🔗 Current API URL: ${company.apiUrl ?? 'Not set'}');
    print('🖼️ Has Image: ${company.image != null}');
    print('═══════════════════════════════════════');
    print('');
    
    _logDebugInfo('Opening Edit Cooperative Company Form', additionalData: {
      'companyId': company.id,
      'companyName': company.name,
      'existingCountryId': company.countryId,
      'existingCityId': company.cityId,
    });
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: company.name);
    final addressController = TextEditingController(text: company.address);
    final phoneController = TextEditingController(text: company.phone);
    final apiUrlController = TextEditingController(text: company.apiUrl ?? '');
    String? selectedImageBase64 = company.image; // Initialize with existing image (for display)
    PlatformFile? selectedImageFile; // Store new image file (for upload)
    int? selectedCountryId = company.countryId;
    int? selectedCityId = company.cityId;

    ModalDialog.show(
      context: context,
      title: 'Edit Cooperative Company',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
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
                              
                              // Logo upload section (moved to first position)
                              Text(
                                'Company Logo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CompanyImagePicker(
                                onImageChanged: (String? base64Image) {
                                  setModalState(() {
                                    selectedImageBase64 = base64Image;
                                  });
                                },
                                onImageFileChanged: (PlatformFile? imageFile) {
                                  setModalState(() {
                                    selectedImageFile = imageFile;
                                  });
                                },
                                initialImage: selectedImageBase64,
                              ),
                              const SizedBox(height: 16),
                              
                              // Company Name field
                              OutBorderTextFormField(
                                labelText: 'Company Name *',
                                hintText: 'Enter company name',
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter company name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Address field
                              OutBorderTextFormField(
                                labelText: 'Address *',
                                hintText: 'Enter company address',
                                controller: addressController,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter company address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Country Dropdown
                              _buildCountryDropdown(
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  print('🌍 [CooperativeCompany] Country selection changed from $selectedCountryId to $value');
                                  selectedCountryId = value;
                                  selectedCityId = null; // Reset city when country changes
                                  print('🏙️ [CooperativeCompany] City selection reset to null due to country change');
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
                                  print('🏙️ [CooperativeCompany] City selection changed from $selectedCityId to $value');
                                  selectedCityId = value;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                              
                              // Phone field
                              OutBorderTextFormField(
                                labelText: 'Phone *',
                                hintText: 'Enter company phone',
                                controller: phoneController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter company phone';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // API URL field
                              OutBorderTextFormField(
                                labelText: 'API URL',
                                hintText: 'Enter API URL (optional)',
                                controller: apiUrlController,
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
                                'Updating Cooperative Company...',
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
                      const Text('Updating Cooperative Company...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = CooperativeCompanyUpdateRequest(
              id: company.id!,
              name: nameController.text.trim(),
              address: addressController.text.trim(),
              phone: phoneController.text.trim(),
              image: null, // Don't send base64 in request when using multipart
              apiUrl: apiUrlController.text.trim().isNotEmpty ? apiUrlController.text.trim() : null,
              countryId: selectedCountryId,
              cityId: selectedCityId,
            );
            
            // Print request body to terminal
            print('');
            print('═══════════════════════════════════════════════════════════');
            print('📤 [CooperativeCompany] UPDATE REQUEST - OUTGOING DATA');
            print('═══════════════════════════════════════════════════════════');
            print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
            print('🔧 Operation: Update Cooperative Company');
            print('🆔 Company ID: ${company.id}');
            print('📋 Request Body:');
            final requestJson = request.toJson();
            requestJson.forEach((key, value) {
              if (key == 'image' && value != null) {
                print('   • $key: [Base64 Image Data - ${(value as String).length} characters]');
              } else {
                print('   • $key: $value');
              }
            });
            print('📊 Form Data Summary:');
            print('   • Original Name: "${company.name}" → New: "${nameController.text.trim()}"');
            print('   • Original Address: "${company.address}" → New: "${addressController.text.trim()}"');
            print('   • Original Phone: "${company.phone}" → New: "${phoneController.text.trim()}"');
            print('   • Original API URL: "${company.apiUrl ?? 'Not set'}" → New: "${apiUrlController.text.trim().isNotEmpty ? apiUrlController.text.trim() : 'Not provided'}"');
            print('   • Original Country ID: ${company.countryId} → New: $selectedCountryId');
            print('   • Original City ID: ${company.cityId} → New: $selectedCityId');
            print('   • Has New Image File: ${selectedImageFile != null}');
            print('   • Image File: ${selectedImageFile?.name ?? "None"} (${selectedImageFile?.size ?? 0} bytes)');
            print('📈 Changes Detected:');
            print('   • Name Changed: ${company.name != nameController.text.trim()}');
            print('   • Address Changed: ${company.address != addressController.text.trim()}');
            print('   • Phone Changed: ${company.phone != phoneController.text.trim()}');
            print('   • Country Changed: ${company.countryId != selectedCountryId}');
            print('   • City Changed: ${company.cityId != selectedCityId}');
            print('   • API URL Changed: ${company.apiUrl != (apiUrlController.text.trim().isNotEmpty ? apiUrlController.text.trim() : null)}');
            print('   • Image Updated: ${selectedImageFile != null}');
            print('═══════════════════════════════════════════════════════════');
            print('');
            
            print('🌐 [CooperativeCompany] Making API call to update cooperative company...');
            final response = await CooperativeCompanyService.updateCooperativeCompany(
              request,
              imageFile: selectedImageFile, // Pass image file for multipart upload
            );
            
            // Print response from server
            print('');
            print('═══════════════════════════════════════════════════════════');
            print('📥 [CooperativeCompany] UPDATE RESPONSE - INCOMING DATA');
            print('═══════════════════════════════════════════════════════════');
            print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
            print('🔧 Operation: Update Cooperative Company Response');
            print('🆔 Company ID: ${company.id}');
            print('✅ Success: ${response.success}');
            print('📨 Response Data:');
            if (response.data != null) {
              print('   • Company ID: ${response.data}');
            } else {
              print('   • No data returned');
            }
            print('📝 Messages:');
            print('   • Arabic: ${response.messageAr ?? 'No message'}');
            print('   • English: ${response.messageEn ?? 'No message'}');
            print('📊 Status Code: ${response.statusCode}');
            print('═══════════════════════════════════════════════════════════');
            print('');
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<CooperativeCompanyDataProvider>().refreshData();
              
              // Close modal
              Get.back();
              
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Cooperative company updated successfully');
            } else {
              throw Exception(response.messageEn ?? 'Failed to update cooperative company');
            }
          } catch (e) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            print('❌ [CooperativeCompany] Error updating cooperative company: $e');
            print('📍 [CooperativeCompany] Stack trace: ${StackTrace.current}');
            print('📋 [CooperativeCompany] Update data: id=${company.id}, name=${nameController.text.trim()}, address=${addressController.text.trim()}, phone=${phoneController.text.trim()}, countryId=$selectedCountryId, cityId=$selectedCityId');
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  void _showCompanyDetails(BuildContext context, CooperativeCompany company) {
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
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
                                        width: 30,
                                        height: 30,
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
                                    return Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade300,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
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

  String _formatCompanyDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  /// Helper method to get country name for a cooperative company synchronously
  String _getCountryNameSync(CooperativeCompany company, CityDataProvider cityProvider) {
    print('🔍 [CooperativeCompany] Getting country name for company ID: ${company.id}');
    print('📋 [CooperativeCompany] Company country data: countryId=${company.countryId}, countryName=${company.countryName}');
    print('📊 [CooperativeCompany] Available countries in provider: ${cityProvider.countries.length}');
    
    // First check if country name is already available from API response
    if (company.countryName != null && company.countryName!.isNotEmpty) {
      print('✅ [CooperativeCompany] Using country name from API: ${company.countryName}');
      return company.countryName!;
    }
    
    // If no country name but we have country ID, try to get it from the provider
    if (company.countryId != null && cityProvider.countries.isNotEmpty) {
      final country = cityProvider.countries.firstWhereOrNull(
        (c) => c.id == company.countryId,
      );
      if (country != null) {
        print('✅ [CooperativeCompany] Found country in provider: ${country.name}');
        return country.name;
      } else {
        print('⚠️ [CooperativeCompany] Country ID ${company.countryId} not found in provider');
      }
    }
    
    print('❌ [CooperativeCompany] No country data available, returning default');
    return 'No country';
  }

  /// Helper method to get city name for a cooperative company synchronously
  String _getCityNameSync(CooperativeCompany company, CityDataProvider cityProvider) {
    print('🔍 [CooperativeCompany] Getting city name for company ID: ${company.id}');
    print('📋 [CooperativeCompany] Company city data: cityId=${company.cityId}, cityName=${company.cityName}');
    print('📊 [CooperativeCompany] Available cities in provider: ${cityProvider.cities.length}');
    
    // First check if city name is already available from API response
    if (company.cityName != null && company.cityName!.isNotEmpty) {
      print('✅ [CooperativeCompany] Using city name from API: ${company.cityName}');
      return company.cityName!;
    }
    
    // If no city name but we have city ID, try to get it from the provider
    if (company.cityId != null && cityProvider.cities.isNotEmpty) {
      final city = cityProvider.cities.firstWhereOrNull(
        (c) => c.id == company.cityId,
      );
      if (city != null) {
        print('✅ [CooperativeCompany] Found city in provider: ${city.name}');
        return city.name;
      } else {
        print('⚠️ [CooperativeCompany] City ID ${company.cityId} not found in provider');
      }
    }
    
    print('❌ [CooperativeCompany] No city data available, returning default');
    return 'No city';
  }

  /// Logs comprehensive debugging information
  void _logDebugInfo(String operation, {Map<String, dynamic>? additionalData}) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔍 [CooperativeCompany] DEBUG INFO - $operation');
    print('═══════════════════════════════════════════════════════════');
    print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    
    // Log CityDataProvider state
    final cityProvider = Get.find<CityDataProvider>();
    print('📊 CityDataProvider State:');
    print('   - Countries loaded: ${cityProvider.countries.length}');
    print('   - Cities loaded: ${cityProvider.cities.length}');
    print('   - Loading countries: ${cityProvider.isLoadingCountries}');
    print('   - Loading cities: ${cityProvider.isLoading}');
    
    // Log CooperativeCompanyDataProvider state
    final companyProvider = Get.find<CooperativeCompanyDataProvider>();
    print('📊 CooperativeCompanyDataProvider State:');
    print('   - Companies loaded: ${companyProvider.companies.length}');
    print('   - Is loading: ${companyProvider.isLoading}');
    print('   - Current page: ${companyProvider.currentPage}');
    print('   - Rows per page: ${companyProvider.rowsPerPage}');
    
    // Log additional data if provided
    if (additionalData != null && additionalData.isNotEmpty) {
      print('📋 Additional Data:');
      additionalData.forEach((key, value) {
        print('   - $key: $value');
      });
    }
    
    print('═══════════════════════════════════════════════════════════');
    print('');
  }

  /// Builds country dropdown widget with data loading
  Widget _buildCountryDropdown({
    required int? selectedCountryId,
    required Function(int?) onChanged,
    required bool enabled,
    required StateSetter setModalState,
  }) {
    print('🏗️ [CooperativeCompany] Building country dropdown with selectedCountryId: $selectedCountryId');
    return GetBuilder<CityDataProvider>(
      builder: (cityProvider) {
        print('📊 [CooperativeCompany] Country dropdown state: countries=${cityProvider.countries.length}, isLoadingCountries=${cityProvider.isLoadingCountries}');
        
        // Ensure data is loaded
        if (cityProvider.countries.isEmpty && !cityProvider.isLoadingCountries) {
          print('🔄 [CooperativeCompany] Triggering country data loading...');
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
    print('🏗️ [CooperativeCompany] Building city dropdown with selectedCityId: $selectedCityId, selectedCountryId: $selectedCountryId');
    return GetBuilder<CityDataProvider>(
      builder: (cityProvider) {
        print('📊 [CooperativeCompany] City dropdown state: cities=${cityProvider.cities.length}, isLoading=${cityProvider.isLoading}');
        
        // Ensure cities are loaded
        if (cityProvider.cities.isEmpty && !cityProvider.isLoading) {
          print('🔄 [CooperativeCompany] Triggering city data loading...');
          // Trigger loading if not already started
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cityProvider.refreshData();
          });
        }
        
        final filteredCities = cityProvider.cities
            .where((city) => city.countryId == selectedCountryId)
            .toList();
        print('🔍 [CooperativeCompany] Filtered cities for country $selectedCountryId: ${filteredCities.length}');
        
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
}

class CooperativeCompanyDataProvider extends GetxController {
  final _companies = <CooperativeCompany>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;

  List<CooperativeCompany> get companies => _companies;
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
  List<CooperativeCompany> get pagedCompanies {
    if (totalItems == 0) return const <CooperativeCompany>[];
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

  Future<List<CooperativeCompany>> loadData() async {
    print('🔄 [CooperativeCompanyDataProvider] Starting to load cooperative companies data...');
    try {
      _isLoading.value = true;
      print('📡 [CooperativeCompanyDataProvider] Making API call to getAllCooperativeCompanies...');
      final response = await CooperativeCompanyService.getAllCooperativeCompanies();
      
      if (response.success) {
        print('✅ [CooperativeCompanyDataProvider] API call successful, loaded ${response.data.length} companies');
        _companies.value = response.data;
        _currentPage.value = 0; // reset page on new data
        
        // Log sample data for debugging
        if (response.data.isNotEmpty) {
          final firstCompany = response.data.first;
          print('📋 [CooperativeCompanyDataProvider] Sample company data: id=${firstCompany.id}, name=${firstCompany.name}, countryId=${firstCompany.countryId}, cityId=${firstCompany.cityId}');
        }
        
        return response.data;
      } else {
        print('❌ [CooperativeCompanyDataProvider] API call failed: ${response.messageEn}');
        throw Exception(response.messageEn);
      }
    } catch (e) {
      print('❌ [CooperativeCompanyDataProvider] Error loading cooperative companies data: $e');
      print('📍 [CooperativeCompanyDataProvider] Stack trace: ${StackTrace.current}');
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
    } catch (e) {
      print('❌ [CooperativeCompanyDataProvider] Error refreshing cooperative companies data: $e');
      print('📍 [CooperativeCompanyDataProvider] Stack trace: ${StackTrace.current}');
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
