import os

def write_directory_contents(directory, output_file, ignore_extensions=None, ignore_items=None):
    if ignore_extensions is None:
        ignore_extensions = ['.pyc', '.DS_Store', '.dll','log','txt']
    if ignore_items is None:
        ignore_items = ['.vscode','__pycache__']

    file_count = 0
    ignored_extensions = set()
    added_extensions = set()
    ignored_items = []

    with open(output_file, 'w') as out_file:
        try:
            # Loop through all files and folders in the directory
            for root, dirs, files in os.walk(directory):
                # Check if the current directory is not in the ignore list
                if os.path.basename(root) not in ignore_items:
                    for file in files:
                        # Check if the file extension is not in the ignore list
                        if not any(file.endswith(ext) for ext in ignore_extensions):
                            file_path = os.path.join(root, file)
                            # Write the file path as a separator
                            out_file.write(f"############## Begin of {file_path} ##############\n")

                            try:
                                # Read and write the content of each file
                                with open(file_path, 'r') as f:
                                    out_file.write(f.read())
                            except (IOError, UnicodeDecodeError) as e:
                                print(f"Error processing file {file_path}: {e}")
                            else:
                                file_count += 1
                            # Write an end separator
                            out_file.write(f"\n############## End of {file_path} ##############\n\n")
                            added_extensions.add(os.path.splitext(file)[1])
                        else:
                            ignored_extensions.add(os.path.splitext(file)[1])
                    # Check if the directory is not in the ignore list
                    if os.path.basename(root) not in ignore_items:
                        out_file.write(f"############## Directory: {root} ##############\n\n")
                else:
                    ignored_items.append(os.path.basename(root))

        except OSError as e:
            print(f"Error processing directory {directory}: {e}")

    print(f"Processed {file_count} files.")
    print(f"Ignored extensions: {', '.join(ignored_extensions)}")
    print(f"added extensions: {', '.join(added_extensions)}")
    print(f"Ignored items: {', '.join(ignored_items)}")

if __name__ == "__main__":
    # Example usage
    write_directory_contents('/Users/edsteine/Documents/Projects/PortfolioProjects/wproject2/test', '/Users/edsteine/Documents/Projects/PortfolioProjects/wproject2/output.txt')