// lib/features/offline_map/widgets/region_item.dart
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RegionItem extends StatelessWidget {
  const RegionItem({
    required this.region,
    required this.deleteRegion,
    super.key,
  });
  final TileRegion region;
  final Function(String) deleteRegion;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(region.id),
        trailing: IconButton(
          onPressed: () {
            deleteRegion(region.id);
          },
          icon: const Icon(Icons.delete),
        ),
      );
}
