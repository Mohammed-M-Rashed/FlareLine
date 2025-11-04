import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/city_model.dart';
import 'package:flareline/core/models/country_model.dart';
import 'package:flareline/core/services/city_service.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:flareline/core/utils/country_code_helper.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'package:flareline/core/i18n/strings_ar.dart';

class CityManagementPage extends LayoutWidget {
  const CityManagementPage({super.key});

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        CityManagementWidget(),
      ],
    );
  }
}

class CityManagementWidget extends StatefulWidget {
  const CityManagementWidget({super.key});

  @override
  State<CityManagementWidget> createState() => _CityManagementWidgetState();
}

class _CityManagementWidgetState extends State<CityManagementWidget> {
  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<CityDataProvider>(
          init: CityDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, CityDataProvider provider) {
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
                            StringsAr.cityManagement,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage cities and their countries',
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
                            btnText: provider.isLoading ? StringsAr.loading : StringsAr.refresh,
                            type: 'secondary',
                            onTap: provider.isLoading ? null : () async {
                              try {
                                await provider.refreshData();
                                _showSuccessToast('Cities data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('Error refreshing cities data: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (CityService.hasCityManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: StringsAr.addCity,
                                  type: 'primary',
                                  onTap: () {
                                    _showAddCityForm(context, provider);
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
                  if (!CityService.hasCityManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage cities. Only Admin users can access this functionality.',
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

                    final cities = provider.filteredCities;

                    return Column(
                      children: [
                        // Search Section
                        _buildSearchSection(context, provider),
                        const SizedBox(height: 16),
                        
                        // Country Filter Section
                        _buildCountryFilter(context, provider),
                        const SizedBox(height: 24),
                        
                        if (cities.isEmpty) ...[
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_city_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  provider.searchQuery.isNotEmpty
                                      ? 'No cities found matching "${provider.searchQuery}"'
                                      : provider.selectedCountryId != null 
                                          ? 'No cities found for selected country'
                                          : 'No cities found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.searchQuery.isNotEmpty
                                      ? 'Try adjusting your search terms'
                                      : 'Get started by adding your first city',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ButtonWidget(
                                  btnText: StringsAr.addCity,
                                  type: 'primary',
                                  onTap: () {
                                    _showAddCityForm(context, provider);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Summary Card
                          CountSummaryWidgetEn(
                            itemName: (provider.selectedCountryId != null || provider.searchQuery.isNotEmpty)
                                ? 'Filtered City'
                                : StringsAr.city,
                            itemNamePlural: (provider.selectedCountryId != null || provider.searchQuery.isNotEmpty)
                                ? 'Filtered Cities'
                                : 'Cities',
                            count: cities.length,
                            icon: Icons.location_city_outlined,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 24),
                          
                          // Cities Table
                          _buildCitiesTable(context, provider, cities),
                        ],
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

  Widget _buildSearchSection(BuildContext context, CityDataProvider provider) {
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
              labelText: 'Search Cities by Country',
              hintText: 'Search by country name...',
              icon: const Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFilter(BuildContext context, CityDataProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.grey),
          const SizedBox(width: 12),
          const Text(
            'Filter by Country:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() {
              if (provider.isLoadingCountries) {
                return const Text('جاري تحميل الدول...');
              }
              
              return DropdownButtonFormField<int?>(
                value: provider.selectedCountryId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                hint: const Text('All Countries'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Countries'),
                  ),
                  ...provider.countries.map((country) => DropdownMenuItem<int?>(
                    value: country.id,
                    child: Text(country.name),
                  )),
                ],
                onChanged: (value) {
                  provider.setSelectedCountry(value);
                },
              );
            }),
          ),
          const SizedBox(width: 16),
          if (provider.selectedCountryId != null)
            IconButton(
              onPressed: () {
                provider.setSelectedCountry(null);
              },
              icon: const Icon(Icons.clear, color: Colors.grey),
              tooltip: 'Clear Filter',
            ),
        ],
      ),
    );
  }

  Widget _buildCitiesTable(BuildContext context, CityDataProvider provider, List<City> cities) {
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
                child: isMobile ? _buildMobileCityHeader() : _buildDesktopCityHeader(),
              ),
              // Table Body
              ...cities.asMap().entries.map((entry) {
                final index = entry.key;
                final city = entry.value;
                return _buildCityRow(context, provider, city, index, isMobile, isTablet);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileCityHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            StringsAr.city,
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

  Widget _buildDesktopCityHeader() {
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
          flex: 3,
          child: Text(
            StringsAr.cityName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Actions',
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

  Widget _buildCityRow(BuildContext context, CityDataProvider provider, City city, int index, bool isMobile, bool isTablet) {
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
      child: isMobile ? _buildMobileCityRow(context, provider, city) : _buildDesktopCityRow(context, provider, city),
    );
  }

  Widget _buildMobileCityRow(BuildContext context, CityDataProvider provider, City city) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                provider.getCountryNameForCity(city),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'ID: ${city.id ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildCountryFlag(city),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () {
                _showEditCityForm(context, provider, city);
              },
              tooltip: StringsAr.editCity,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopCityRow(BuildContext context, CityDataProvider provider, City city) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            city.id?.toString() ?? 'N/A',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildCountryFlag(city),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              provider.getCountryNameForCity(city),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            city.name,
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
                  _showEditCityForm(context, provider, city);
                },
                tooltip: StringsAr.editCity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountryFlag(City city) {
    // Get emoji flag from country name using helper
    String? flagEmoji = CountryCodeHelper.getCountryFlag(city.country?.name ?? '');
    
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

  void _showAddCityForm(BuildContext context, CityDataProvider provider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    int? selectedCountryId;
    bool isSubmitting = false;

    ModalDialog.show(
      context: context,
      title: StringsAr.addCity,
      showTitle: true,
      modalType: ModalType.medium,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Country',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedCountryId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select a country',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: provider.countries.map((country) => DropdownMenuItem<int>(
                          value: country.id,
                          child: Text(country.name),
                        )).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCountryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a country';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      OutBorderTextFormField(
                        labelText: StringsAr.cityName,
                        hintText: 'Enter city name',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter city name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
                    btnText: isSubmitting ? StringsAr.creating : StringsAr.save,
                    type: 'primary',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        setFooterState(() {
                          isSubmitting = true;
                        });

                        try {
                          final request = CityCreateRequest(
                            name: nameController.text.trim(),
                            countryId: selectedCountryId!,
                          );

                          await provider.createCity(request);
                          Navigator.of(context).pop();
                          _showSuccessToast('City created successfully');
                        } catch (e) {
                          _showErrorToast('Error creating city: ${e.toString()}');
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

  void _showEditCityForm(BuildContext context, CityDataProvider provider, City city) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: city.name);
    int? selectedCountryId = city.countryId;
    bool isSubmitting = false;

    ModalDialog.show(
      context: context,
      title: StringsAr.editCity,
      showTitle: true,
      modalType: ModalType.medium,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Country',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedCountryId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select a country',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: provider.countries.map((country) => DropdownMenuItem<int>(
                          value: country.id,
                          child: Text(country.name),
                        )).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCountryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a country';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      OutBorderTextFormField(
                        labelText: StringsAr.cityName,
                        hintText: 'Enter city name',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter city name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
                    btnText: isSubmitting ? StringsAr.updating : StringsAr.save,
                    type: 'primary',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        setFooterState(() {
                          isSubmitting = true;
                        });

                        try {
                          final request = CityUpdateRequest(
                            name: nameController.text.trim(),
                            countryId: selectedCountryId!,
                          );

                          await provider.updateCity(city.id!, request);
                          Navigator.of(context).pop();
                          _showSuccessToast('City updated successfully');
                        } catch (e) {
                          _showErrorToast('Error updating city: ${e.toString()}');
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
