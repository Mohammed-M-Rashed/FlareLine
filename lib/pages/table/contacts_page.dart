
import 'package:flareline_uikit/components/tables/base_table_widget.dart';
import 'package:flareline_uikit/core/mvvm/base_table_provider.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flutter/material.dart';

class ContactsPage extends LayoutWidget {
  ContactsPage({super.key});

  @override
  bool get isContentScroll => false;

  @override
  String breakTabTitle(BuildContext context) {
    return 'Contacts';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return DataTableWidget();
  }
}

class DataTableWidget extends TableWidget<ContactsViewModel> {
  const DataTableWidget({super.key});

  @override
  ContactsViewModel viewModelBuilder(BuildContext context) {
    return ContactsViewModel(context);
  }
}

class ContactsViewModel extends BaseTableProvider {
  @override
  String get TAG => 'ContactsViewModel';

  ContactsViewModel(BuildContext context) : super(context);

  @override
  Future<void> loadData(BuildContext context) async {
    const headers = [
      "Contact Name",
      "Last Contacted",
      "Company",
      "Contact",
      "Lead Score"
    ];

    List rows = [];

    for (int i = 0; i < 50; i++) {
      List<List<Map<String, dynamic>>> list = [];

      List<Map<String, dynamic>> row = [];
      var id = i;
      var item = {
        'contactName': 'Tom${id}',
        'lastContacted': '1 Feb, 2020',
        'company': 'Starbucks',
        'contact': 'nathan.roberts@example.com',
        'phone': '(201) 555-0124',
        'leadScore': 'Online store',
      };
      row.add(getItemValue('contactName', item));
      row.add(getItemValue('lastContacted', item));
      row.add(getItemValue('company', item));
      row.add(getItemValue('contact', item));
      row.add(getItemValue('leadScore', item, dataType: CellDataType.TAG.type));
      list.add(row);

      rows.addAll(list);
    }

    Map<String, dynamic> map = {'headers': headers, 'rows': rows};
    // For now, just store the data directly since TableDataEntity is not available
    tableDataEntity = map;
  }
}
