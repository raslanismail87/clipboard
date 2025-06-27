#!/bin/bash

# Version management utility for ClipFlow

VERSION_FILE=".version"

show_usage() {
    echo "ClipFlow Version Management"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  show              Show current version"
    echo "  set <version>     Set specific version (e.g., 2.0.0)"
    echo "  major             Increment major version (1.2.3 → 2.0.0)"
    echo "  minor             Increment minor version (1.2.3 → 1.3.0)"
    echo "  patch             Increment patch version (1.2.3 → 1.2.4)"
    echo "  help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 show           # Shows: 1.2.3"
    echo "  $0 set 2.0.0      # Sets version to 2.0.0"
    echo "  $0 major          # 1.2.3 → 2.0.0"
    echo "  $0 minor          # 1.2.3 → 1.3.0"
    echo "  $0 patch          # 1.2.3 → 1.2.4"
}

get_current_version() {
    if [ ! -f "$VERSION_FILE" ]; then
        echo "1.1.0" > "$VERSION_FILE"
    fi
    cat "$VERSION_FILE"
}

set_version() {
    local new_version="$1"
    if [[ ! $new_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "❌ Invalid version format. Use semantic versioning (e.g., 1.2.3)"
        exit 1
    fi
    echo "$new_version" > "$VERSION_FILE"
    echo "✅ Version set to: $new_version"
}

increment_version() {
    local current_version=$(get_current_version)
    IFS='.' read -r MAJOR MINOR PATCH <<< "$current_version"
    
    case $1 in
        "major")
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        "minor")
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        "patch")
            PATCH=$((PATCH + 1))
            ;;
        *)
            echo "❌ Invalid increment type: $1"
            exit 1
            ;;
    esac
    
    local new_version="${MAJOR}.${MINOR}.${PATCH}"
    echo "$new_version" > "$VERSION_FILE"
    echo "🔄 Version updated: $current_version → $new_version"
}

case "${1:-help}" in
    "show")
        echo "📋 Current version: $(get_current_version)"
        ;;
    "set")
        if [ -z "$2" ]; then
            echo "❌ Please specify a version number"
            echo "Usage: $0 set <version>"
            exit 1
        fi
        set_version "$2"
        ;;
    "major"|"minor"|"patch")
        increment_version "$1"
        ;;
    "help"|*)
        show_usage
        ;;
esac