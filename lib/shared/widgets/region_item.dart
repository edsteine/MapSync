///
/// File: lib/shared/widgets/region_item.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays a single item representing a downloaded map region, including an option to delete it.
/// Updates: Initial setup for listing tile regions with delete capabilities.
/// Used Libraries: flutter/material.dart, mapbox_maps_flutter/mapbox_maps_flutter.dart
///
library;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// RegionItem widget displays a single downloaded region with a delete button.
class RegionItem extends StatelessWidget {
    /// Constructor for the region item takes `region` and `deleteRegion` callback.
  const RegionItem({
    required this.region,
    required this.deleteRegion,
    super.key,
  });
  /// Tile region for showing details
  final TileRegion region;
   /// Callback for deleting the current region.
  final Function(String) deleteRegion;

  @override
  Widget build(BuildContext context) => ListTile(
        // Region id as the title
        title: Text(region.id),
        // Button to trigger the delete functionality
        trailing: IconButton(
          onPressed: () {
            deleteRegion(region.id);
          },
          icon: const Icon(Icons.delete),
        ),
      );
}