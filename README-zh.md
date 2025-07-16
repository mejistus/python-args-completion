# Python Arguments Completion Plugin

一个智能的 oh-my-zsh 插件，为 Python 脚本提供命令行参数的自动补全功能。

## 功能特性

- **参数名补全**：自动解析 Python 文件中的 argparse 参数定义
- **参数值补全**：智能补全预定义的 choices 和 default 值
- **文件系统回退**：当没有预定义值匹配时，自动使用文件系统补全
- **前缀匹配**：支持部分输入的智能匹配
- **混合补全**：同时显示预定义值和文件路径选项

## 安装

### 1. 创建插件目录

```bash
mkdir -p ~/.oh-my-zsh/custom/plugins/python-args-completion
```

### 2. 保存插件文件

将插件代码保存到：
```bash
~/.oh-my-zsh/custom/plugins/python-args-completion/python-args-completion.plugin.zsh
```

### 3. 启用插件

编辑 `~/.zshrc` 文件，在 `plugins` 数组中添加插件：

```bash
plugins=(
    git
    python-args-completion
    # 其他插件...
)
```

### 4. 重新加载配置

```bash
source ~/.zshrc
```

## 使用示例

假设你有一个 `train.py` 文件：

```python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--model', choices=['bert', 'gpt', 'diffusers/stable-diffusion-xl'], default='bert')
parser.add_argument('--device', choices=['cpu', 'cuda', 'fp16'], default='cpu')
parser.add_argument('--output_dir', type=str, help='输出目录')
parser.add_argument('--batch_size', type=int, default=32)
```

### 参数名补全

```bash
python train.py --<TAB>
# 显示: --model --device --output_dir --batch_size
```

### 参数值补全（预定义值）

```bash
python train.py --model <TAB>
# 显示: bert gpt diffusers/stable-diffusion-xl + 文件补全

python train.py --model dif<TAB>
# 显示: diffusers/stable-diffusion-xl + 匹配 "dif" 前缀的文件

python train.py --device <TAB>
# 显示: cpu cuda fp16 + 文件补全
```

### 参数值补全（文件系统）

```bash
python train.py --output_dir <TAB>
# 显示: 当前目录的文件和文件夹

python train.py --output_dir /data<TAB>
# 显示: 以 /data 开头的路径补全
```

### 混合场景

```bash
python train.py --model bert --output_dir /datasets/<TAB>
# 显示: /datasets/ 目录下的文件和文件夹

python train.py --device c<TAB>
# 显示: cpu cuda（匹配前缀 "c"）+ 以 "c" 开头的文件
```

## 支持的 Python 语法

插件支持以下 argparse 语法模式：

### 基本参数定义

```python
parser.add_argument('--model', choices=['bert', 'gpt'])
parser.add_argument('--device', default='cpu')
parser.add_argument('--output', type=str)
```

### 复合定义

```python
parser.add_argument('--format', choices=['json', 'yaml'], default='xml')
# 补全时会显示: json yaml xml
```

### 支持的调用方式

```python
# 方式1：通过 parser 对象
parser = argparse.ArgumentParser()
parser.add_argument('--model', choices=['bert', 'gpt'])

# 方式2：直接调用（不常见但支持）
add_argument('--device', choices=['cpu', 'cuda'])
```

## 补全逻辑

### 优先级顺序

1. **预定义值匹配**：优先显示匹配当前输入前缀的 choices 和 default 值
2. **文件系统补全**：同时提供文件和目录补全作为备选方案

### 智能判断

- 当输入 `--` 时：补全参数名
- 当输入参数值时：先匹配预定义值，同时提供文件补全
- 当无法解析 Python 文件时：回退到标准文件补全

## 兼容性

- **Zsh**: 需要 oh-my-zsh 框架
- **Python**: 需要 Python 3.6+ 支持 ast 模块
- **系统**: 支持 Linux、macOS 和 WSL

## 故障排除

### 补全不工作

1. 确认插件已正确安装到指定目录
2. 检查 `~/.zshrc` 中是否正确添加了插件名
3. 重新加载配置：`source ~/.zshrc`

### Python 文件解析失败

1. 确认 Python 文件语法正确，可以被 `ast.parse()` 解析
2. 检查是否使用了标准的 `argparse.ArgumentParser` 语法
3. 确认 Python 3 在系统 PATH 中可用

### 文件补全不工作

插件会自动回退到标准的 zsh 文件补全，如果不工作可能是 zsh 配置问题。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 更新日志

### v1.0.0
- 初始版本发布
- 支持参数名和参数值补全
- 支持 choices 和 default 值解析
- 智能文件系统回退机制
