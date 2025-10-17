# Conversation Logger Skill

A Claude Code skill that enables systematic saving, searching, and retrieving of conversation transcripts.

## What is this?

This is a **Skill** for Claude Code that converts raw conversation transcripts into readable markdown format and provides powerful search capabilities across all saved conversations. Unlike plugins, skills are simpler to install, more portable, and work across Claude apps, Claude Code, and the API.

## Features

- **Save conversations** - Automatically parse JSONL transcripts to readable markdown
- **Search through history** - Find past conversations by keyword with context
- **Browse recent sessions** - List and view recent conversations
- **Automatic activation** - Claude uses this skill when you ask about conversation history
- **Portable & simple** - No hooks, no complex setup, just drop in the skills folder

## Installation

### Quick Install

1. Download the latest `conversation-logger.zip` from releases
2. Extract to `~/.claude/skills/`:
   ```bash
   unzip conversation-logger.zip -d ~/.claude/skills/
   ```
3. That's it! Claude will automatically use this skill when relevant

### Manual Install

```bash
cd ~/.claude/skills
git clone https://github.com/sirkitree/conversation-logger.git
```

## Usage

The skill activates automatically when you:
- Ask Claude to save the current conversation
- Search through past conversations for context
- Ask about previous sessions or topics discussed

### Example Prompts

```
"Save this conversation"
"Search conversations about docker configuration"
"When did we work on the authentication bug?"
"Show me recent conversations"
```

### Direct Script Usage

You can also use the scripts directly:

```bash
# Save a conversation
bash ~/.claude/skills/conversation-logger/scripts/save-conversation.sh <transcript-path> [session-id]

# Search conversations
bash ~/.claude/skills/conversation-logger/scripts/search-conversations.sh "search-term"

# List all conversations
bash ~/.claude/skills/conversation-logger/scripts/search-conversations.sh --list

# Show recent conversations
bash ~/.claude/skills/conversation-logger/scripts/search-conversations.sh --recent 5
```

## How It Works

1. **Save**: Copies JSONL transcript to `~/.claude/conversation-logs/`
2. **Parse**: Converts to human-readable markdown format
3. **Search**: Full-text search across all saved conversations
4. **Retrieve**: Access complete conversation history

## File Structure

```
conversation-logger/
├── SKILL.md                         # Skill instructions for Claude
├── README.md                        # This file
└── scripts/
    ├── save-conversation.sh         # Save and parse conversations
    ├── search-conversations.sh      # Search utility
    └── parse-conversation.py        # JSONL to markdown converter
```

## Saved Files Location

Conversations are saved to `~/.claude/conversation-logs/`:
- `conversation_YYYY-MM-DD_HH-MM-SS.jsonl` - Raw transcript
- `conversation_YYYY-MM-DD_HH-MM-SS.md` - Readable markdown
- `session_YYYY-MM-DD_HH-MM-SS.json` - Session metadata
- `conversation_latest.md` - Symlink to most recent

## Requirements

- `python3` - For parsing JSONL to markdown
- `bash` - For running scripts
- `jq` - Optional, for JSON metadata handling

## Why a Skill Instead of a Plugin?

**Skills vs Plugins**:
- **Simpler**: No marketplace setup, no executable permissions hassles
- **Portable**: Works across Claude apps, Claude Code, and API
- **Intuitive**: Claude guides you naturally, no slash commands to remember
- **Maintainable**: Fewer moving parts, easier to troubleshoot
- **Cross-platform**: Same format everywhere

## Upgrading from the Plugin

If you previously used the `conversation-saver` plugin:
1. Install this skill (instructions above)
2. The skill works with existing logs in `~/.claude/conversation-logs/`
3. You can keep the plugin for automatic session-end saves, or rely on explicit saves with the skill

## Contributing

Contributions welcome! Feel free to:
- Report bugs via GitHub Issues
- Suggest features
- Submit pull requests
- Share your use cases

## License

MIT License - feel free to use and modify as needed.

## Related

- [Claude Code Skills](https://www.anthropic.com/news/skills) - Official skills announcement
- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code) - Official documentation
- [Skills Repository](https://github.com/anthropics/skills) - Example skills

## Credits

Created with Claude Code itself. Built on the foundation of the original `conversation-saver` plugin.

---

*Never lose a conversation again. Install once, search forever.*
