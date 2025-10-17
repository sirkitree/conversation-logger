#!/bin/bash
# Save conversation transcript to logs directory
# Usage: save-conversation.sh <transcript-path> [session-id]

LOG_DIR="$HOME/.claude/conversation-logs"
mkdir -p "$LOG_DIR"

# Check if transcript path provided
if [ -z "$1" ]; then
    echo "Error: No transcript path provided"
    echo "Usage: $0 <transcript-path> [session-id]"
    exit 1
fi

TRANSCRIPT_PATH="$1"
SESSION_ID="${2:-unknown}"

# Check if transcript exists
if [ ! -f "$TRANSCRIPT_PATH" ]; then
    echo "Error: Transcript file not found: $TRANSCRIPT_PATH"
    exit 1
fi

# Generate timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Copy the full transcript
cp "$TRANSCRIPT_PATH" "$LOG_DIR/conversation_$TIMESTAMP.jsonl"

# Create symlink to latest conversation
ln -sf "$LOG_DIR/conversation_$TIMESTAMP.jsonl" "$LOG_DIR/conversation_latest.jsonl"

# Save session metadata
cat > "$LOG_DIR/session_$TIMESTAMP.json" <<EOF
{
  "session_id": "$SESSION_ID",
  "timestamp": "$TIMESTAMP",
  "date": "$(date '+%Y-%m-%d %H:%M:%S')",
  "transcript_path": "$TRANSCRIPT_PATH"
}
EOF

# Parse to markdown using Python parser
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARSER_PATH="$SCRIPT_DIR/parse-conversation.py"

if command -v python3 &> /dev/null && [ -f "$PARSER_PATH" ]; then
    python3 "$PARSER_PATH" \
        "$LOG_DIR/conversation_$TIMESTAMP.jsonl" \
        "$LOG_DIR/conversation_$TIMESTAMP.md" \
        "$SESSION_ID" 2>/dev/null || {
            echo "Warning: Failed to parse conversation to markdown"
        }

    # Create symlink to latest markdown
    ln -sf "$LOG_DIR/conversation_$TIMESTAMP.md" "$LOG_DIR/conversation_latest.md"

    echo "✓ Conversation saved successfully!"
    echo "  - JSONL: $LOG_DIR/conversation_$TIMESTAMP.jsonl"
    echo "  - Markdown: $LOG_DIR/conversation_$TIMESTAMP.md"
    echo "  - Metadata: $LOG_DIR/session_$TIMESTAMP.json"
else
    echo "Warning: python3 or parser not found, skipping markdown conversion"
    echo "✓ Conversation saved to: $LOG_DIR/conversation_$TIMESTAMP.jsonl"
fi

exit 0
