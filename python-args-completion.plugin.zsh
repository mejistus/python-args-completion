# path: ~/.oh-my-zsh/custom/plugins/python-args-completion/

_python_args_completion() {
    local curcontext="$curcontext" state line
    local python_file=""
    local -a args
    
    local completion_type="files"
    local target_arg=""
    
    if [[ "$words[CURRENT]" == --* ]]; then
        completion_type="args"
    else
        for (( i=CURRENT-1; i>=1; i-- )); do
            if [[ "${words[i]}" == --* ]]; then
                local has_other_arg=false
                for (( j=i+1; j<CURRENT; j++ )); do
                    if [[ "${words[j]}" == --* ]]; then
                        has_other_arg=true
                        break
                    fi
                done
                
                if [[ "$has_other_arg" == false ]]; then
                    completion_type="values"
                    target_arg="${words[i]}"
                fi
                break
            fi
        done
    fi
    
    if [[ "$completion_type" == "files" ]]; then
        _files
        return
    fi

    for word in "${words[@]}"; do
        if [[ "$word" == *.py ]]; then
            python_file="$word"
            break
        fi
    done
    
    if [[ -z "$python_file" || ! -f "$python_file" ]]; then
        _files
        return
    fi
    
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
            if ((hasattr(node.func, 'attr') and node.func.attr == 'add_argument') or
                (hasattr(node.func, 'id') and node.func.id == 'add_argument')):
                
                if node.args and isinstance(node.args[0], ast.Constant):
                    arg = node.args[0].value
                    if arg.startswith('-'):
                        args.append(arg)
                        
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
    
    if [[ "$completion_type" == "args" ]]; then
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
        local current_input="$words[CURRENT]"
        local -a predefined_matches
        local -a file_matches
        
        if [[ "$parser_data" =~ ^VALUES:(.*)$ ]]; then
            local values_str="${match[1]}"
            if [[ -n "$values_str" ]]; then
                local -a all_values
                all_values=(${(s: :)values_str})
                
                for value in "${all_values[@]}"; do
                    if [[ "$value" == ${current_input}* ]]; then
                        predefined_matches+=("$value")
                    fi
                done
            fi
        fi
        
        if [[ ${#predefined_matches[@]} -gt 0 ]]; then
            _describe 'predefined values' predefined_matches
        fi
        
        _files
    fi
}

compdef _python_args_completion python python3
