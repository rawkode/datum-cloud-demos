#!/usr/bin/env bash
# Register datum-mcp with Claude Code as a stdio server.
# --scope user makes it available in every project; drop it for the current directory only.
claude mcp add --scope user datum-mcp -- datum-mcp
