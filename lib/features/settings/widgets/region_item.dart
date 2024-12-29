// lib/features/settings/widgets/region_item.dart
import 'package:flutter/material.dart';

class RegionItem extends StatelessWidget {
  const RegionItem({
    required this.region,
    required this.deleteRegion,
    super.key,
  });
  final String region;
  final Function(String) deleteRegion;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(region),
        trailing: IconButton(
          onPressed: () {
            deleteRegion(region);
          },
          icon: const Icon(Icons.delete),
        ),
      );
}
