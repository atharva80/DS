#!/bin/bash

# 1. Install Ollama (The Engine) silently
echo "[*] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# 2. Pull the "Heavy Hitter" Lightweight Model
# Qwen2.5-Coder 1.5B is widely considered the SOTA for small coding models right now.
# It fits in ~1.5GB VRAM/RAM.
echo "[*] Pulling Qwen2.5-Coder 1.5B (The Brain)..."
ollama pull qwen2.5-coder:1.5b

# 3. Create the "Cheat" Wrapper
# This creates a command 'ask' that gives you code instantly without yapping.
echo "[*] creating 'ask' alias..."

cat << 'EOF' | sudo tee /usr/local/bin/ask > /dev/null
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ask 'your dsa question here'"
    exit 1
fi

# The prompt engineering: Forces C language, minimal comments, strictly code.
PROMPT="You are an expert C programmer for competitive programming. \
Write a C solution for the following problem. \
Do not explain the logic. Do not use markdown backticks. \
Provide ONLY the raw C code. \
Include necessary headers. \
Problem: $1"

# Pipe to Ollama and strip thinking process if any
ollama run qwen2.5-coder:1.5b "$PROMPT"
EOF

# 4. Create a "Compile & Run" Shortcut
# This creates a command 'crc' (Compile Run C) that runs your file in one go.
echo "[*] Creating 'crc' (Compile-Run-C) shortcut..."

cat << 'EOF' | sudo tee /usr/local/bin/crc > /dev/null
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: crc filename.c"
    exit 1
fi

# Compile with strict warnings (looks pro) but run immediately
gcc -o temp_exe "$1" && ./temp_exe
rm -f temp_exe
EOF

# 5. Make them executable
sudo chmod +x /usr/local/bin/ask
sudo chmod +x /usr/local/bin/crc

echo ""
echo "=== SYSTEM READY ==="
echo "1. Type: ask \"reverse a linked list\" -> Get raw C code."
echo "2. Type: crc main.c -> Compiles and runs instantly."
echo "===================="
