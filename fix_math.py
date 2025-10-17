import re
import os
import sys

if len(sys.argv) != 2:
    print("Usage: python fix_math.py <folder_with_md_files>")
    sys.exit(1)

folder = sys.argv[1]

# Pattern to convert T(k{i}) -> T(k_i)
subscript_pattern = re.compile(r'([a-zA-Z]+)\(k\{([0-9a-zA-Z_]+)\}\)')

# Pattern to detect math blocks starting and ending with $$ or $
math_block_pattern = re.compile(r'(\$\$.*?\$\$|\$.*?\$)', re.DOTALL)

def fix_math_block(block):
    # Replace T(k{i}) with T(k_i)
    block = subscript_pattern.sub(r'\1(k_\2)', block)
    # Replace \textdollar with \$
    block = block.replace(r'\textdollar', r'\$')
    # Remove newlines inside math blocks
    block = block.replace('\n', ' ')
    # Optional: remove multiple spaces
    block = re.sub(r'\s+', ' ', block)
    return block

for filename in os.listdir(folder):
    if filename.endswith('.md'):
        path = os.path.join(folder, filename)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Process all math blocks
        content = math_block_pattern.sub(lambda m: fix_math_block(m.group(0)), content)

        # Optional: prepend header if desired
        header = f"# {os.path.splitext(filename)[0]}\n\n"
        if not content.startswith("#"):
            content = header + content

        # Save back
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"Processed {filename}")

print("✅ All Markdown files fixed for MathJax rendering.")

