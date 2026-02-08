# Ripgrep (rg) Cheatsheet

## Basic Usage
rg "pattern"                    # Search recursively in current dir
rg "pattern" path/to/dir        # Search in specific directory
rg -i "pattern"                 # Case-insensitive search
rg -w "word"                    # Match whole words only
rg -F "literal.string"          # Literal string (no regex)

## Filtering Files
rg "pattern" -t py              # Only Python files
rg "pattern" -t js -t ts        # Multiple file types
rg "pattern" -T test            # Exclude test files
rg "pattern" -g "*.py"          # Glob filter
rg "pattern" -g "!*.min.js"     # Exclude glob
rg "pattern" -g "src/**"        # Only in src/ directory

## Output Control
rg -l "pattern"                 # List filenames only
rg -c "pattern"                 # Count matches per file
rg -n "pattern"                 # Show line numbers (default)
rg -C 3 "pattern"              # 3 lines of context (before + after)
rg -B 2 "pattern"              # 2 lines before
rg -A 2 "pattern"              # 2 lines after

## Advanced
rg -m 1 "pattern"              # First match per file only
rg --json "pattern"            # JSON output (for piping)
rg -U "multi\nline"            # Multiline search
rg -e "pat1" -e "pat2"         # Multiple patterns (OR)
rg "pattern" --replace "new"   # Preview replacements (dry-run)
rg --hidden "pattern"          # Include hidden files
rg --no-ignore "pattern"       # Don't respect .gitignore

## Common Patterns
rg "TODO|FIXME|HACK"           # Find all code annotations
rg "def \w+\(" -t py           # Find Python function definitions
rg "import .* from" -t ts      # Find TS imports
rg "class \w+" -t py           # Find Python class definitions

## List Supported File Types
rg --type-list                  # Show all built-in file types
