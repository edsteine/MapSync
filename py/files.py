import os

def create_project_structure():
    # Define the project structure
    structure = {
        'lib': {
            'core': {
                'performance': [
                    'app_size_reducer.dart',
                    'map_tile_manager.dart',
                    'performance_monitor.dart'
                ],
                'map': [
                    'offline_map_manager.dart'
                ],
                '__files__': [
                    'app_config.dart',
                    'network.dart',
                    'storage.dart'
                ]
            },
            'features': {
                'map': {
                    'models': [
                        'map_marker.dart'
                    ],
                    'repositories': [
                        'map_repository.dart'
                    ],
                    'viewmodels': [
                        'map_viewmodel.dart'
                    ],
                    'views': {
                        'widgets': [
                            'map_controls.dart',
                            'offline_banner.dart'
                        ],
                        '__files__': [
                            'map_screen.dart'
                        ]
                    }
                }
            },
            'shared': {
                'widgets': [
                    'loading_overlay.dart',
                    'error_widget.dart'
                ],
                'utils': [
                    'constants.dart',
                    'helpers.dart'
                ]
            },
            '__files__': [
                'main.dart'
            ]
        },
        'test': {
            'unit': {
                'core': [
                    'network_test.dart',
                    'storage_test.dart'
                ],
                'features': {
                    'map': [
                        'map_repository_test.dart',
                        'map_viewmodel_test.dart'
                    ]
                }
            },
            'widget': {
                'features': {
                    'map': {
                        'widgets': [
                            'map_controls_test.dart',
                            'offline_banner_test.dart'
                        ],
                        '__files__': [
                            'map_screen_test.dart'
                        ]
                    }
                }
            },
            'integration': [
                'app_test.dart'
            ]
        }
    }

    def create_structure(base_path, structure):
        for key, value in structure.items():
            if key == '__files__':
                # Create files directly in the current directory
                for file_name in value:
                    file_path = os.path.join(base_path, file_name)
                    with open(file_path, 'w') as f:
                        pass  # Create empty file
            else:
                # Create directory
                new_path = os.path.join(base_path, key)
                os.makedirs(new_path, exist_ok=True)
                
                if isinstance(value, dict):
                    create_structure(new_path, value)
                elif isinstance(value, list):
                    # Create files in the directory
                    for file_name in value:
                        file_path = os.path.join(new_path, file_name)
                        with open(file_path, 'w') as f:
                            pass  # Create empty file

    # Create the project root directory
    project_root = 'flutter_map_project'
    os.makedirs(project_root, exist_ok=True)

    # Create the structure
    create_structure(project_root, structure)
    print(f"Project structure created in '{project_root}' directory")

if __name__ == '__main__':
    create_project_structure()