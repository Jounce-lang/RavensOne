#!/bin/bash
# rename_text_content.sh
# Replaces ravensone/raven text with jounce/inc throughout the repository

set -e  # Exit on any error

echo "=========================================="
echo "Ravensone → Jounce Text Replacement Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository!${NC}"
    echo "Please run this script from the root of your RavensOne repo."
    exit 1
fi

echo -e "${GREEN}✓${NC} Found git repository"
echo ""

# Step 2: Show what will be changed (preview)
echo "=========================================="
echo "PREVIEW: Searching for text to replace..."
echo "=========================================="
echo ""

echo "Files containing 'ravensone' (any case):"
grep -rli "ravensone" . --exclude-dir=.git | head -20
echo ""

echo "Total occurrences of 'ravensone' variations:"
echo -n "  ravensone: "
grep -ro "ravensone" . --exclude-dir=.git | wc -l | tr -d ' '
echo -n "  Ravensone: "
grep -ro "Ravensone" . --exclude-dir=.git | wc -l | tr -d ' '
echo -n "  RavensOne: "
grep -ro "RavensOne" . --exclude-dir=.git | wc -l | tr -d ' '
echo -n "  RAVENSONE: "
grep -ro "RAVENSONE" . --exclude-dir=.git | wc -l | tr -d ' '
echo ""

# Step 3: Ask for confirmation
echo -e "${YELLOW}This will replace:${NC}"
echo "  ravensone → jounce-lang"
echo "  Ravensone → Jounce-lang"
echo "  RavensOne → Jounce-Lang"
echo "  RAVENSONE → JOUNCE-LANG"
echo ""
echo "  raven → jounce"
echo "  Raven → Jounce"
echo "  RAVEN → Jounce"
echo ""
read -p "Do you want to proceed? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted.${NC}"
    exit 0
fi

echo ""
echo "=========================================="
echo "Performing replacements..."
echo "=========================================="
echo ""

# Step 4: Do the replacements
# Find all files (excluding .git directory and common binary files)
find . -type f \
    -not -path "./.git/*" \
    -not -name "*.png" \
    -not -name "*.jpg" \
    -not -name "*.jpeg" \
    -not -name "*.gif" \
    -not -name "*.pdf" \
    -not -name "*.zip" \
    -not -name "*.tar" \
    -not -name "*.gz" \
    -exec sed -i '' \
        -e 's/ravensone/jounce/g' \
        -e 's/Ravensone/Jounce/g' \
        -e 's/RavensOne/JounceOne/g' \
        -e 's/RAVENSONE/JOUNCE/g' \
        -e 's/\braven\b/inc/g' \
        -e 's/\bRaven\b/Inc/g' \
        -e 's/\bRAVEN\b/INC/g' \
    {} + 2>/dev/null || true

echo -e "${GREEN}✓${NC} Text replacement complete!"
echo ""

# Step 5: Verify the changes
echo "=========================================="
echo "Verification..."
echo "=========================================="
echo ""

REMAINING=$(grep -ri "ravensone" . --exclude-dir=.git 2>/dev/null | wc -l | tr -d ' ')

if [ "$REMAINING" -eq "0" ]; then
    echo -e "${GREEN}✓${NC} Success! No instances of 'ravensone' found."
else
    echo -e "${YELLOW}⚠${NC}  Warning: Found $REMAINING remaining instances of 'ravensone'"
    echo "These may be in binary files or intentional. Review with:"
    echo "  grep -ri 'ravensone' . --exclude-dir=.git"
fi

echo ""

# Step 6: Show git status
echo "=========================================="
echo "Git Status (files changed):"
echo "=========================================="
git status --short
echo ""

# Step 7: Instructions for next steps
echo "=========================================="
echo -e "${GREEN}Done!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Stage changes: git add ."
echo "  3. Commit: git commit -m \"Replace ravensone with jounce in file contents\""
echo "  4. Push: git push origin main"
echo ""