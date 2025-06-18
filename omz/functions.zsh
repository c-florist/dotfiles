source-search(){
    find . \( \
        -name node_modules -o \
        -name .mypy_cache -o \
        -name .ruff_cache -o \
        -name .pytest_cache -o \
        -name .direnv -o \
        -name venv -o \
        -name .venv -o \
        -name .idea -o \
        -name .terraform -o \
        -name .git -o \
        -name .aws-sam -o \
        -name htmlcov -o \
        -name build -o \
        -name dist \
    \) -prune -o -type f -exec grep -I -i "$1" {} \+
}

ql () { qlmanage -p "$*" >& /dev/null & }
