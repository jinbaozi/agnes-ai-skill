# Agnes AI 免费文本 / 生图 / 生视频 Agent Skill

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-blue)](./SKILL.md)
[![Models](https://img.shields.io/badge/models-text%20%7C%20image%20%7C%20video-black)](https://agnes-ai.com/doc)
[![Agnes AI](https://img.shields.io/badge/platform-Agnes%20AI-ff6b3d)](https://platform.agnes-ai.com/)
[![English README](https://img.shields.io/badge/docs-English-blue)](./README.md)

Agnes AI Skill 是面向 Codex、Claude Code、OpenClaw、Claude Desktop、Hermes、
WorkBuddy、Cherry Studio、Opencode 等 AI Agent 工具的免费全模态 Skill。它通过一个根目录
`SKILL.md` 帮助 Agent 调用 Agnes 2.0 API，支持文本生成、生图、图片编辑、文生视频、图生视频和
API 集成。

适合搜索 Agnes AI skill、Codex skills、Claude Code skills、OpenClaw skills、
免费 AI API、免费 AI 模型、免费生图、免费生视频、文生图和图生视频的 Agent 工作流。

English: Agnes AI free text, image, and video generation Agent Skill for Codex,
Claude Code, OpenClaw, Claude Desktop, Hermes, WorkBuddy, Cherry Studio,
Opencode, and other SKILL.md-compatible agent tools.

## 快速开始

使用支持仓库 Skill 的安装器：

```bash
npx skills add jomeswang/agnes-ai-skill -g
```

或直接把下面这句话复制给 Agent：

```text
请读取并安装 Agnes AI Skill：https://github.com/jomeswang/agnes-ai-skill
```

安装完成后，前往 [platform.agnes-ai.com/settings/apiKeys](https://platform.agnes-ai.com/settings/apiKeys) 注册并创建 Agnes API Key，再配置为 `AGNES_API_KEY`。之后告诉 Agent `我要生图`、`我要生视频`、`帮我改图` 或 `我要接入 Agnes API`，Agent 就可以自动选择合适的 Agnes 模型和执行方式。

这个 Skill 会帮助 Agent：

- 完成 Agnes AI 接入并持久化 `AGNES_API_KEY`
- 使用 `agnes-2.0-flash` 进行聊天、编码、流式输出和工具调用
- 使用 `agnes-image-2.0-flash` 与 `agnes-image-2.1-flash` 进行 AI 生图、图片编辑和图生图
- 使用 `agnes-video-v2.0` 进行文生视频、图生视频和异步视频生成
- 优先使用配套 `agnes-ai-cli` 执行真实请求

兼容工具：Codex、Claude Code、Claude Desktop、OpenClaw、Hermes、WorkBuddy、
Cherry Studio、Opencode、Kimi Work，以及其他 Agent Skills / SKILL.md 兼容环境。

![Agnes AI frontier models hero](./assets/images/agnes-frontier-models-banner.jpg)

## 重要公告

**Agnes 2.0 全模态模型 API 正式开放全球免费调用！**

- 不限期、全模态，API 调用完全免费（RPM 20 以内）
- 注册官网，生成 KEY，直接调用
- 文本、图像、视频全能适配
- 模型持续升级并保持免费

**官方平台：** https://platform.agnes-ai.com

> 当前官方模型文档也包含价格信息。涉及成本、额度或商业使用时，请以实时官方文档为准。

这个仓库提供一个根目录 `SKILL.md`，让编码 Agent 可以快速：

- 获取并持久化 Agnes API Key
- 使用 `agnes-2.0-flash` 进行聊天、编码、流式输出和工具调用
- 使用 `agnes-image-2.0-flash` 与 `agnes-image-2.1-flash` 进行图像生成和编辑
- 使用 `agnes-video-v2.0` 进行异步视频生成和轮询

它适合 Agnes 最容易上手的使用场景：

- 一个平台同时覆盖文本、图像和视频
- 公共免费试用定位降低实验门槛
- Agent、创意生成和原型开发等高频调用工作流

这个 Skill 会保持轻量：它教 Agent 如何成功调用 Agnes API，而不是把完整官方文档复制到仓库里。

## 安装

使用支持仓库 Skill 的安装器：

```bash
npx skills add jomeswang/agnes-ai-skill -g
```

这个仓库只有一个根目录 `SKILL.md`，支持仓库根目录 Skill 的安装器可以直接发现它。

已验证的安装路径：

```bash
npx skills add jomeswang/agnes-ai-skill --list
npx skills add jomeswang/agnes-ai-skill --agent codex --yes
```

仓库会被识别为一个名为 `agnes-ai-skill` 的根目录 Skill。

## 配套 CLI

推荐配套执行层：

- npm: [`agnes-ai-cli`](https://www.npmjs.com/package/agnes-ai-cli)
- GitHub: [`jomeswang/agnes-ai-cli`](https://github.com/jomeswang/agnes-ai-cli)

如果你想使用稳定命令而不是手写请求，可以安装：

```bash
npm install -g agnes-ai-cli
agnes --help
```

## 模型指南

默认选择：

- `agnes-2.0-flash`
  - 聊天、编码、流式输出、工具调用和 Agent 工作流
  - `text chat` 未传 `--model` 时的默认模型
- `agnes-image-2.1-flash`
  - 新文本生图和图生图的默认选择
  - 更适合密集布局、细节更丰富、语义对齐更强的图像
  - `image text2img`、`image img2img` 或 `image compose` 未传 `--model` 时的默认模型
- `agnes-image-2.0-flash`
  - 当你明确需要 `tags: ["img2img"]`、多图合成或 `seed` 复现时使用
- `agnes-video-v2.0`
  - 文生视频、图生视频、多图引导视频、关键帧和异步轮询
  - 当前所有 `video` 生成命令未传 `--model` 时的默认模型

官方文档中各模型侧重点不同：

- Image 2.1 更强调高信息密度视觉和构图保持
- Image 2.0 更强调编辑、合成、响应字段和 OpenAI Images 风格兼容
- Video 2.0 是任务式 API，包含生成模式、任务状态、结果轮询和帧数约束

## 场景化配置 Presets

这个 Skill 内置了一组轻量 preset。Preset 用来帮助 Agent 在执行前判断：

- 该用图片还是视频
- 该用哪个模型系列
- 该用哪个 CLI 子命令
- prompt 应该包含哪些关键要素

Preset 不是绕过 CLI 校验的捷径。对于 `--size`、`--width`、`--height`、
`--num-frames`、`--frame-rate` 等参数，Agent 必须先通过当前 CLI 的 `--help`
或 smoke test 确认支持后再使用；详细状态记录在
`docs/cli-flag-verification.md`。

### 图片 Presets

| Preset | 适用场景 |
|---|---|
| `image.quick` | 快速试稿、通用图片 |
| `image.landscape` | PPT、网页 banner、横版海报 |
| `image.portrait` | 小红书封面、手机海报、竖版视觉 |
| `image.product` | 产品广告、电商图、商业主视觉 |
| `image.edit_or_compose` | 单图编辑、多图参考合成 |

### 视频 Presets

| Preset | 适用场景 |
|---|---|
| `video.quick_preview` | 快速预览 |
| `video.standard` | 标准视频 |
| `video.social` | 竖版社媒短视频 |
| `video.cinematic` | 电影感广告、分镜、叙事镜头 |
| `video.image_to_video` | 让一张图动起来 |
| `video.keyframes` | 两张或多张图做关键帧转场 |

完整的选择规则、参数提示和本地媒体隐私风险说明都内联在 `SKILL.md` 的
`Preset Strategy` 和 `Preset Selection Rules` 章节。

## 为什么选择 Agnes

Agnes 最有价值的场景，是一个工作流需要同时用到三层能力：

- 文本：规划、编码、提示词和 Agent 循环
- 图像：营销、电商和创意视觉生成
- 视频：分镜、产品演示、运动测试和短视频内容

公开材料反复强调 Agnes 适合：

- 快速 AI 产品原型
- 高频 Agent 工作流
- 前端或 HTML 生成
- 营销和电商素材
- 广告、分镜和电影感短视频迭代

这个 Skill 把这些能力整理成一个可复用安装目标，帮助 Codex 和其他兼容 `SKILL.md` 的 Agent 选择正确模型并完成鉴权。

## 它做什么

- Agnes 快速开始文档中的平台和鉴权流程
- Agnes 平台设置页里的 API Key 创建路径
- 面向未来会话的 `AGNES_API_KEY` 持久化设置
- 文本和图像端点的 OpenAI 风格请求模式
- 视频生成的异步任务工作流
- 从公开材料提炼的实用场景

## 手动安装

如果你的工具不支持仓库安装器，可以手动复制 `SKILL.md` 到对应目录，例如：

```bash
mkdir -p ~/.codex/skills/agnes-ai-skill
cp SKILL.md ~/.codex/skills/agnes-ai-skill/SKILL.md
```

然后在新会话中让 Agent 使用 `agnes-ai-skill`。

## 打包成 `.skill` 发布

仓库可以打包为自包含的 `.skill` 压缩包，里面包含 `SKILL.md`、`docs/`、
`examples/`、`configs/`、`scripts/`、`tests/`、两个 README、showcase 资源
和 `LICENSE`。

### 构建

```bash
# 完整包（含展示视频）
bash scripts/build-skill.sh

# 精简包（跳过展示视频，约 12 MB 而非 24 MB）
bash scripts/build-skill.sh --light
```

产物写入 `dist/agnes-ai-skill-<version>.skill`，`<version>` 从
`SKILL.md` frontmatter 读取。包内还会包含 `BUILD_INFO.txt`，记录构建
日期、主机和 git commit。

### 校验

```bash
bash scripts/verify-skill.sh dist/agnes-ai-skill-<version>.skill
```

校验脚本会在临时目录解压、核对每个必备文件、验证 frontmatter、
交叉对照 `BUILD_INFO.txt`，并再次运行包内的 `tests/verify_presets.sh`
与 `tests/verify_e2e.sh`。

### 安装已构建的 `.skill`

下载 release 中的 `.skill` 文件后，解压到 skills 目录即可：

```bash
mkdir -p ~/.claude/skills
tar -xzf agnes-ai-skill-1.3.0.skill -C ~/.claude/skills
mv ~/.claude/skills/agnes-ai-skill ~/.claude/skills/agnes-ai-skill-1.3.0
```

然后重启 Agent 让它读取新的 skill 元数据。
