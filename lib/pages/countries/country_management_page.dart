import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/country_model.dart';
import 'package:flareline/core/services/country_service.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:flareline/core/utils/country_code_helper.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';

class CountryManagementPage extends LayoutWidget {
  const CountryManagementPage({super.key});

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        CountryManagementWidget(),
      ],
    );
  }
}

class CountryManagementWidget extends StatefulWidget {
  const CountryManagementWidget({super.key});

  @override
  State<CountryManagementWidget> createState() => _CountryManagementWidgetState();
}

class _CountryManagementWidgetState extends State<CountryManagementWidget> {
  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<CountryDataProvider>(
          init: CountryDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, CountryDataProvider provider) {
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
                            'Country Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage countries in the system',
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
                                _showSuccessToast('Countries data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('Error refreshing countries data: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (CountryService.hasCountryManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'Add Country',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddCountryForm(context, provider);
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
                  if (!CountryService.hasCountryManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage countries. Only Admin users can access this functionality.',
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

                    final countries = provider.countries;
                    final filteredCountries = provider.filteredCountries;

                    if (countries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.public_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No countries found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding your first country',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ButtonWidget(
                              btnText: 'Add First Country',
                              type: 'primary',
                              onTap: () {
                                _showAddCountryForm(context, provider);
                              },
                            ),
                          ],
                        ),
                      );
                    }


                    return Column(
                      children: [
                        // Summary Cards
                        CountSummaryWidgetEn(
                          itemName: 'Country',
                          itemNamePlural: 'Countries',
                          count: filteredCountries.length,
                          icon: Icons.public_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 24),
                        
                        // Search and filter section
                        _buildSearchSection(context, provider),
                        const SizedBox(height: 16),
                        
                        // Countries Table
                        _buildCountriesTable(context, provider, provider.filteredCountries),
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

  Widget _buildSearchSection(BuildContext context, CountryDataProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutBorderTextFormField(
              controller: provider.searchController,
              labelText: 'Search Countries',
              hintText: 'Search by country name...',
              icon: const Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesTable(BuildContext context, CountryDataProvider provider, List<Country> countries) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth < 1024;
        
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Header
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
              ),
              // Table Body
              if (countries.isEmpty)
                _buildEmptyState(provider)
              else
                ...countries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final country = entry.value;
                  return _buildCountryRow(context, provider, country, index, isMobile, isTablet);
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Country',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Flag',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'ID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Flag',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            'Country Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(CountryDataProvider provider) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isNotEmpty 
                ? 'No countries found matching "${provider.searchQuery}"'
                : 'No countries found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (provider.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search terms',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountryRow(BuildContext context, CountryDataProvider provider, Country country, int index, bool isMobile, bool isTablet) {
    final isEven = index % 2 == 0;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: isMobile ? _buildMobileCountryRow(context, provider, country) : _buildDesktopCountryRow(context, provider, country),
    );
  }

  Widget _buildMobileCountryRow(BuildContext context, CountryDataProvider provider, Country country) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                country.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'ID: ${country.id ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildCountryFlag(country),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () {
                _showEditCountryForm(context, provider, country);
              },
              tooltip: 'Edit Country',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopCountryRow(BuildContext context, CountryDataProvider provider, Country country) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            country.id?.toString() ?? 'N/A',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildCountryFlag(country),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            country.name,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                onPressed: () {
                  _showEditCountryForm(context, provider, country);
                },
                tooltip: 'Edit Country',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountryFlag(Country country) {
    // Get emoji flag from country name using helper
    String? flagEmoji = CountryCodeHelper.getCountryFlag(country.name);
    
    if (flagEmoji != null && flagEmoji.isNotEmpty) {
      return Container(
        height: 24,
        width: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            flagEmoji,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    } else {
      // No flag available, show placeholder
      return Container(
        height: 24,
        width: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Icon(
          Icons.flag,
          size: 16,
          color: Colors.grey,
        ),
      );
    }
  }

  void _showAddCountryForm(BuildContext context, CountryDataProvider provider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    bool isSubmitting = false;

    ModalDialog.show(
      context: context,
      title: 'Add New Country',
      showTitle: true,
      modalType: ModalType.medium,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutBorderTextFormField(
                labelText: 'Country Name',
                hintText: 'Enter country name',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter country name';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      footer: StatefulBuilder(
        builder: (BuildContext context, StateSetter setFooterState) {
          return Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: ButtonWidget(
                    btnText: isSubmitting ? 'Creating...' : 'Save',
                    type: 'primary',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        setFooterState(() {
                          isSubmitting = true;
                        });

                        try {
                          final request = CountryCreateRequest(
                            name: nameController.text.trim(),
                          );

                          await provider.createCountry(request);
                          Navigator.of(context).pop();
                          _showSuccessToast('Country created successfully');
                        } catch (e) {
                          _showErrorToast('Error creating country: ${e.toString()}');
                        } finally {
                          setFooterState(() {
                            isSubmitting = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditCountryForm(BuildContext context, CountryDataProvider provider, Country country) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: country.name);
    bool isSubmitting = false;

    ModalDialog.show(
      context: context,
      title: 'Edit Country',
      showTitle: true,
      modalType: ModalType.medium,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutBorderTextFormField(
                labelText: 'Country Name',
                hintText: 'Enter country name',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter country name';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      footer: StatefulBuilder(
        builder: (BuildContext context, StateSetter setFooterState) {
          return Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: ButtonWidget(
                    btnText: isSubmitting ? 'Updating...' : 'Save',
                    type: 'primary',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        setFooterState(() {
                          isSubmitting = true;
                        });

                        try {
                          final request = CountryUpdateRequest(
                            name: nameController.text.trim(),
                          );

                          await provider.updateCountry(country.id!, request);
                          Navigator.of(context).pop();
                          _showSuccessToast('Country updated successfully');
                        } catch (e) {
                          _showErrorToast('Error updating country: ${e.toString()}');
                        } finally {
                          setFooterState(() {
                            isSubmitting = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showSuccessToast(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}