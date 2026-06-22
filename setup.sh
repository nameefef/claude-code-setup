#!/bin/bash
# ============================================================
# Claude Code 一键配置脚本
# 跳过登录 + DeepSeek 接入 + 中文汉化
# 用法: bash setup.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude Code 一键配置脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ---- Step 1: 检查 Claude Code ----
echo -e "${YELLOW}[1/4] 检查 Claude Code 安装状态...${NC}"
if command -v claude &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Claude Code 已安装: $(which claude)"
else
    echo -e "  ${RED}✗${NC} 未找到 Claude Code，请先安装:"
    echo "    npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# ---- Step 2: 跳过登录 ----
echo -e "${YELLOW}[2/4] 配置跳过登录页面...${NC}"

CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$CLAUDE_JSON" ]; then
    # 检查是否已有 hasCompletedOnboarding
    if grep -q '"hasCompletedOnboarding"' "$CLAUDE_JSON" 2>/dev/null; then
        sed -i'' 's/"hasCompletedOnboarding"[[:space:]]*:[[:space:]]*false/"hasCompletedOnboarding": true/g' "$CLAUDE_JSON" 2>/dev/null || true
    else
        # 在第一个 } 前插入
        sed -i'' 's/}$/,\n  "hasCompletedOnboarding": true\n}/' "$CLAUDE_JSON" 2>/dev/null
    fi
else
    echo '{"hasCompletedOnboarding": true}' > "$CLAUDE_JSON"
fi
echo -e "  ${GREEN}✓${NC} 已配置 ~/.claude.json"

# ---- Step 3: 中文汉化 ----
echo -e "${YELLOW}[3/4] 安装中文汉化插件...${NC}"

TMP_DIR=$(mktemp -d)
if git clone --depth=1 https://github.com/taekchef/claude-code-zh-cn.git "$TMP_DIR/claude-code-zh-cn" 2>/dev/null; then
    cd "$TMP_DIR/claude-code-zh-cn"
    bash install.sh 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} 汉化插件安装完成"
else
    echo -e "  ${YELLOW}⚠${NC} Git clone 失败，跳过汉化（不影响使用）"
fi
rm -rf "$TMP_DIR"

# ---- Step 4: 配置 DeepSeek API ----
echo -e "${YELLOW}[4/4] 配置 DeepSeek 模型接入...${NC}"

# 优先从环境变量读取，否则提示输入
API_KEY="${DEEPSEEK_API_KEY:-}"

if [ -z "$API_KEY" ]; then
    echo ""
    echo -e "  请输入你的 DeepSeek API Key（以 sk- 开头）:"
    read -r -p "  > " API_KEY
fi

if [ -z "$API_KEY" ]; then
    echo -e "  ${RED}✗${NC} 未提供 API Key，跳过配置"
    echo -e "  你可以之后手动运行:"
    echo '    export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"'
    echo '    export ANTHROPIC_AUTH_TOKEN="你的key"'
    echo '    export ANTHROPIC_MODEL="deepseek-v4-pro"'
else
    SHELL_RC="$HOME/.zshrc"
    [ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"

    cat >> "$SHELL_RC" << EOF

# ---- Claude Code DeepSeek 配置 ----
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="${API_KEY}"
export ANTHROPIC_MODEL="deepseek-v4-pro"
EOF

    # 当前会话也生效
    export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
    export ANTHROPIC_AUTH_TOKEN="${API_KEY}"
    export ANTHROPIC_MODEL="deepseek-v4-pro"

    echo -e "  ${GREEN}✓${NC} DeepSeek 配置已写入 $SHELL_RC"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 配置完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  启动: 直接运行 claude"
echo ""
echo "  注意:"
echo "  - 如果换了新终端，需要先: source ~/.zshrc"
echo "  - 汉化插件在 Claude Code 更新后可能失效，重新运行本脚本即可"
echo ""
