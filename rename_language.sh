#!/bin/bash

# Language Rename Script1
# Renames ravensone -> jounce and .raven -> .jnc
# Usage: ./rename_language.sh [--dry-run]

set -e

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "=== DRY RUN MODE - No changes will be made ==="
    echo
fi

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository. Please run from the root of your repo."
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    log_warn "You have uncommitted changes. Consider committing or stashing them first."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "==================================="
echo "Language Rename Script"
echo "==================================="
echo "Old name: ravensone"
echo "New name: jounce"
echo "Old extension: .raven"
echo "New extension: .jnc"
echo "==================================="
echo

# Create a backup branch
if [ "$DRY_RUN" = false ]; then
    BACKUP_BRANCH="backup-before-rename-$(date +%Y%m%d-%H%M%S)"
    log_info "Creating backup branch: $BACKUP_BRANCH"
    git branch "$BACKUP_BRANCH"
    log_info "Backup created. You can restore with: git checkout $BACKUP_BRANCH"
    echo
fi

# Step 1: Rename .raven files to .jnc
log_info "Step 1: Renaming .raven files to .jnc..."
RAVEN_FILES=$(find . -type f -name "*.raven" ! -path "*/\.*" ! -path "*/node_modules/*" ! -path "*/target/*" ! -path "*/build/*")

if [ -z "$RAVEN_FILES" ]; then
    log_warn "No .raven files found"
else
    echo "$RAVEN_FILES" | while read -r file; do
        newfile="${file%.raven}.jnc"
        if [ "$DRY_RUN" = true ]; then
            echo "  Would rename: $file -> $newfile"
        else
            git mv "$file" "$newfile" 2>/dev/null || mv "$file" "$newfile"
            echo "  Renamed: $file -> $newfile"
        fi
    done
fi
echo

# Step 2: Update file contents - replace text references
log_info "Step 2: Updating content in files..."

# Files to search (excluding binary files and common directories to skip)
SEARCHABLE_FILES=$(find . -type f \
    ! -path "*/\.*" \
    ! -path "*/node_modules/*" \
    ! -path "*/target/*" \
    ! -path "*/build/*" \
    ! -path "*/dist/*" \
    ! -path "*/.git/*" \
    ! -name "*.png" \
    ! -name "*.jpg" \
    ! -name "*.jpeg" \
    ! -name "*.gif" \
    ! -name "*.ico" \
    ! -name "*.pdf" \
    ! -name "*.zip" \
    ! -name "*.tar" \
    ! -name "*.gz" \
    ! -name "rename_language.sh")

# Define all the patterns to replace
declare -A REPLACEMENTS=(
    ["ravensone"]="jounce"
    ["Ravensone"]="Jounce"
    ["RAVENSONE"]="JOUNCE"
    ["raven"]="jnc"
    [".raven"]=".jnc"
    ["Raven"]="Jnc"
)

if [ "$DRY_RUN" = true ]; then
    log_info "Searching for occurrences (dry run)..."
    for old in "${!REPLACEMENTS[@]}"; do
        COUNT=$(echo "$SEARCHABLE_FILES" | xargs grep -l "$old" 2>/dev/null | wc -l || echo "0")
        if [ "$COUNT" -gt 0 ]; then
            echo "  Pattern '$old' found in $COUNT files"
        fi
    done
else
    for old in "${!REPLACEMENTS[@]}"; do
        new="${REPLACEMENTS[$old]}"
        log_info "Replacing '$old' with '$new'..."
        
        # Use different sed syntax for macOS vs Linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            echo "$SEARCHABLE_FILES" | xargs sed -i '' "s/$old/$new/g" 2>/dev/null || true
        else
            # Linux
            echo "$SEARCHABLE_FILES" | xargs sed -i "s/$old/$new/g" 2>/dev/null || true
        fi
    done
fi
echo

# Step 3: Rename directories
log_info "Step 3: Checking for directories to rename..."
DIRS_TO_RENAME=$(find . -type d -name "*ravensone*" -o -name "*raven*" ! -path "*/\.*" ! -path "*/node_modules/*" | sort -r)

if [ -z "$DIRS_TO_RENAME" ]; then
    log_warn "No directories found to rename"
else
    echo "$DIRS_TO_RENAME" | while read -r dir; do
        # Skip if directory doesn't exist (may have been renamed already)
        [ ! -d "$dir" ] && continue
        
        newdir=$(echo "$dir" | sed 's/ravensone/jounce/g' | sed 's/raven/jnc/g')
        if [ "$dir" != "$newdir" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "  Would rename: $dir -> $newdir"
            else
                git mv "$dir" "$newdir" 2>/dev/null || mv "$dir" "$newdir"
                echo "  Renamed: $dir -> $newdir"
            fi
        fi
    done
fi
echo

# Step 4: Summary
echo "==================================="
if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN COMPLETE"
    echo "==================================="
    echo "Run without --dry-run to apply changes"
else
    echo "RENAME COMPLETE"
    echo "==================================="
    log_info "Next steps:"
    echo "  1. Review the changes: git status"
    echo "  2. Run your tests to ensure everything works"
    echo "  3. Commit the changes: git add -A && git commit -m 'Rename ravensone to jounce'"
    echo "  4. If something went wrong, restore backup: git checkout $BACKUP_BRANCH"
fi
echo "==================================="
