#!/usr/bin/env sh

# The markdown file to extract code blocks from
markdown_file="$1"
# Which code blocks to extract, e.g. bash for "```bash", ignoring e.g. "```yaml"
code_block="$2"
# Filter to ignore code blocks, e..g noci to ignore block with "```bash noci"
filter="$3"

echo 'set -x'
echo 'set -e'

awk '
BEGIN {
    in_code_block = 0;
    ignore_filter = "'"$filter"'";
}
/^```'"$code_block"'/ {
    in_code_block = 1;
    if (ignore_filter != "" && $0 ~ ignore_filter) {
        in_code_block = 0 ;
    }
    next;
}
/^```/ {
    in_code_block = 0;
    next;
}
( in_code_block ) { print }
' "$markdown_file"
