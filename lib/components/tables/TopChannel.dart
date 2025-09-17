import 'dart:convert';

import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:flareline_uikit/components/tables/base_table_widget.dart';
import 'package:flareline_uikit/core/mvvm/base_table_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TopChannelWidget extends StatelessWidget {
  const TopChannelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Register the view model with GetX if not already registered
    if (!Get.isRegistered<TopChannelViewModel>()) {
      Get.put<TopChannelViewModel>(TopChannelViewModel(context), permanent: false);
    }
    
    return _TopChannelTableWidget();
  }
}

class _TopChannelTableWidget extends TableWidget<TopChannelViewModel> {
  const _TopChannelTableWidget({super.key});

  @override
  bool get showPaging => false;

  @override
  String? title(BuildContext context) {
    return AppLocalizations.of(context)!.topChannels;
  }
}

class TopChannelViewModel extends BaseTableProvider {
  TopChannelViewModel(BuildContext context) : super(context);

  @override
  Future<void> loadData(BuildContext context) async {
    // String res = await rootBundle.loadString('assets/api/channelTable.json');

    Map<String, dynamic> map = {
      "headers": ["SOURCE", "VISITORS", "REVENUES", "SALES", "CONVERSATION"],
      "rows": [
        [
          {"text": "Google"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "590"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Google"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "590"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Google"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "590"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Google"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "590"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ],
        [
          {"text": "Google"},
          {"text": "3.5K"},
          {"text": r"$5,768", "dataType": "tag", "tagType": "success"},
          {"text": "590"},
          {"text": "4.8%", "dataType": "tag", "tagType": "secondary"}
        ]
      ]
    };
    // For now, just store the data directly since TableDataEntity is not available
    tableDataEntity = map;
  }
}
