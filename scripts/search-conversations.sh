#!/bin/bash
# Search through saved conversation logs

LOGS_DIR="$HOME/.claude/conversation-logs"

# Check if logs directory exists
if [ ! -d "$LOGS_DIR" ]; then
    echo "No conversation logs found at $LOGS_DIR"
    exit 1
fi

# Show usage if no arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <search-term> [options]"
    echo ""
    echo "Search through conversation logs in $LOGS_DIR"
    echo ""
    echo "Options:"
    echo "  -l, --list       List all available conversation logs"
    echo "  -r, --recent N   Show N most recent conversations (default: 5)"
    echo "  -c, --context N  Show N lines of context around matches (default: 2)"
    echo ""
    echo "Examples:"
    echo "  $0 --list                    # List all conversations"
    echo "  $0 --recent 3                # Show 3 most recent conversations"
    echo "  $0 'hooks'                   # Search for 'hooks' in all conversations"
    echo "  $0 'git commit' --context 5  # Search with 5 lines of context"
    exit 0
fi

# Parse arguments
SEARCH_TERM=""
CONTEXT_LINES=2
ACTION="search"
RECENT_COUNT=5

while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--list)
            ACTION="list"
            shift
            ;;
        -r|--recent)
            ACTION="recent"
            RECENT_COUNT="$2"
            shift 2
            ;;
        -c|--context)
            CONTEXT_LINES="$2"
            shift 2
            ;;
        *)
            SEARCH_TERM="$1"
            shift
            ;;
    esac
done

# List all conversations
if [ "$ACTION" = "list" ]; then
    echo "Available conversation logs:"
    echo ""
    ls -lh "$LOGS_DIR"/*.md 2>/dev/null | while read -r line; do
        file=$(echo "$line" | awk '{print $NF}')
        size=$(echo "$line" | awk '{print $5}')
        date=$(basename "$file" | sed 's/conversation_\(.*\)\.md/\1/' | tr '_' ' ')
        echo "  $date ($size)"
    done
    exit 0
fi

# Show recent conversations
if [ "$ACTION" = "recent" ]; then
    echo "Most recent $RECENT_COUNT conversations:"
    echo ""
    ls -t "$LOGS_DIR"/conversation_*.md 2>/dev/null | head -n "$RECENT_COUNT" | while read -r file; do
        date=$(basename "$file" | sed 's/conversation_\(.*\)\.md/\1/' | tr '_' ' ')
        size=$(wc -l < "$file")
        echo "=== $date ($size lines) ==="
        head -20 "$file"
        echo ""
        echo "... (use 'cat $file' to see full conversation)"
        echo ""
    done
    exit 0
fi

# Search for term
if [ -z "$SEARCH_TERM" ]; then
    echo "Error: No search term provided"
    exit 1
fi

echo "Searching for '$SEARCH_TERM' in conversation logs..."
echo ""

# Search through markdown files with context
grep -r -i -C "$CONTEXT_LINES" "$SEARCH_TERM" "$LOGS_DIR"/*.md 2>/dev/null | while IFS=: read -r file content; do
    # Skip empty lines and separators
    if [[ -z "$file" ]] || [[ "$file" == "--" ]]; then
        echo ""
        continue
    fi

    # Extract filename only if we have a valid file path
    if [[ -f "$file" ]]; then
        filename=$(basename "$file" | sed 's/conversation_\(.*\)\.md/\1/' | tr '_' ' ')
        echo "[$filename] $content"
    fi
done

# Count matches
MATCH_COUNT=$(grep -r -i -l "$SEARCH_TERM" "$LOGS_DIR"/*.md 2>/dev/null | wc -l)
echo ""
echo "Found matches in $MATCH_COUNT conversation(s)"
