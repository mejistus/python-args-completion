# path: ~/.oh-my-zsh/custom/plugins/python-args-completion/

_python_args_completion() {
    local curcontext="$curcontext" state line
    local python_file=""
    local -a args
    
    # 判断补全类型
    local completion_type="files"  # 默认文件补全
    local target_arg=""
    
    if [[ "$words[CURRENT]" == --* ]]; then
        # 当前输入是参数名
        completion_type="args"
    else
        # 检查前面是否有参数，且中间没有其他参数
        for (( i=CURRENT-1; i>=1; i-- )); do
            if [[ "${words[i]}" == --* ]]; then
                # 找到了前面的参数，检查中间是否有其他参数
                local has_other_arg=false
                for (( j=i+1; j<CURRENT; j++ )); do
                    if [[ "${words[j]}" == --* ]]; then
                        has_other_arg=true
                        break
                    fi
                done
                
                if [[ "$has_other_arg" == false ]]; then
                    # 中间没有其他参数，当前是参数值
                    completion_type="values"
                    target_arg="${words[i]}"
                fi
                break
            fi
        done
    fi
    
    # 如果是纯文件补全，直接返回
    if [[ "$completion_type" == "files" ]]; then
        _files
        return
    fi
    
    # 获取 python 文件名
    for word in "${words[@]}"; do
        if [[ "$word" == *.py ]]; then
            python_file="$word"
            break
        fi
    done
    
    # 如果没有找到 python 文件或文件不存在，使用默认补全
    if [[ -z "$python_file" || ! -f "$python_file" ]]; then
        _files
        return
    fi
    
    # 解析 python 文件中的参数和choices
    local parser_data=$(python3 -c "
import ast
import sys

def extract_args_and_choices(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    tree = ast.parse(content)
    args = []
    choices = {}
    
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            # 检查 add_argument 调用
            if ((hasattr(node.func, 'attr') and node.func.attr == 'add_argument') or
                (hasattr(node.func, 'id') and node.func.id == 'add_argument')):
                
                if node.args and isinstance(node.args[0], ast.Constant):
                    arg = node.args[0].value
                    if arg.startswith('-'):
                        args.append(arg)
                        
                        # 查找 choices 和 default 参数
                        choice_values = []
                        default_value = None
                        
                        for keyword in node.keywords:
                            if keyword.arg == 'choices':
                                if isinstance(keyword.value, ast.List):
                                    for choice in keyword.value.elts:
                                        if isinstance(choice, ast.Constant):
                                            choice_values.append(str(choice.value))
                            elif keyword.arg == 'default':
                                if isinstance(keyword.value, ast.Constant):
                                    default_value = str(keyword.value.value)
                        
                        # 合并 choices 和 default
                        all_values = choice_values[:]
                        if default_value and default_value not in all_values:
                            all_values.append(default_value)
                        
                        if all_values:
                            choices[arg] = all_values
    
    return args, choices

if __name__ == '__main__':
    try:
        args, choices = extract_args_and_choices('$python_file')
        if '$completion_type' == 'args':
            print('ARGS:' + ' '.join(args))
        elif '$completion_type' == 'values':
            if '$target_arg' in choices:
                print('VALUES:' + ' '.join(choices['$target_arg']))
            else:
                print('VALUES:')
    except:
        if '$completion_type' == 'args':
            print('ARGS:')
        else:
            print('VALUES:')
" 2>/dev/null)
    
    # 处理返回的数据
    if [[ "$completion_type" == "args" ]]; then
        # 补全参数名
        if [[ "$parser_data" =~ ^ARGS:(.*)$ ]]; then
            local args_str="${match[1]}"
            args=(${(s: :)args_str})
            if [[ ${#args[@]} -gt 0 ]]; then
                _describe 'python arguments' args
            else
                _files
            fi
        else
            _files
        fi
    elif [[ "$completion_type" == "values" ]]; then
        # 补全参数值：先尝试预定义值，再尝试文件系统
        local current_input="$words[CURRENT]"
        local -a predefined_matches
        local -a file_matches
        
        # 检查预定义值
        if [[ "$parser_data" =~ ^VALUES:(.*)$ ]]; then
            local values_str="${match[1]}"
            if [[ -n "$values_str" ]]; then
                local -a all_values
                all_values=(${(s: :)values_str})
                
                # 过滤匹配当前输入前缀的预定义值
                for value in "${all_values[@]}"; do
                    if [[ "$value" == ${current_input}* ]]; then
                        predefined_matches+=("$value")
                    fi
                done
            fi
        fi
        
        # 如果有匹配的预定义值，优先显示
        if [[ ${#predefined_matches[@]} -gt 0 ]]; then
            _describe 'predefined values' predefined_matches
        fi
        
        # 同时提供文件系统补全作为备选
        _files
    fi
}

# 注册补全函数
compdef _python_args_completion python python3
