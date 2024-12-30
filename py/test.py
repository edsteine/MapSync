import os

def create_test_structure():
    structure = {
        'test': {
            'core': {
                'services': [
                    'network_service_unit_test.dart',
                    'storage_service_unit_test.dart',
                    'tile_service_unit_test.dart',
                    'map_service_unit_test.dart',
                    'cache_service_unit_test.dart',
                    'permission_service_unit_test.dart',
                    'notification_service_unit_test.dart'
                ],
                'utils': [
                    'app_utils_unit_test.dart',
                    'map_utils_unit_test.dart',
                    'error_manager_unit_test.dart'
                ],
                'performance': [
                    'app_resource_optimizer_unit_test.dart',
                    'performance_monitor_unit_test.dart'
                ]
            },
            'features': {
                'map': [
                    'map_repository_unit_test.dart',
                    'map_viewmodel_unit_test.dart',
                    'map_screen_widget_test.dart'
                ],
                'settings': {
                    '': [
                        'settings_repository_unit_test.dart',
                        'settings_viewmodel_unit_test.dart',
                        'settings_screen_widget_test.dart'
                    ],
                    'widgets': [
                        'region_item_widget_test.dart',
                        'theme_picker_widget_test.dart'
                    ]
                },
                'offline_map': [
                    'offline_map_repository_unit_test.dart',
                    'offline_map_viewmodel_unit_test.dart',
                    'offline_map_screen_widget_test.dart'
                ]
            },
            'shared': {
                'widgets': [
                    'custom_error_widget_test.dart',
                    'loading_overlay_widget_test.dart',
                    'theme_picker_widget_test.dart',
                    'map_controls_unit_test.dart',
                    'map_widget_unit_test.dart',
                    'offline_banner_unit_test.dart'
                ]
            },
            'integration': [
                'map_integration_test.dart',
                'core_integration_test.dart'
            ],
            'e2e': [
                'app_e2e_test.dart'
            ],
            'performance': [
                'memory_leak_performance_test.dart',
                'frame_rate_performance_test.dart',
                'load_time_performance_test.dart'
            ]
        }
    }

    def create_structure(base_path, structure):
        if isinstance(structure, dict):
            for key, value in structure.items():
                path = os.path.join(base_path, key) if key else base_path
                if not os.path.exists(path):
                    os.makedirs(path)
                create_structure(path, value)
        elif isinstance(structure, list):
            for item in structure:
                file_path = os.path.join(base_path, item)
                test_name = os.path.splitext(item)[0]
                template = f"""import 'package:flutter_test/flutter_test.dart';

void main() {{
  group('{test_name}', () {{
    test('initial test', () {{
      // TODO: Implement test
    }});
  }});
}}"""
                with open(file_path, 'w') as f:
                    f.write(template)

    # Create the directory structure
    create_structure('.', structure)
    print("Test directory structure created successfully!")

if __name__ == '__main__':
    create_test_structure()