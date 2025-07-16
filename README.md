# Python Arguments Completion Plugin

An intelligent oh-my-zsh plugin that provides automatic completion for Python script command-line arguments.

## Features

- **Argument Name Completion**: Automatically parses argparse parameter definitions in Python files
- **Argument Value Completion**: Intelligently completes predefined choices and default values
- **Filesystem Fallback**: Automatically uses filesystem completion when no predefined values match
- **Prefix Matching**: Supports intelligent matching for partial input
- **Hybrid Completion**: Displays both predefined values and file path options simultaneously

## Installation

### 1. Create Plugin Directory

```bash
mkdir -p ~/.oh-my-zsh/custom/plugins/python-args-completion
```

### 2. Save Plugin File

Save the plugin code to:
```bash
~/.oh-my-zsh/custom/plugins/python-args-completion/python-args-completion.plugin.zsh
```

### 3. Enable Plugin

Edit `~/.zshrc` file and add the plugin to the `plugins` array:

```bash
plugins=(
    git
    python-args-completion
    # other plugins...
)
```

### 4. Reload Configuration

```bash
source ~/.zshrc
```

## Usage Examples

Suppose you have a `train.py` file:

```python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--model', choices=['bert', 'gpt', 'diffusers/stable-diffusion-xl'], default='bert')
parser.add_argument('--device', choices=['cpu', 'cuda', 'fp16'], default='cpu')
parser.add_argument('--output_dir', type=str, help='Output directory')
parser.add_argument('--batch_size', type=int, default=32)
```

### Argument Name Completion

```bash
python train.py --<TAB>
# Shows: --model --device --output_dir --batch_size
```

### Argument Value Completion (Predefined Values)

```bash
python train.py --model <TAB>
# Shows: bert gpt diffusers/stable-diffusion-xl + file completion

python train.py --model dif<TAB>
# Shows: diffusers/stable-diffusion-xl + files matching "dif" prefix

python train.py --device <TAB>
# Shows: cpu cuda fp16 + file completion
```

### Argument Value Completion (Filesystem)

```bash
python train.py --output_dir <TAB>
# Shows: files and folders in current directory

python train.py --output_dir /data<TAB>
# Shows: path completion starting with /data
```

### Mixed Scenarios

```bash
python train.py --model bert --output_dir /datasets/<TAB>
# Shows: files and folders under /datasets/ directory

python train.py --device c<TAB>
# Shows: cpu cuda (matching prefix "c") + files starting with "c"
```

## Supported Python Syntax

The plugin supports the following argparse syntax patterns:

### Basic Parameter Definition

```python
parser.add_argument('--model', choices=['bert', 'gpt'])
parser.add_argument('--device', default='cpu')
parser.add_argument('--output', type=str)
```

### Compound Definition

```python
parser.add_argument('--format', choices=['json', 'yaml'], default='xml')
# Completion will show: json yaml xml
```

### Supported Call Patterns

```python
# Method 1: Through parser object
parser = argparse.ArgumentParser()
parser.add_argument('--model', choices=['bert', 'gpt'])

# Method 2: Direct call (uncommon but supported)
add_argument('--device', choices=['cpu', 'cuda'])
```

## Completion Logic

### Priority Order

1. **Predefined Value Matching**: Prioritizes displaying choices and default values that match the current input prefix
2. **Filesystem Completion**: Simultaneously provides file and directory completion as alternatives

### Smart Detection

- When typing `--`: Complete argument names
- When typing argument values: Match predefined values first, while providing file completion
- When Python file parsing fails: Fall back to standard file completion

## Compatibility

- **Zsh**: Requires oh-my-zsh framework
- **Python**: Requires Python 3.6+ with ast module support
- **Systems**: Supports Linux, macOS, and WSL

## Troubleshooting

### Completion Not Working

1. Confirm the plugin is correctly installed in the specified directory
2. Check if the plugin name is correctly added in `~/.zshrc`
3. Reload configuration: `source ~/.zshrc`

### Python File Parsing Failed

1. Ensure Python file syntax is correct and can be parsed by `ast.parse()`
2. Check if using standard `argparse.ArgumentParser` syntax
3. Confirm Python 3 is available in system PATH

### File Completion Not Working

The plugin automatically falls back to standard zsh file completion. If not working, it might be a zsh configuration issue.

## Contributing

Issues and Pull Requests are welcome!

## License

MIT License

## Changelog

### v1.0.0
- Initial release
- Support for argument name and value completion
- Support for choices and default value parsing
- Intelligent filesystem fallback mechanism
