#!/usr/bin/env python3
"""
Parse Claude Code conversation JSONL files into readable markdown format
"""
import json
import sys
from pathlib import Path


def parse_conversation(jsonl_path, output_path, session_id="unknown"):
    """Parse a JSONL conversation file into markdown"""

    with open(output_path, 'w') as outfile:
        # Write header
        from datetime import datetime
        outfile.write("# Conversation Log\n")
        outfile.write(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        outfile.write(f"Session ID: {session_id}\n")
        outfile.write("\n---\n\n")

        # Process each line
        with open(jsonl_path, 'r') as infile:
            for line in infile:
                try:
                    data = json.loads(line)

                    msg_type = data.get('type')
                    message = data.get('message', {})
                    role = message.get('role')

                    # Process user messages
                    if msg_type == 'user' and role == 'user':
                        content = message.get('content')

                        # Skip if content is a list (tool results)
                        if isinstance(content, list):
                            continue

                        # Skip meta messages
                        if not content or 'Caveat:' in content:
                            continue
                        if '<command-name>' in content or '<local-command-stdout>' in content:
                            continue

                        outfile.write("## USER\n\n")
                        outfile.write(f"{content}\n\n")

                    # Process assistant messages
                    elif msg_type == 'assistant' and role == 'assistant':
                        content_list = message.get('content', [])

                        if not isinstance(content_list, list):
                            continue

                        has_content = False
                        assistant_text = []
                        tool_uses = []

                        for item in content_list:
                            if item.get('type') == 'text':
                                text = item.get('text', '').strip()
                                if text:
                                    assistant_text.append(text)
                                    has_content = True

                            elif item.get('type') == 'tool_use':
                                tool_name = item.get('name', 'unknown')
                                tool_input = item.get('input', {})
                                tool_uses.append((tool_name, tool_input))
                                has_content = True

                        if has_content:
                            outfile.write("## ASSISTANT\n\n")

                            # Write text content
                            for text in assistant_text:
                                outfile.write(f"{text}\n\n")

                            # Write tool uses
                            if tool_uses:
                                for tool_name, tool_input in tool_uses:
                                    outfile.write(f"**Tool:** `{tool_name}`\n")
                                    if tool_input:
                                        # Only show a few key fields to keep it readable
                                        if 'file_path' in tool_input:
                                            outfile.write(f"- file_path: `{tool_input['file_path']}`\n")
                                        if 'pattern' in tool_input:
                                            outfile.write(f"- pattern: `{tool_input['pattern']}`\n")
                                        if 'command' in tool_input:
                                            cmd = tool_input['command']
                                            if len(cmd) > 100:
                                                cmd = cmd[:100] + '...'
                                            outfile.write(f"- command: `{cmd}`\n")
                                    outfile.write("\n")

                except json.JSONDecodeError:
                    continue
                except Exception as e:
                    # Don't let parsing errors stop the whole process
                    print(f"Warning: Error processing line: {e}", file=sys.stderr)
                    continue


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: parse-conversation.py <input.jsonl> <output.md> [session_id]")
        sys.exit(1)

    jsonl_path = sys.argv[1]
    output_path = sys.argv[2]
    session_id = sys.argv[3] if len(sys.argv) > 3 else "unknown"

    parse_conversation(jsonl_path, output_path, session_id)
