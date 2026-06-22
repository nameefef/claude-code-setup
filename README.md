# Claude Code 一键配置工具

跳过登录 + DeepSeek 接入 + 中文汉化

## 用法

```bash
# 1. 克隆仓库
git clone https://github.com/你的用户名/claude-code-setup.git
cd claude-code-setup

# 2. 方式一：交互式输入（推荐）
DEEPSEEK_API_KEY="sk-你的key" bash setup.sh

# 3. 方式二：也适用
bash setup.sh
# 然后按提示输入 API Key
```

## 功能

- ✅ 自动跳过 Claude Code 登录页面
- ✅ 接入 DeepSeek V4 Pro 模型
- ✅ 安装中文汉化插件
- ✅ API Key 交互式输入，不写死在脚本里

## 环境变量参考

| 变量 | 说明 | 示例 |
|------|------|------|
| `ANTHROPIC_BASE_URL` | API 地址 | `https://api.deepseek.com/anthropic` |
| `ANTHROPIC_AUTH_TOKEN` | API 密钥 | `sk-xxx...` |
| `ANTHROPIC_MODEL` | 模型名 | `deepseek-v4-pro` |
