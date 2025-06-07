#!/usr/bin/env python3
import os
import sys
import json
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

def ensure_yaml_installed():
    try:
        import yaml
    except ImportError:
        print_color("PyYAML is required but not installed. Installing it now...", 'yellow')
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyyaml"])
        import yaml
    return yaml

yaml = ensure_yaml_installed()

# Check Python version
if sys.version_info < (3, 6):
    print("Error: Python 3.6 or higher is required.")
    sys.exit(1)

def print_color(text, color):
    colors = {
        'red': '\033[91m',
        'green': '\033[92m',
        'blue': '\033[94m',
        'yellow': '\033[93m',
        'end': '\033[0m'
    }
    print(f"{colors.get(color, '')}{text}{colors['end']}")

def get_input(prompt, default=None):
    if default:
        result = input(f"{prompt} [{default}]: ").strip()
        return result if result else default
    return input(f"{prompt}: ").strip()

def get_boolean_input(prompt, default=True):
    while True:
        result = input(f"{prompt} [Y/n]: " if default else f"{prompt} [y/N]: ").strip().lower()
        if not result:
            return default
        if result in ['y', 'yes']:
            return True
        if result in ['n', 'no']:
            return False
        print("Please answer 'y' or 'n'")

def update_metadata(config):
    metadata_path = Path('metadata.yaml')
    
    # Read existing metadata
    with open(metadata_path, 'r') as f:
        try:
            metadata = yaml.safe_load(f) or {}
        except yaml.YAMLError as e:
            print_color(f"Error reading metadata.yaml: {e}", 'red')
            sys.exit(1)
    
    # Update metadata with new values
    metadata.update({
        'title': config['title'],
        'author': config['authors'],
        'publication_date': config['date'],
        'publisher': config['publisher'],
        'rights': f"© {datetime.now().year} {', '.join(config['authors'])}",
    })
    
    # Preserve any existing fields that we don't modify
    
    # Write updated metadata
    with open(metadata_path, 'w') as f:
        try:
            yaml.dump(metadata, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
        except yaml.YAMLError as e:
            print_color(f"Error writing metadata.yaml: {e}", 'red')
            sys.exit(1)

def update_sample_book(config):
    typst_path = Path('output/sample-book.typ')
    with open(typst_path, 'r') as f:
        content = f.read()

    # Update title and authors
    authors_str = '",\n  "'.join(config['authors'])
    old_section = '''title: "Sample Book",
  authors: (
  "Antonio Mateos Belinchón", 
  "Alejandro Modroño Vara"  ),'''
    
    new_section = f'''title: "{config['title']}",
  authors: (
  "{authors_str}"  ),'''
    
    content = content.replace(old_section, new_section)

    with open(typst_path, 'w') as f:
        f.write(content)

def clean_contents():
    contents_dir = Path('contents')
    # Remove example files
    for f in contents_dir.glob('*.md'):
        if f.name.startswith(('000.', '001.')):
            f.unlink()

def create_first_chapter(config):
    chapter_content = f"""# Introduction

Welcome to {config['title']}

## About This Book

{config['description']}

## How to Use This Book

This book is organized into chapters, each focusing on a specific topic. You can read it sequentially or jump to the chapters that interest you most.

## Prerequisites

[List any prerequisites or required knowledge here]

## Acknowledgments

[Add your acknowledgments here]
"""
    
    with open(Path('contents') / '001.introduction.md', 'w') as f:
        f.write(chapter_content)

def save_config(config):
    with open('.book-config.json', 'w') as f:
        json.dump(config, f, indent=2)

def load_config():
    try:
        with open('.book-config.json', 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return None

def main():
    print_color("📚 Welcome to the Book Project Initializer!", 'blue')
    print("This script will help you set up your book project.\n")

    # Check for existing configuration
    existing_config = load_config()
    if existing_config and get_boolean_input("Found existing configuration. Would you like to use it as defaults?"):
        config = existing_config
        print("\nCurrent settings:")
        for key, value in config.items():
            print(f"{key}: {value}")
        if not get_boolean_input("\nWould you like to modify these settings?"):
            print_color("\n✅ Using existing settings.", 'green')
            return
    else:
        config = {}

    # Get basic information
    config['title'] = get_input("What's the title of your book?", 
                               existing_config.get('title', "My New Book") if existing_config else "My New Book")
    
    # Get authors
    authors = []
    default_authors = existing_config.get('authors', []) if existing_config else []
    if default_authors:
        print("\nCurrent authors:", ", ".join(default_authors))
        if not get_boolean_input("Would you like to modify the author list?"):
            authors = default_authors
    
    if not authors:
        while True:
            author = get_input(f"Enter author name {len(authors) + 1} (or press Enter to finish)", 
                             None if authors else "Your Name")
            if not author and authors:
                break
            if author:
                authors.append(author)
    config['authors'] = authors

    # Get other metadata
    config['publisher'] = get_input("Publisher name?", 
                                   existing_config.get('publisher', "Self Published") if existing_config else "Self Published")
    config['date'] = get_input("Publication date (YYYY-MM-DD)?", 
                              existing_config.get('date', datetime.now().strftime("%Y-%m-%d")) if existing_config else datetime.now().strftime("%Y-%m-%d"))
    config['description'] = get_input("Brief description of your book?", 
                                    existing_config.get('description', "A comprehensive guide to...") if existing_config else "A comprehensive guide to...")
    
    # License choice
    print("\nChoose a license:")
    print("1. Creative Commons BY-NC-SA 4.0 (default)")
    print("2. Creative Commons BY-SA 4.0")
    print("3. All Rights Reserved")
    default_license = "1"
    if existing_config and existing_config.get('license'):
        default_license = {"CC-BY-NC-SA-4.0": "1", "CC-BY-SA-4.0": "2", "ARR": "3"}.get(existing_config['license'], "1")
    license_choice = get_input("Enter choice (1-3)", default_license)
    config['license'] = {
        "1": "CC-BY-NC-SA-4.0",
        "2": "CC-BY-SA-4.0",
        "3": "ARR"
    }.get(license_choice, "CC-BY-NC-SA-4.0")

    # Confirm and apply changes
    print("\nReview your settings:")
    for key, value in config.items():
        print(f"{key}: {value}")

    if get_boolean_input("\nApply these settings?"):
        try:
            update_metadata(config)
            update_sample_book(config)
            if get_boolean_input("Would you like to remove the example chapters and create a new introduction?", True):
                clean_contents()
                create_first_chapter(config)
            save_config(config)
            print_color("\n✅ Your book project has been initialized successfully!", 'green')
            print("\nNext steps:")
            print("1. Review the generated files in the 'contents/' directory")
            print("2. Run 'make pdf' to generate a PDF preview")
            print("3. Run 'make epub' to generate an EPUB version")
            print("4. Run 'make watch' to automatically rebuild when you make changes")
        except Exception as e:
            print_color(f"\n❌ Error: {str(e)}", 'red')
            sys.exit(1)
    else:
        print_color("\nSetup cancelled.", 'yellow')

if __name__ == "__main__":
    main()
