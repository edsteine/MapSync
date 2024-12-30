import os
import shutil
import subprocess
from datetime import datetime

# Configuration
FLUTTER_PROJECT_PATH = "path/to/your/flutter/project"
DJANGO_MEDIA_PATH = "path/to/your/django/project/media/apks"
VERSION = "1.0.0"  # Update this with your app version

def create_directory_structure():
    version_dir = os.path.join(DJANGO_MEDIA_PATH, f"version_{VERSION}")
    
    # Create directories for each architecture
    architectures = ['arm64-v8a', 'armeabi-v7a', 'x86_64', 'universal']
    for arch in architectures:
        os.makedirs(os.path.join(version_dir, arch), exist_ok=True)
    
    return version_dir

def build_apks():
    # Change to Flutter project directory
    os.chdir(FLUTTER_PROJECT_PATH)
    
    # Build split APKs
    subprocess.run(['flutter', 'build', 'apk', '--split-per-abi', '--release'])
    
    # Build universal APK
    subprocess.run(['flutter', 'build', 'apk', '--release'])

def move_apks(version_dir):
    flutter_build_dir = os.path.join(FLUTTER_PROJECT_PATH, 'build/app/outputs/flutter-apk')
    
    # Map of Flutter output files to destination directories
    apk_mapping = {
        'app-arm64-v8a-release.apk': 'arm64-v8a',
        'app-armeabi-v7a-release.apk': 'armeabi-v7a',
        'app-x86_64-release.apk': 'x86_64',
        'app-release.apk': 'universal'
    }
    
    # Move each APK to its respective directory
    for apk_file, arch_dir in apk_mapping.items():
        source = os.path.join(flutter_build_dir, apk_file)
        if os.path.exists(source):
            destination = os.path.join(version_dir, arch_dir, apk_file)
            shutil.copy2(source, destination)
            print(f"Moved {apk_file} to {destination}")

def get_apk_sizes(version_dir):
    sizes = {}
    for root, dirs, files in os.walk(version_dir):
        for file in files:
            if file.endswith('.apk'):
                file_path = os.path.join(root, file)
                size_mb = os.path.getsize(file_path) / (1024 * 1024)  # Convert to MB
                sizes[file] = round(size_mb, 2)
    return sizes

def main():
    print("Starting APK generation process...")
    
    # Create directory structure
    version_dir = create_directory_structure()
    print("Created directory structure")
    
    # Build APKs
    build_apks()
    print("Built APKs")
    
    # Move APKs to appropriate directories
    move_apks(version_dir)
    print("Moved APKs to destination directories")
    
    # Get and display APK sizes
    sizes = get_apk_sizes(version_dir)
    print("\nAPK Sizes:")
    for apk, size in sizes.items():
        print(f"{apk}: {size} MB")
    
    print("\nProcess completed!")

if __name__ == "__main__":
    main()